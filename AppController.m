//
//  AppController.m
//  SubtitleConverter
//
//  Created by Andrew Hughes on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"


@implementation AppController

#pragma mark App Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// APP DELEGATE METHODS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
	The following are implented to allow the user to drop files onto the application icon (also had to add file types to the app plist).
*/

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	fileToOpen = nil; // initialize temp string pointer to nil so that we know if it was assigned
}

// this is called after "applicationWillFinishLaunching" and before "applicationDidFinishLaunching"
// we save a copy of the filename to open so that we can open it in "applicationDidFinishLaunching"
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	fileToOpen = [filename retain];
	return YES;
}

// if we have a file to open, open it!
-(void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	if (fileToOpen) 
	{
		[self tryLoadFile:fileToOpen];
	}
}

// save prefs when user quits app
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[self loadVarsAndSavePrefs];
}


#pragma mark Initialization
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// WAKE FROM NIB (INITIALIZATION)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// initiailization after object is instantiated and ready from the nib
- (void) awakeFromNib
{



	// clear the text views
	[[[sourceTextView textStorage] mutableString] setString:@""];
	[[[resultTextView textStorage] mutableString] setString:@""];
	
	// set both text views to not editable
	[sourceTextView setEditable:NO];
	[resultTextView setEditable:NO];
	
	// set the source path text field to not editable
	[sourceTextField setEditable:NO];
	
	// create a number character set for testing to see if a given line starts with a timecode
	numCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] retain];

		
	// convert and save should be disabled until a file is loaded
	[convertButton setEnabled:NO];
	[saveAsButton setEnabled:NO];
	
	// tool tips, just to be nice
	[frameRateTextField setToolTip:@"This value is used to convert miliseconds to frames in the timecodes."];
	[newlineCharTextField setToolTip:@"Newlines in the subtitle text of the iSBV are replaced with this character."];
	[separatorTextField setToolTip:@"The character used to separate timecodes and subtitle text. Enter \"tab\" to use tabs."];
	
	// default character added between different lines of subtitle text is a space
	[newlineCharTextField setStringValue:@" "];
	
	result = nil;
	separator = nil;
	newLineChar = nil;
	[separatorTextField setStringValue:@","];
	addQuotes = NO;
	frameRate = 30;

	//[self setStandardPrefs];
	[self loadPrefs];

}


// clean up
- (void) dealloc
{
	if (result) [result release];
	if (sourceLines) [sourceLines release];
	[numCharSet release];
	[super dealloc];
}	


#pragma mark Prefs
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PREFERENCES
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// loads the saved prefs
// - note that temp string vars are used because we do not retain the separator and newLineChar strings; instead
//   they are read from the text fields right before use in the parse function
- (void) loadPrefs
{
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"PrefsSet"])
	{
		[self setStandardPrefs];
	}
	
	addQuotes = [[NSUserDefaults standardUserDefaults] boolForKey:@"AddQuotes"];
	
	if (addQuotes)
	{
		[addQuotesCheckBox setState:NSOnState];
	}
	else
	{
		[addQuotesCheckBox setState:NSOffState];
	}
	
	NSString * _separator = [[NSUserDefaults standardUserDefaults] objectForKey:@"Separator"];
	if ([_separator isEqualToString:@"\t"]) [separatorTextField setStringValue:@"tab"];
	else [separatorTextField setStringValue:_separator];
	

	frameRate = [[NSUserDefaults standardUserDefaults] integerForKey:@"FrameRate"];
	[frameRateTextField setIntValue:frameRate];
	
	NSString * _newLineChar = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewLineChar"];
	[newlineCharTextField setStringValue:_newLineChar];

}

- (IBAction) resetPrefs:(id)sender
{
	[self setStandardPrefs];
	[self loadPrefs];
}

// sets the standard prefs 
- (void) setStandardPrefs
{
	[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"PrefsSet"];
	[[NSUserDefaults standardUserDefaults] setObject:@"," forKey:@"Separator"];
	[[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"AddQuotes"];
	[[NSUserDefaults standardUserDefaults] setInteger:30 forKey:@"FrameRate"];
	[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"NewLineChar"];
}


// saves the prefs and loads the option vars from the text fields and check box
- (void) loadVarsAndSavePrefs
{

	newLineChar = [newlineCharTextField stringValue];
	
	if ([newLineChar isEqualToString:@""]) newLineChar = @" ";
	
	separator = [separatorTextField stringValue];
	
	if ([separator isEqualToString:@"\t"] || [[separator lowercaseString] isEqualToString:@"tab"]) separator = @"\t";
	
	addQuotes = ([addQuotesCheckBox state] == NSOnState);


	[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"PrefsSet"];
	[[NSUserDefaults standardUserDefaults] setObject:separator forKey:@"Separator"];
	[[NSUserDefaults standardUserDefaults] setBool:addQuotes forKey:@"AddQuotes"];
	[[NSUserDefaults standardUserDefaults] setInteger:frameRate forKey:@"FrameRate"];
	[[NSUserDefaults standardUserDefaults] setObject:newLineChar forKey:@"NewLineChar"];
}



#pragma mark Help
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// HELP
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (IBAction) showHelp:(id)sender
{
	[helpWindow makeKeyAndOrderFront:self];
}



#pragma mark Frame Rate Validation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FRAME RATE TEXT FIELD ACTION (validates entry)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// frame rate text field action
// validate frame rate values entered into the text field
- (IBAction) frameRateTextFieldAction:(id)sender
{
	// get the integer value from the text field
	int newFrameRate = [sender integerValue];
	
	// reality check the frame rate
	if (newFrameRate < 12 || newFrameRate > 100)
	{
		NSAlert *alert = [[NSAlert alloc] init];

		[alert addButtonWithTitle:@"OK"];
		
		[alert setMessageText:@"Please enter a frame rate between 1 and 100."];

		[alert setAlertStyle:NSWarningAlertStyle];
		
		[alert runModal];
		
		[alert release];
		
		[frameRateTextField setIntegerValue:frameRate];
	}
	else
	{
		frameRate = newFrameRate;
	}
}


#pragma mark Save & Load
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SAVE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// the save button action
- (IBAction) saveAsButtonAction:(id)sender
{
	// make a save panel
	NSSavePanel * sPanel = [NSSavePanel savePanel];	
	
	// set allowed types
	[sPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"csv", @"txt", nil]];
	[sPanel setAllowsOtherFileTypes:YES];
	
	// show the panel
	int sResult = [sPanel runModal];
			
	
	if (sResult == NSOKButton)
	{
		NSString * selectedFilename = [sPanel filename];
		NSError *error;

		BOOL ok = [[[resultTextView textStorage] mutableString] writeToFile:selectedFilename atomically:YES encoding:NSUnicodeStringEncoding error:&error];


		// on error
		if (!ok) 
		{

			NSAlert * alert = [NSAlert alertWithError:error];
			[alert runModal];
		
			[alert release];
			
			NSLog(@"Error writing file at %@\n%@", selectedFilename, [error localizedFailureReason]);

		}
		
		// on success
		else
		{
			NSAlert *alert = [[NSAlert alloc] init];

			[alert addButtonWithTitle:@"OK"];
			
			[alert setMessageText:@"File saved successfully!"];
			[alert setInformativeText:selectedFilename];

			[alert setAlertStyle:NSWarningAlertStyle];
			
			[alert runModal];
			
			[alert release];
		}
	}
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// LOAD
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// load source button action
- (IBAction) loadSourceButtonAction:(id)sender
{
	
	// create an open panel
	NSOpenPanel * oPanel = [NSOpenPanel openPanel];

	// set the allowed file types
	NSArray * fileTypes =  [NSArray arrayWithObjects:@"txt",@"sbv",nil];

	// run the panel and get the result
	int panelResult = [oPanel runModalForTypes:fileTypes];
	
	// if we selected a file to open
	if (panelResult == NSOKButton)
	{
		// get the file name
		sourceFileName = [oPanel filename];
			
		[self tryLoadFile:sourceFileName];
	}		
}

- (BOOL) tryLoadFile:(NSString*)file
{
			// try and load the file
		
		NSError * error = nil;
		sourceText = [[NSString stringWithContentsOfFile:file usedEncoding:nil error:&error] retain];
		
		// if no error
		if (error == nil)
		{
			sourceFileName = file;
		
			// load the text into the source text view
			[[[sourceTextView textStorage] mutableString] setString:sourceText];

			// load the file name into the source file name text field
			[sourceTextField setStringValue:sourceFileName];
			
			// cause the source text view to show the loaded text
			[sourceTextView display];
			
			// enable the convert button and allow user to edit the source text
			[convertButton setEnabled:YES];
			[sourceTextView setEditable:YES];
			
			return TRUE;
		}
		
		// on error
		else
		{
			NSAlert * alert = [NSAlert alertWithError:error];
			[alert runModal];
			[alert release];
			
			return FALSE;
		}
}


#pragma mark Parse/Convert
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CONVERT
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// convert button action
- (IBAction) convertButtonAction:(id)sender
{
		// split the source text into lines
		sourceLines = [[[[sourceTextView textStorage] mutableString] componentsSeparatedByString:@"\n"] retain];
		
		// parse it!
		[self parse];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PARSE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// this is where the magic happens - the file is parsed and reformated
- (void) parse
{

	[NSApp beginSheet:progressPanel modalForWindow:window modalDelegate:self didEndSelector:NULL contextInfo:NULL];
	[progressIndicator setMinValue:0.0];
	double max = (double)[sourceLines count];
	[progressIndicator setMaxValue:max];
	[progressIndicator setUsesThreadedAnimation:YES];

	[self loadVarsAndSavePrefs];
	

	// "result" holds the converted file as it is generated
	if (result) [result release];	
	result = [[NSMutableString alloc] init]; 
	
	// enumerator to iterate through the lines of our source file
	NSEnumerator * etr = [sourceLines objectEnumerator];
	
	// iterator variable that holds each new line of source file
	NSString * nextLine;
	
	// this is a temp variable that will accrue the different lines of subtitle text for each subtitle
	// bc in the SBV a single subtitle can be split across multiple consecutive lines
	NSMutableString * subText = nil;
	
	double counter = 0.0;
	
	@try
	{
	
		// the main loop
		// - here we iterate through every line of the file, createing the translation as we go
		while (nextLine = [etr nextObject])
		{
		
			// is the current line a timecode line?
			if ([self isStartOfTimeCode:nextLine index:0])
			{
				
				// if subText is NOT nil, then we have some subtitle text from a previous loop iteration
				// that needs to be appended to the results string before we process the timecodes on the
				// new current line
				if (subText != nil)
				{
					// this line gets rid of the extraneous new line character that was added below
					if (newLineChar != nil && ![newLineChar isEqualToString:@""])
						subText = [[[subText substringToIndex:[subText length] - 1] mutableCopy] autorelease];

					// close out quotes if necessary
					if (addQuotes) [subText appendString:@"\""];

					// add the comma, subtitle text, and a newline to the results
					[result appendString:separator];
					[result appendString:subText];
					[result appendString:@"\n"];
					
					// set to nil so that we know we're starting over
					subText = nil;
				}
				
				// get the timecodes from the line
				// - the timecodes are converted from miliseconds to frames by a helper method
				NSArray * tcs = [self getTimecodes:nextLine];
				
				// add the timecodes to the results string
				[result appendString:[NSString stringWithFormat:@"%@%@%@", [tcs objectAtIndex:0],separator, [tcs objectAtIndex:1]]];
				
			}
			
			// the current line is NOT a timecode line, it must be a subtitle text line
			else
			{
				// if subText is nil, this is the first subtitle text line and we need to initialize the string
				if (subText == nil)
				{
					subText = [[[NSMutableString alloc] init] autorelease];
					if (addQuotes) [subText appendString:@"\""];
				}
				
				// trim any extra whitespace (which also reduces empty lines to zero length so we can ignore them)
				nextLine = [self trimWhite:nextLine];
				
				// only append lines with actual, non-whitespace text
				if ([nextLine length] > 0)
				{
					[subText appendString:nextLine];
					[subText appendString:newLineChar];
				}
			}
		
		}
		
		
		// force the display to refresh
		//[[[resultTextView textStorage] mutableString] setString:result];
		
		// force the results text view to scroll to the last line
		//NSRect frame = [resultTextView frame];
		//[resultTextView scrollPoint: NSMakePoint(0, frame.origin.y + frame.size.height)];
		//[resultTextView display];
		
		[progressIndicator setDoubleValue:counter];
		[progressIndicator display];
		counter++;
	}
	
	@catch ( NSException *e)
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:[e name]];
		[alert setInformativeText:[e reason]];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert runModal];
		[alert release];

	}
	
	@finally 
	{
		[NSApp endSheet:progressPanel returnCode:NSOKButton];
		[progressPanel orderOut:nil];		
	}


	// have to process the last bit of subtitle text
	if (subText != nil)
	{
		[result appendString:separator];
		[result appendString:subText];
		subText = nil;
	}
	
	[NSApp endSheet:progressPanel returnCode:NSOKButton];
	[progressPanel orderOut:nil];
	
	// refresh the display
	[[[resultTextView textStorage] mutableString] setString:result];
	[resultTextView display];
	[resultTextView setEditable:YES];
	
	// enable the save button
	[saveAsButton setEnabled:YES];

}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PARSE/CONVERT HELPERS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// returns two trimmed and converted timecodes as an array from a string containing two timecodes
- (NSArray*) getTimecodes:(NSString*)string
{
	// we assume that the timecodes are separated by a comma
	NSArray * timecodes = [string componentsSeparatedByString:@","];
	
	// make sure that we have two well-formed time codes
	if ([timecodes count] != 2)
	{
			
		[result appendString:[NSString stringWithFormat:@"Timecode appears to be invalid!  %@", string]];

		// refresh the display
		[[[resultTextView textStorage] mutableString] setString:result];
		[resultTextView display];

		[NSException raise:@"Invalid Timecode" format:@"Timecode appears to be invalid!  %@", string];
	}
	
	// convert timecodes and trim any whitespace
	NSMutableArray * trimmedTimecodes = [NSArray arrayWithObjects:	
											[self convertTimecode:[self trimWhite:[timecodes objectAtIndex:0]]], 
											[self convertTimecode:[self trimWhite:[timecodes objectAtIndex:1]]], nil];
	
	
	return trimmedTimecodes;	
}

// converts a timecode from miliseconds to frames
- (NSString*) convertTimecode:(NSString*)timecode
{
	// separate timecode by the "."
	NSArray * components = [timecode componentsSeparatedByString:@"."];
	
	// make sure that we have a well-formed time code
	if ([components count] != 2 || [[components objectAtIndex:1] length] != 3)
	{		
		[result appendString:[NSString stringWithFormat:@"Timecode appears to be invalid!  %@", timecode]];

		// refresh the display
		[[[resultTextView textStorage] mutableString] setString:result];
		[resultTextView display];

		[NSException raise:@"Invalid Timecode" format:@"Timecode appears to be invalid!  %@", timecode];
	}

	// get miliseconds from timecode
	int miliseconds = [[components objectAtIndex:1] integerValue];
	
	// convert to frames
	int frames = round((float)miliseconds / 1000 * (float)frameRate);
	
	// create new timecode string
	NSString * newTC = [NSString stringWithFormat:@"0%@:%02d", [components objectAtIndex:0], frames];
	
	return newTC;
	
}

// trims whitespace
- (NSString*)trimWhite:(NSString*) string
{
	return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

// is the character in the string at the index a number between 0-9?
- (BOOL) isNumberInString:(NSString*)string index:(int)index
{
	return [numCharSet characterIsMember:[string characterAtIndex:index]];
}

// determines if we are at the start of a timecode by looking for a number and a colon
- (BOOL) isStartOfTimeCode:(NSString*)string index:(int)index
{

	[[string retain] autorelease];

	if (index + 1 >= [string length]) return NO;

	if ([numCharSet characterIsMember:[string characterAtIndex:index]] && 
		[string characterAtIndex:index+1] == ':') return YES;
	else return NO;
}


@end
