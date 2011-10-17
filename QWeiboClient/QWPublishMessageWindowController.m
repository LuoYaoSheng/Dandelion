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
@synthesize orgMessage = _orgMessage;
@synthesize imageView = _imageView;
@synthesize imageLabel = _imageLabel;
@synthesize deleteImageButton = _deleteImageButton;
@synthesize atLabel = _atLabel;
@synthesize filePath = _filePath;

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
    self.imageView.allowDrag = NO;
    self.imageView.delegate = self;
    if (self.orgMessage) {
        self.atLabel.stringValue = [NSString stringWithFormat:@"@%@", self.orgMessage.nick];
        self.imageView.allowDrop = NO;
        self.imageLabel.stringValue = @"不能添加图片";
        [self.deleteImageButton setHidden:YES];
    } else {
        self.imageView.allowDrop = YES;
        self.imageLabel.stringValue = @"拖动图片到这里";
        [self.deleteImageButton setHidden:NO];
    }
}

- (void)dealloc
{
    [api release];
    [_orgMessage release];
    [_filePath release];
    [super dealloc];
}

- (IBAction)publishClicked:(id)sender {
    if (self.orgMessage)
        [api retweet:self.messageTextView.string reid:self.orgMessage.tweetId];
    else {
        if (self.filePath && ![self.filePath isEqualToString:@""])
            [api publishMessage:self.messageTextView.string withPicture:self.filePath];
        else
            [api publishMessage:self.messageTextView.string];
    }
        
    [NSApp endSheet:self.window];
}

- (IBAction)cacelClicked:(id)sender {
    [NSApp endSheet:self.window];    
}

- (IBAction)deleteImageClicked:(id)sender 
{    
    self.imageView.image = nil;
    [self.imageLabel setHidden:NO];
}

- (void)dropComplete:(NSString *)filePath
{
    [self.imageLabel setHidden:YES];
    self.filePath = filePath;
}

@end
