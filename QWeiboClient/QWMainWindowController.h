//
//  QWMainWindow.h
//  QWeiboClient
//
//  Created by  on 11-9-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QWVerifyWindowController.h"

@interface QWMainWindowController : NSWindowController
{
    NSMutableDictionary *allControllers;
    NSViewController *currentViewController;
}

@property (assign) NSViewController* currentViewController;

- (IBAction)homeTappped:(id)sender;
- (IBAction)metionsTapped:(id)sender;
@end
