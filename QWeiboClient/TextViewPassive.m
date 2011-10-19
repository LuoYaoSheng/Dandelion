//
//  TextViewPassive.m
//  Dandelion
//
//  Created by  on 11-10-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TextViewPassive.h"

@implementation TextViewPassive

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [[self nextResponder] mouseDown:theEvent]; 
    [[self window] makeFirstResponder:self];
    [super mouseDown:theEvent];
}

@end
