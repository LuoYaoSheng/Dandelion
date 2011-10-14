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
#import "QWPerson.h"
#import "QWPublishMessageWindowController.h"

@interface QWMainWindowController ()

- (void)activateViewController:(NSViewController*)controller;
- (NSViewController*)viewControllerForName:(NSString*)name tweetType:(TweetType)type;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUpdate:) name:GET_UPDATE_COUNT_NOTIFICATION object:nil];
        self.selectedTweetType = TweetTypeTimeline;
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self updateBadge:nil];

    [api getUserInfo];

    NSViewController *viewController = [self viewControllerForName:@"QWTimelineViewController" tweetType:TweetTypeTimeline];
    [self activateViewController:viewController];
    viewController = [self viewControllerForName:@"QWMentionsViewController" tweetType:TweetTypeMethions];
    [viewController loadView];
    viewController = [self viewControllerForName:@"QWMessagesViewController" tweetType:TweetTypeMessages];
    [viewController loadView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_USER_INFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PUBLISH_MESSAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_UPDATE_COUNT_NOTIFICATION object:nil];

    [allControllers release];
    [api release];
    [super dealloc];
}

- (NSViewController*)viewControllerForName:(NSString*)name tweetType:(TweetType)type
{
    NSViewController* controller = [allControllers objectForKey:name];
    if ( controller ) return controller;
    
    if (type == TweetTypeNone) {
        Class controllerClass = NSClassFromString( name );
        controller = [[controllerClass alloc] initWithNibName:name bundle:nil];
    } else {
        controller = [[QWTweetViewController alloc] initWithNibName:@"QWTweetViewController" bundle:nil tweetType:type];
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
            [self.timelineBadge setHidden:YES];
            NSViewController *viewController = [self viewControllerForName:@"QWTimelineViewController" tweetType:TweetTypeTimeline];
            [self activateViewController:viewController];
            self.selectedTweetType = TweetTypeTimeline;
            break;
        }
        case QWShowTabMethions:
        {
            [self.mentionsBadge setHidden:YES];
            NSViewController *viewController = [self viewControllerForName:@"QWMentionsViewController" tweetType:TweetTypeMethions];
            [self activateViewController:viewController];
            self.selectedTweetType = TweetTypeMethions;
            break;
        }
        case QWShowTabMessages:
        {
            [self.messagesBadge setHidden:YES];
            NSViewController *viewController = [self viewControllerForName:@"QWMessagesViewController" tweetType:TweetTypeMessages];
            [self activateViewController:viewController];
            self.selectedTweetType = TweetTypeMessages;
            break;
        }
        case QWShowTabFavorites:
        {
            NSViewController *viewController = [self viewControllerForName:@"QWFavoritesViewController" tweetType:TweetTypeFavorites];
            [self activateViewController:viewController];
            break;
        }
        case QWShowTabPeople:
        {
//            NSViewController *viewController = [self viewControllerForName:@"QWMentionsViewController"];
//            [self activateViewController:viewController];
            break;
        }
        case QWShowTabSearch:
        {
//            NSViewController *viewController = [self viewControllerForName:@"QWMentionsViewController"];
//            [self activateViewController:viewController];
            break;
        }
        default:
            break;
    }
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

- (IBAction)logout:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ACCESS_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ACCESS_TOKEN_SECRET_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT_NOTIFICATION object:nil];
}

- (void)hasSendMessage:(NSNotification *)notification
{
    NSString *result = notification.object;
    NSLog(@"%@", result);
    NSViewController *viewController = [self viewControllerForName:@"QWTimelineViewController" tweetType:TweetTypeTimeline];
    [self activateViewController:viewController];
    QWTweetViewController *timelineController = (QWTweetViewController *)viewController;
    [timelineController getLastTweets];
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
