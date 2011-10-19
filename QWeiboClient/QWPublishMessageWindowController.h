//
//  QWPublishMessageWindowController.h
//  QWeiboClient
//
//  Created by Leon on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QWeiboAsyncApi.h"
#import "QWMessage.h"
#import "DragDropImageView.h"

@interface QWPublishMessageWindowController : NSWindowController<DragDropImageViewDelegate, NSTextViewDelegate> {
    QWeiboAsyncApi *api;
    NSButton *_publishButton;
}

@property (assign) IBOutlet NSTextField *atLabel;
@property (assign) IBOutlet NSTextView *messageTextView;
@property (retain) QWMessage *orgMessage;
@property (assign) IBOutlet DragDropImageView *imageView;
@property (assign) IBOutlet NSTextField *imageLabel;
@property (assign) IBOutlet NSButton *deleteImageButton;
@property (copy) NSString *filePath;
@property (assign) IBOutlet NSButton *publishButton;

- (IBAction)publishClicked:(id)sender;
- (IBAction)cacelClicked:(id)sender;
- (IBAction)deleteImageClicked:(id)sender;

@end
