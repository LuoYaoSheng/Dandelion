//
//  QWPeopleViewController.h
//  Dandelion
//
//  Created by Leon on 9/18/12.
//
//

#import <Cocoa/Cocoa.h>
#import "QWTweetViewController.h"

@interface QWPeopleViewController : QWTweetViewController

@property (assign) IBOutlet NSView *userInfoView;
@property (assign) IBOutlet NSButton *headButton;

@end
