//
//  RoundedButtonCell.m
//  QWeiboClient
//
//  Created by Leon on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RoundedButtonCell.h"

@implementation RoundedButtonCell

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    [[NSColor whiteColor] set];
    NSRect rectInFrame = NSInsetRect(frame, 2, 2);
    NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRoundedRect:rectInFrame xRadius:5.0 yRadius:5.0];
    [roundedRect setClip];
	[roundedRect fill];
}

@end
