//
//  MyView.m
//  QWeiboClient
//
//  Created by Leon on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyView.h"

@implementation MyView

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
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize
{
    [super resizeWithOldSuperviewSize:oldBoundsSize];
    [[NSNotificationCenter defaultCenter] postNotificationName:LISTVIEW_RESIZED_NOTIFICATION object:nil];
}

@end