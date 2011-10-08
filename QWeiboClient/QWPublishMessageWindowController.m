//
//  QWPublishMessageWindowController.m
//  QWeiboClient
//
//  Created by Leon on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QWPublishMessageWindowController.h"

@implementation QWPublishMessageWindowController

@synthesize messageTextView = _messageTextView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        api = [[QWeiboAsyncApi alloc] init];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.messageTextView.font = [NSFont systemFontOfSize:13];
}

- (void)dealloc
{
    [api release];
    [super dealloc];
}

- (IBAction)publishClicked:(id)sender {
    [api publishMessage:self.messageTextView.string];
    [NSApp endSheet:self.window];
}

- (IBAction)cacelClicked:(id)sender {
    [NSApp endSheet:self.window];    
}

@end
