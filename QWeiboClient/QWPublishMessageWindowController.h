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

@interface QWPublishMessageWindowController : NSWindowController {
    QWeiboAsyncApi *api;
}

@property (assign) IBOutlet NSTextField *atLabel;
@property (assign) IBOutlet NSTextView *messageTextView;
@property (retain) QWMessage *orgMessage;

- (IBAction)publishClicked:(id)sender;
- (IBAction)cacelClicked:(id)sender;

@end
