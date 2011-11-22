//
//  QWMainWindow.m
//  QWeiboClient
//
//  Created by  on 11-9-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "QWMainWindowController.h"
#import "AppDelegate.h"
#import "QWTweetViewController.h"
#import <QWeiboSDK/QWPerson.h>
#import "QWPublishMessageWindowController.h"

@interface QWMainWindowController ()

- (void)activateViewController:(NSViewController*)controller;
- (NSViewController*)viewControllerForName:(NSString*)name tweetType:(TweetType)type userName:(NSString *)userName;
- (void)switchImageForButton:(NSButton *)button;
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)updateBadge:(NSDictionary *)info;

@end

@implementation QWMainWindowController

@synthesize currentViewController = _currentViewController;
@synthesize statusLabel = _statusLabel;
@synthesize headButton = _headButton;
@synthesize timelineBadge = _timelineBadge;
@synthesize mentionsBadge = _mentionsBadge;
@synthesize messagesBadge = _messagesBadge;
@synthesize selectedTweetType;
@synthesize matrix = _matrix;
@synthesize viewImageController = _viewImageController;

- (QWViewImageWindowController *)viewImageController
{
    if (!_viewImageController) {
        _viewImageController = [[QWViewImageWindowController alloc] initWithWindowNibName:@"QWViewImageWindowController"];
    }
    return _viewImageController;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        allControllers = [[NSMutableDictionary alloc] init];
        selectedTab = 1;
        api = [[QWeiboAsyncApi alloc] initWithAppKey:APP_KEY AppSecret:APP_SECRET];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:GET_USER_INFO_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasSendMessage:) name:PUBLISH_MESSAGE_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUpdate:) name:GET_UPDATE_COUNT_NOTIFICATION object:nil];
        self.selectedTweetType = TweetTypeTimeline;
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // add url schema support
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    [GrowlApplicationBridge setGrowlDelegate:self]; // add Growl support!
    [self updateBadge:nil];

    [api getUserInfo];

    NSViewController *viewController = [self viewControllerForName:@"QWTimelineViewController" tweetType:TweetTypeTimeline userName:nil];
    [self activateViewController:viewController];
    viewController = [self viewControllerForName:@"QWMentionsViewController" tweetType:TweetTypeMethions userName:nil];
    [viewController loadView];
    viewController = [self viewControllerForName:@"QWMessagesViewController" tweetType:TweetTypeMessages userName:nil];
    [viewController loadView];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [NSApp setMainMenu:[[NSApp delegate] mainMenu]];
}



- (void)dealloc
{
    [allControllers release];
    [api release];
    [_viewImageController release];
    [super dealloc];
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSLog(@"%@", url);
    [self toggleTab:QWShowTabPeople withInfo:[NSDictionary dictionaryWithObjectsAndKeys:[url stringByReplacingOccurrencesOfString:@"Dandelion://" withString:@""], @"userName", nil]];
}

#pragma mark - GrowlApplicationBridgeDelegate

- (NSDictionary *)registrationDictionaryForGrowl
{
    NSArray *allNotes = [NSArray arrayWithObjects:GROWL_NOTIFICATION_TIMELINE, GROWL_NOTIFICATION_MENTHIONS, GROWL_NOTIFICATION_MESSAGES, nil];
    return [NSDictionary dictionaryWithObjectsAndKeys:allNotes, GROWL_NOTIFICATIONS_ALL, allNotes, GROWL_NOTIFICATIONS_DEFAULT, nil];
}

- (void)growlNotificationWasClicked:(id)clickContext
{
    [NSApp activateIgnoringOtherApps:YES]; 
    [self showWindow:nil];
    TweetType tweetType = (TweetType)[clickContext intValue];
    switch (tweetType) {
        case TweetTypeTimeline: {
            [self toggleTab:QWShowTabTimeline withInfo:nil];
            break;
        }
        case TweetTypeMethions: {
            [self toggleTab:QWShowTabMethions withInfo:nil];
            break;
        }
        case TweetTypeMessages: {
            [self toggleTab:QWShowTabMessages withInfo:nil];
            break;
        }
        default:
            break;
    }
}

- (IBAction)retweet:(id)sender
{
    QWTweetViewController *tweetViewController = (QWTweetViewController *)currentViewController;
    [tweetViewController retweet];
}
     
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    QWTweetViewController *tweetViewController = (QWTweetViewController *)currentViewController;
    if ([menuItem action] == @selector(retweet:)) 
        return [tweetViewController canRetweet];
    return YES;
}

- (NSViewController*)viewControllerForName:(NSString*)name tweetType:(TweetType)type userName:(NSString *)userName
{
    NSViewController* controller = [allControllers objectForKey:name];
    if (controller) {
        return controller;
    }
    
    if (type == TweetTypeNone) {
        Class controllerClass = NSClassFromString( name );
        controller = [[controllerClass alloc] initWithNibName:name bundle:nil];
    } else {
        controller = [[QWTweetViewController alloc] initWithNibName:@"QWTweetViewController" bundle:nil tweetType:type userName:userName];
        ((QWTweetViewController *)controller).mainWindowController = self;
    }
    [allControllers setObject:controller forKey:name];
    [controller release];

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
    NSRect frame = [window.contentView frame];
    frame.size.width -= 65;
    frame.size.height -= 21;
    frame.origin.x += 65;
    controller.view.frame = frame;
}

- (IBAction)switchButtonClicked:(id)sender
{
    [self toggleTab:(QWShowTab)(((NSButtonCell *)self.matrix.selectedCell).tag) withInfo:nil];
}

- (void)toggleTab:(QWShowTab)tab withInfo:(NSDictionary *)info
{
    [self switchImageForButton:[self.matrix cellWithTag:selectedTab]];
    [self switchImageForButton:[self.matrix cellWithTag:tab]];
    
    NSViewController *viewController;
    switch (tab) {
        case QWShowTabTimeline:
        {
            [self.timelineBadge setHidden:YES];
            viewController = [self viewControllerForName:@"QWTimelineViewController" tweetType:TweetTypeTimeline userName:nil];
            self.selectedTweetType = TweetTypeTimeline;
            break;
        }
        case QWShowTabMethions:
        {
            [self.mentionsBadge setHidden:YES];
            viewController = [self viewControllerForName:@"QWMentionsViewController" tweetType:TweetTypeMethions userName:nil];
            self.selectedTweetType = TweetTypeMethions;
            break;
        }
        case QWShowTabMessages:
        {
            [self.messagesBadge setHidden:YES];
            viewController = [self viewControllerForName:@"QWMessagesViewController" tweetType:TweetTypeMessages userName:nil];
            self.selectedTweetType = TweetTypeMessages;
            break;
        }
        case QWShowTabFavorites:
        {
            viewController = [self viewControllerForName:@"QWFavoritesViewController" tweetType:TweetTypeFavorites userName:nil];
            self.selectedTweetType = TweetTypeMessages;
            break;
        }
        case QWShowTabPeople:
        {
            if (info && [info objectForKey:@"userName"]) {
                 viewController = [self viewControllerForName:@"QWPeopleViewController" tweetType:TweetTypeUserBroadcast userName:[info objectForKey:@"userName"]];
                ((QWTweetViewController *)viewController).tweetType = TweetTypeUserBroadcast;
                ((QWTweetViewController *)viewController).userName = [info objectForKey:@"userName"];
            } else {
                viewController = [self viewControllerForName:@"QWPeopleViewController" tweetType:TweetTypeMyBroadcast userName:nil];
                ((QWTweetViewController *)viewController).tweetType = TweetTypeMyBroadcast;
                ((QWTweetViewController *)viewController).userName = [info objectForKey:@"userName"];
            }
            break;
        }
        case QWShowTabSearch:
        {
            viewController = [self viewControllerForName:@"QWSearchViewController" tweetType:TweetTypeSearch userName:nil];
            self.selectedTweetType = TweetTypeMessages;
            break;
        }
        default:
            break;
    }
    if (viewController)
        [self activateViewController:viewController];
    if (selectedTab == tab) {
        if ([viewController isMemberOfClass:[QWTweetViewController class]]) {
            [(QWTweetViewController *)viewController getLastTweets];
        }
    }
    selectedTab = tab;
}

- (IBAction)publishMessage:(id)sender 
{
    QWPublishMessageWindowController *messageWindowController= [[QWPublishMessageWindowController alloc] initWithWindowNibName:@"QWPublishMessageWindowController"];
    [NSApp beginSheet:messageWindowController.window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)retweetMessage:(QWMessage *)message
{
    QWPublishMessageWindowController *messageWindowController= [[QWPublishMessageWindowController alloc] initWithWindowNibName:@"QWPublishMessageWindowController"];
    messageWindowController.orgMessage = message;
    [NSApp beginSheet:messageWindowController.window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)headButtonClicked:(id)sender 
{
    [self toggleTab:QWShowTabPeople withInfo:[NSDictionary dictionaryWithObjectsAndKeys:nil, @"userName", nil]];   
}

- (IBAction)logout:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.window close];
    [[NSAppleEventManager sharedAppleEventManager] removeEventHandlerForEventClass:kInternetEventClass andEventID:kAEGetURL];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ACCESS_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ACCESS_TOKEN_SECRET_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT_NOTIFICATION object:nil];
}

- (void)hasSendMessage:(NSNotification *)notification
{
    NSString *result = notification.object;
    NSLog(@"%@", result);
    
    [self toggleTab:QWShowTabTimeline withInfo:nil];
    [(QWTweetViewController *)currentViewController getLastTweets];
    
    [api getUserInfo];
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

- (void)receivedUpdate:(NSNotification *)notification
{
    NSLog(@"%@", notification.object);
    [self updateBadge:notification.object];
}

- (void)updateBadge:(NSDictionary *)info
{
    int timelineCount = [[info objectForKey:@"home"] intValue];
    int mentionsCount = [[info objectForKey:@"mentions"] intValue];
    int messagesCount = [[info objectForKey:@"private"] intValue];

    if (timelineCount > 0) {
        [self.timelineBadge setHidden:NO];
        ((QWTweetViewController *)[allControllers objectForKey:@"QWTimelineViewController"]).newTweetCount = timelineCount;
        NSString *timelineDescription = [NSString stringWithFormat:@"%d条新微博", timelineCount];
        [GrowlApplicationBridge notifyWithTitle:timelineDescription description:@"" notificationName:GROWL_NOTIFICATION_TIMELINE iconData:nil priority:0 isSticky:YES clickContext:nil];
    }
    if (mentionsCount > 0) {
        [self.mentionsBadge setHidden:NO];
        ((QWTweetViewController *)[allControllers objectForKey:@"QWMentionsViewController"]).newTweetCount = mentionsCount;
        NSString *mentionsDescription = [NSString stringWithFormat:@"%d条新引用", mentionsCount];
        [GrowlApplicationBridge notifyWithTitle:mentionsDescription description:@"" notificationName:GROWL_NOTIFICATION_MENTHIONS iconData:nil priority:0 isSticky:YES clickContext:nil];
    }
    if (messagesCount > 0) {
        [self.messagesBadge setHidden:NO];
        ((QWTweetViewController *)[allControllers objectForKey:@"QWMessagesViewController"]).newTweetCount = messagesCount;
        NSString *messagesDescription = [NSString stringWithFormat:@"%d条新私信", messagesCount];
        [GrowlApplicationBridge notifyWithTitle:messagesDescription description:@"" notificationName:GROWL_NOTIFICATION_MESSAGES iconData:nil priority:0 isSticky:YES clickContext:nil];
    }
}

@end
