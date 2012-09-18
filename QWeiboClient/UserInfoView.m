//
//  UserInfoView.m
//  Dandelion
//
//  Created by Leon on 9/18/12.
//
//

#import "UserInfoView.h"

@implementation UserInfoView

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
    [RGBCOLOR(100,100,100) set];
    CGContextFillRect(context, NSRectToCGRect(dirtyRect));
}

@end
