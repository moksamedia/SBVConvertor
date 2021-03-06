//
//  AppController.h
//  SubtitleConverter
//
//  Created by Andrew Hughes on 11/7/11.
//	-------------------------------------------
//
//
//	All code (c)2011 Moksa Media all rights reserved
//	Developer: Andrew Hughes
//
//	This file is part of SBVConvertor.
//
//	SBVConvertor is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	SBVConvertor is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with SBVConvertor.  If not, see <http://www.gnu.org/licenses/>.
//
//
//	-------------------------------------------
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject 
{
	NSString * fileToOpen;

	// text view that displays the source file
	IBOutlet NSTextView * sourceTextView;
	
	// text view that displays the converted result
	IBOutlet NSTextView * resultTextView;
	
	// text field to display the path of the source file
	IBOutlet NSTextField * sourceTextField;
	
	// allows user to set frame rate for miliseconds conversion
	IBOutlet NSTextField * frameRateTextField;
	
	// allows user to set character to put in place of new lines
	IBOutlet NSTextField * newlineCharTextField;
	
	// separator check text field
	IBOutlet NSTextField * separatorTextField;
	
	// add quotes check box
	IBOutlet NSButton * addQuotesCheckBox;
	
	// convert and save buttons (initially disabled)
	IBOutlet NSButton * convertButton;
	IBOutlet NSButton * saveAsButton;
	
	IBOutlet NSWindow * helpWindow;
	
	// string of source text to be converted
	NSString * sourceText;
	
	// filename of source
	NSString * sourceFileName;
	
	// holds the source split apart by newlines
	NSArray * sourceLines;
	
	// character set for numbers 0-9 (used to find timecodes)
	NSCharacterSet * numCharSet;

	// holds the converted results
	NSMutableString * result;
	
	// the character used to replace newlines (default is a space)
	NSString * newLineChar;
	
	NSString * separator;
	
	BOOL addQuotes;
	
	// frame rate for miliseconds to frames conversion
	int frameRate;
	
	IBOutlet NSWindow * window;
	
	IBOutlet NSPanel * progressPanel;
	IBOutlet NSProgressIndicator * progressIndicator;

}

// prefs
- (void) loadPrefs;
- (void) loadVarsAndSavePrefs;
- (void) setStandardPrefs;
- (IBAction) resetPrefs:(id)sender;

- (BOOL) tryLoadFile:(NSString*)file;

// help
- (IBAction) showHelp:(id)sender;

// save action
- (IBAction) saveAsButtonAction:(id)sender;

// load source SBV file action
- (IBAction) loadSourceButtonAction:(id)sender;

// convert action
- (IBAction) convertButtonAction:(id)sender;

// frame rate text field action (performs some basic reality checking)
- (IBAction) frameRateTextFieldAction:(id)sender;

// main work method, parses and converts the file
- (void) parse;

// utility methods
- (NSArray*) getTimecodes:(NSString*)string;
- (NSString*)trimWhite:(NSString*)string;
- (BOOL) isNumberInString:(NSString*)string index:(int)index;
- (BOOL) isStartOfTimeCode:(NSString*)string index:(int)index;
- (NSString*) convertTimecode:(NSString*)timecode;

@end
