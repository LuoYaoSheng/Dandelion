//
//  QWeiboClientAppDelegate.m
//  QWeiboClient
//
//  Created by  on 11-9-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "QWVerifyWindowController.h"
#import "NSURL+QAdditions.h"
#import "QWMainWindowController.h"

@interface AppDelegate (Private)

- (void)checkForLogin:(NSNotification *)notification;
- (void)saveDefaultKey;
- (void)loadDefaultKey;

@end

@implementation AppDelegate

@synthesize windowController = _windowController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [_statusItem setImage:[NSImage imageNamed:@"status_on.png"]];
    [_statusItem setAlternateImage:[NSImage imageNamed:@"status_off.png"]];
    [_statusItem setHighlightMode:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForLogin:) name:LOGOUT_NOTIFICATION object:nil];
//    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:AppTokenKey];
//    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:AppTokenSecret];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    [self checkForLogin:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (flag) {
		return NO;
	} else {
		[self.windowController showWindow:nil];
		return YES;
	}
}

- (void)checkForLogin:(NSNotification *)notification
{    
    [self.windowController.window close];
    self.windowController = nil;
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN_KEY];
    NSString *accessTokenSecret = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN_SECRET_KEY];
    if (accessToken && ![accessToken isEqualToString:@""] && accessTokenSecret && ![accessTokenSecret isEqualToString:@""]) {
        [self loginFinished:nil];
    } else {
        QWeiboAsyncApi *api = [[[QWeiboAsyncApi alloc] init] autorelease];
        NSString *retString = [api getRequestTokenWithConsumerKey:APP_KEY consumerSecret:APP_SECRET];
        NSLog(@"Get requestToken:%@", retString);
        
        NSDictionary *params = [NSURL parseURLQueryString:retString];
        [[NSUserDefaults standardUserDefaults] setObject:[params objectForKey:@"oauth_token"] forKey:REQUEST_TOKEN_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:[params objectForKey:@"oauth_token_secret"] forKey:REQUEST_TOKEN_SECRET_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        QWVerifyWindowController *loginWindow = [[QWVerifyWindowController alloc] initWithWindowNibName:@"QWVerifyWindowController"];
        loginWindow.delegate = self;
        [loginWindow showWindow:nil];
    }
}

- (void)dealloc
{
    [_windowController release];
    [[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
	[_statusItem release];
    [super dealloc];
}

#pragma mark - QWVerifyDelegate

- (void)loginFinished:(QWVerifyWindowController *)verifyWindowController
{
    [verifyWindowController.window close];
    [verifyWindowController release];
    QWMainWindowController *controller = [[QWMainWindowController alloc] initWithWindowNibName:@"QWMainWindowController"];
    [controller showWindow:nil];
    self.windowController = controller;
    [controller release];
}

@end
