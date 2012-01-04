//
//  MyImageView.m
//  SubtitleConverter
//
//  Created by Andrew Hughes on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyImageView.h"


@implementation MyImageView

- (void)drawRect:(NSRect)rect 
{
	[NSGraphicsContext saveGraphicsState];
	NSGraphicsContext * myGC = [NSGraphicsContext graphicsContextWithWindow:[self window]];
	[myGC setShouldAntialias:NO];
	[myGC setImageInterpolation:NSImageInterpolationNone];
	[super drawRect:rect];
	[NSGraphicsContext restoreGraphicsState];
}

@end
