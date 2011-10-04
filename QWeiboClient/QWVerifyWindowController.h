//
//  QWVerifyWindow.h
//  QWeiboClient
//
//  Created by Leon on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebView.h>

@class QWVerifyWindowController;

@protocol QWVerifyDelegate <NSObject>

- (void)loginFinished:(QWVerifyWindowController *)verifyWinow;

@end

@interface QWVerifyWindowController : NSWindowController<NSWindowDelegate> {

}


@property (assign) id<QWVerifyDelegate> delegate;
@property (assign) IBOutlet WebView *webView;

@end
