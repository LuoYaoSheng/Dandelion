//
//  QWMainWindow.m
//  QWeiboClient
//
//  Created by  on 11-9-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "QWMainWindowController.h"
#import "AppDelegate.h"
#import "QWTimelineViewController.h"
#import "QWMentionsViewController.h"
#import "QWPerson.h"
#import "QWPublishMessageWindowController.h"

@interface QWMainWindowController ()

- (void)activateViewController:(NSViewController*)controller;
- (NSViewController*)viewControllerForName:(NSString*)name;
- (void)switchImageForButton:(NSButton *)button;
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end

@implementation QWMainWindowController

@synthesize currentViewController = _currentViewController;
@synthesize statusLabel = _statusLabel;
@synthesize headButton = _headButton;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        allControllers = [[NSMutableDictionary alloc] init];
        selectedIndex = 1;
        api = [[QWeiboAsyncApi alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:GET_USER_INFO_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasSendMessage:) name:PUBLISH_MESSAGE_NOTIFICATION object:nil];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [api getUserInfo];

    NSViewController *viewController = [self viewControllerForName:@"QWTimelineViewController"];
    [self activateViewController:viewController];
}

- (void)dealloc
{
    [allControllers release];
    [api release];
    [super dealloc];
}

- (NSViewController*)viewControllerForName:(NSString*)name
{
    
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
    self.window.title = controller.title;
    
    // adjust for window margin.
    NSWindow* window = self.window;  
    NSRect frame    = [window.contentView frame];
    frame.size.width -= 65;
    frame.size.height -= 21;
    frame.origin.x += 65;
    controller.view.frame = frame;
}

- (IBAction)toggleTab:(id)sender 
{
    NSMatrix *matrix = (NSMatrix *)sender;
    NSButton *button = (NSButton *)matrix.selectedCell;
    [self switchImageForButton:button];
    [self switchImageForButton:[matrix cellWithTag:selectedIndex]];
    selectedIndex = button.tag;
    switch (selectedIndex) {
        case QWShowTabTimeline:
        {
            NSViewController *viewController = [self viewControllerForName:@"QWTimelineViewController"];
            [self activateViewController:viewController];
            break;
        }
        case QWShowTabMethions:
        {
            NSViewController *viewController = [self viewControllerForName:@"QWMentionsViewController"];
            [self activateViewController:viewController];
            break;
        }
        case QWShowTabMessages:
        {
            break;
        }
        case QWShowTabFavorite:
            break;
        case QWShowTabPeople:
            break;
        case QWShowTabSearch:
            break;
        default:
            break;
    }
}

- (IBAction)publishMessage:(id)sender {
    QWPublishMessageWindowController *messageWindowController= [[QWPublishMessageWindowController alloc] initWithWindowNibName:@"QWPublishMessageWindowController"];
    [NSApp beginSheet:messageWindowController.window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)hasSendMessage:(NSNotification *)notification
{
    NSString *result = notification.object;
    NSLog(@"%@", result);
    NSViewController *viewController = [self viewControllerForName:@"QWTimelineViewController"];
    [self activateViewController:viewController];
    QWTimelineViewController *timelineController = (QWTimelineViewController *)viewController;
    [timelineController reloadData:YES];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (void)switchImageForButton:(NSButton *)button
{
    NSImage *image = [button.image retain];
    button.image = button.alternateImage;
    button.alternateImage = image;
    [image release];
}

- (void)updateUserInfo:(NSNotification *)notification
{
    QWPerson *person = (QWPerson *)notification.object;
    self.statusLabel.stringValue = [NSString stringWithFormat:@"关注:%d 粉丝:%d 微博:%d", person.idolNum, person.fansNum, person.tweetNum];
    self.headButton.image = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:person.head]] autorelease];
}

@end
