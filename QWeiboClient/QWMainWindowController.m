//
//  QWMainWindow.m
//  QWeiboClient
//
//  Created by  on 11-9-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "QWMainWindowController.h"
#import "AppDelegate.h"
#import "QWeiboSyncApi.h"
#import "QWTimelineViewController.h"
#import "QWMentionsViewController.h"

@interface QWMainWindowController (Private)

@end

@implementation QWMainWindowController

@synthesize currentViewController = _currentViewController;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        allControllers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self homeTappped:nil];
}

- (void)dealloc
{
    [allControllers release];
    [super dealloc];
}

- (NSViewController*)viewControllerForName:(NSString*)name {
    
    // see if this view already exists.
    NSViewController* controller = [allControllers objectForKey:name];
    if ( controller ) return controller;
    
    // create a new instance of the view.
    Class controllerClass = NSClassFromString( name );
    controller = [[controllerClass alloc] initWithNibName:name bundle:nil];
    [allControllers setObject:controller forKey:name];
    [controller release];
    // use key-value coding to avoid compiler warnings.
//    [controller setValue:self forKey:@"mainWindowController"];
    return controller;
}

- (void)activateViewController:(NSViewController*)controller 
{    
    // remove current view.
    [currentViewController.view removeFromSuperview];
    
    // setup new view controller.
    currentViewController = controller;
    [[self.window contentView] addSubview:controller.view];
    
    // adjust for window margin.
    NSWindow* window = self.window;  
    NSRect frame    = [window.contentView frame];
    frame.size.width -= 77;
    frame.size.height -= 21;
    frame.origin.x += 77;
    controller.view.frame = frame;
}

- (IBAction)homeTappped:(id)sender 
{
    NSViewController *viewController = [self viewControllerForName:@"QWTimelineViewController"];
    [self activateViewController:viewController];
}

- (IBAction)metionsTapped:(id)sender 
{
    NSViewController *viewController = [self viewControllerForName:@"QWMentionsViewController"];
    [self activateViewController:viewController];
}

@end
