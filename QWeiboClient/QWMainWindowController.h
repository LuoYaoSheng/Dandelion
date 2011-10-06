//
//  QWMainWindow.h
//  QWeiboClient
//
//  Created by  on 11-9-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QWVerifyWindowController.h"

typedef enum {
    QWShowTabTimeline = 1,
    QWShowTabMethions,
    QWShowTabFavorite,
    QWShowTabPeople,
    QWShowTabSearch
} QWShowTab;

@interface QWMainWindowController : NSWindowController
{
    NSMutableDictionary *allControllers;
    NSViewController *currentViewController;
    NSInteger selectedIndex;
}

@property (assign) NSViewController* currentViewController;
@property (assign) IBOutlet NSTextField *statusLabel;

- (IBAction)toggleTab:(id)sender;

@end
