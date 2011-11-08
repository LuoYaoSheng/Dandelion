//
//  QWPublishMessageWindowController.h
//  QWeiboClient
//
//  Created by Leon on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QWeiboSDK/QWeiboAsyncApi.h>
#import <QWeiboSDK/QWMessage.h>
#import "DragDropImageView.h"

@interface QWPublishMessageWindowController : NSWindowController<DragDropImageViewDelegate, NSTextViewDelegate> {
    QWeiboAsyncApi *api;
    NSButton *_publishButton;
    NSPopUpButton *_imagePicker;
}

@property (assign) IBOutlet NSTextField *atLabel;
@property (assign) IBOutlet NSTextView *messageTextView;
@property (retain) QWMessage *orgMessage;
@property (assign) IBOutlet DragDropImageView *imageView;
@property (assign) IBOutlet NSTextField *imageLabel;
@property (assign) IBOutlet NSButton *deleteImageButton;
@property (copy) NSString *filePath;
@property (assign) IBOutlet NSButton *publishButton;
@property (assign) IBOutlet NSPopUpButton *imagePicker;

- (IBAction)publishClicked:(id)sender;
- (IBAction)cacelClicked:(id)sender;
- (IBAction)deleteImageClicked:(id)sender;
- (IBAction)takeImageFrom:(id)sender;

@end
