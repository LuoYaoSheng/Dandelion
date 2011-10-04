//
//  ToolboxView.m
//  GuestBook
//
//  Created by  on 11-9-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ToolboxView.h"

@implementation ToolboxView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(context, 0.227,0.251,0.337,0.8);
    CGContextFillRect(context, NSRectToCGRect(dirtyRect));
}

@end
