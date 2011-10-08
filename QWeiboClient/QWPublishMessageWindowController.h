//
//  QWPublishMessageWindowController.h
//  QWeiboClient
//
//  Created by Leon on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QWeiboAsyncApi.h"

@interface QWPublishMessageWindowController : NSWindowController {
    QWeiboAsyncApi *api;
}

@property (assign) IBOutlet NSTextView *messageTextView;

- (IBAction)publishClicked:(id)sender;
- (IBAction)cacelClicked:(id)sender;

@end
