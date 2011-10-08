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

typedef enum {
    QWShowTabTimeline = 1,
    QWShowTabMethions,
    QWShowTabMessages,
    QWShowTabFavorite,
    QWShowTabPeople,
    QWShowTabSearch
} QWShowTab;

@interface QWMainWindowController : NSWindowController
{
    NSMutableDictionary *allControllers;
    NSViewController *currentViewController;
    NSInteger selectedIndex;
    QWeiboAsyncApi *api;
}

@property (assign) NSViewController* currentViewController;
@property (assign) IBOutlet NSTextField *statusLabel;
@property (assign) IBOutlet NSButton *headButton;

- (IBAction)toggleTab:(id)sender;
- (IBAction)publishMessage:(id)sender;

@end
