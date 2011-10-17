//
//  ScrollViewPassive.m
//  QWeiboClient
//
//  Created by  on 11-10-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>

#import "ScrollViewPassive.h"

@implementation ScrollViewPassive

// Pass any gesture scrolling up to the main, active scrollview.
- (void)scrollWheel:(NSEvent *)event {
    [[self nextResponder] scrollWheel:event];
}

@end
