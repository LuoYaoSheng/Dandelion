//
//  QWeiboClientAppDelegate.h
//  QWeiboClient
//
//  Created by  on 11-9-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QWVerifyWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, QWVerifyDelegate> {
    NSStatusItem *_statusItem;
    NSMenuItem *_logoutMenuItem;
}

@property (nonatomic, retain) NSWindowController *windowController;

@end
