//
//  QWViewImageWindowController.h
//  QWeiboClient
//
//  Created by Leon on 10/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QWMessage.h"

@interface QWViewImageWindowController : NSWindowController {

}

@property (assign) IBOutlet NSImageView *imageView;
@property (assign) IBOutlet NSProgressIndicator *progessIndicator;
@property (retain) QWMessage *message;

- (void)loadImageForMessage:(QWMessage *)message;

@end
