//
//  QWPublishMessageWindowController.m
//  QWeiboClient
//
//  Created by Leon on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QWPublishMessageWindowController.h"

@implementation QWPublishMessageWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)publish:(id)sender {
    [NSApp endSheet:self.window];
}

@end
