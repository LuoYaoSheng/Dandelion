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
#import <Growl/Growl.h>

typedef enum {
    QWShowTabTimeline = 1,
    QWShowTabMethions,
    QWShowTabMessages,
    QWShowTabFavorites,
    QWShowTabPeople,
    QWShowTabSearch
} QWShowTab;

@interface QWMainWindowController : NSWindowController<GrowlApplicationBridgeDelegate>
{
    NSMutableDictionary *allControllers;
    NSViewController *currentViewController;
    NSInteger selectedIndex;
    QWeiboAsyncApi *api;
}

@property (assign) NSViewController* currentViewController;
@property (assign) IBOutlet NSTextField *statusLabel;
@property (assign) IBOutlet NSButton *headButton;
@property (assign) IBOutlet NSImageView *timelineBadge;
@property (assign) IBOutlet NSImageView *mentionsBadge;
@property (assign) IBOutlet NSImageView *messagesBadge;

- (IBAction)toggleTab:(id)sender;
- (IBAction)publishMessage:(id)sender;
- (IBAction)logout:(id)sender;

@end
