//
//  QWViewImageWindowController.h
//  QWeiboClient
//
//  Created by Leon on 10/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QWViewImageWindowController : NSWindowController

@property (assign) IBOutlet NSImageView *imageView;

- (void)loadImage:(NSString *)imageURL;

@end
