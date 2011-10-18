//
//  QWMainWindow.h
//  QWeiboClient
//
//  Created by  on 11-9-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QWVerifyWindowController.h"
#import "QWeiboAsyncApi.h"
#import "QWMessage.h"

typedef enum {
    QWShowTabTimeline = 1,
    QWShowTabMethions,
    QWShowTabMessages,
    QWShowTabFavorites,
    QWShowTabPeople,
    QWShowTabSearch
} QWShowTab;

@interface QWMainWindowController : NSWindowController
{
    NSMutableDictionary *allControllers;
    NSViewController *currentViewController;
    QWShowTab selectedTab;
    QWeiboAsyncApi *api;
}

@property (assign) NSViewController* currentViewController;
@property (assign) IBOutlet NSTextField *statusLabel;
@property (assign) IBOutlet NSButton *headButton;
@property (assign) IBOutlet NSImageView *timelineBadge;
@property (assign) IBOutlet NSImageView *mentionsBadge;
@property (assign) IBOutlet NSImageView *messagesBadge;
@property (assign) TweetType selectedTweetType;
@property (assign) IBOutlet NSMatrix *matrix;

- (IBAction)switchButtonClicked:(id)sender;
- (void)toggleTab:(QWShowTab)tab withInfo:(NSDictionary *)info;
- (IBAction)publishMessage:(id)sender;
- (IBAction)logout:(id)sender;
- (void)retweetMessage:(QWMessage *)message;
- (IBAction)headButtonClicked:(id)sender;

@end
