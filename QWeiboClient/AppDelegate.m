//
//  QWeiboClientAppDelegate.m
//  QWeiboClient
//
//  Created by  on 11-9-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "QWVerifyWindowController.h"
#import <QWeiboSDK/NSURL+QAdditions.h>
#import "QWMainWindowController.h"

@interface AppDelegate (Private)

- (void)checkForLogin:(NSNotification *)notification;
- (void)saveDefaultKey;
- (void)loadDefaultKey;

@end

@implementation AppDelegate

@synthesize windowController = _windowController;
@synthesize mainMenu = _mainMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // status menu
    _statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [_statusItem setImage:[NSImage imageNamed:@"status_on.png"]];
    [_statusItem setAlternateImage:[NSImage imageNamed:@"status_off.png"]];
    [_statusItem setHighlightMode:YES];
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    [menu setAutoenablesItems:NO];
    _logoutMenuItem = [[NSMenuItem alloc] initWithTitle:@"注销" action:@selector(logout:) keyEquivalent:@""];
    [menu addItem:_logoutMenuItem];
    [_logoutMenuItem release];
    [_statusItem setMenu:menu];
    [menu release];
    
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
		return NO;
	}
}

- (IBAction)logout:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ACCESS_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ACCESS_TOKEN_SECRET_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self checkForLogin:nil];
}

- (void)checkForLogin:(NSNotification *)notification
{    
    self.windowController = nil;
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN_KEY];
    NSString *accessTokenSecret = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN_SECRET_KEY];
    if (accessToken && ![accessToken isEqualToString:@""] && accessTokenSecret && ![accessTokenSecret isEqualToString:@""]) {
        [self loginFinished:nil];
    } else {
        [_logoutMenuItem setEnabled:NO];
        QWeiboAsyncApi *api = [[[QWeiboAsyncApi alloc] initWithAppKey:APP_KEY AppSecret:APP_SECRET] autorelease];
        NSString *retString = [api getRequestToken];
        NIF_TRACE(@"Get requestToken:%@", retString);
        
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
    [_logoutMenuItem setEnabled:YES];
    [verifyWindowController.window close];
    [verifyWindowController release];
    QWMainWindowController *controller = [[QWMainWindowController alloc] initWithWindowNibName:@"QWMainWindowController"];
    [controller showWindow:nil];
    self.windowController = controller;
    [controller release];
}

@end
