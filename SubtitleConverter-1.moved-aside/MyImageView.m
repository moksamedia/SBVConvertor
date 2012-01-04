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
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationLow];
	[super drawRect:rect];
}
@end
