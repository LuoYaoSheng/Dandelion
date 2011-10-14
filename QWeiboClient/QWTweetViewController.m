//
//  QWTimelineView.m
//  QWeiboClient
//
//  Created by  on 11-9-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "QWTweetViewController.h"
#import <YAJL/YAJL.h>
#import "QWMessage.h"
#import "MyListViewCell.h"
#import "ListViewEndCell.h"
#import <Growl/Growl.h>

#define MIN_HEIGHT  70

@interface QWTweetViewController()

@property (nonatomic, retain) NSMutableArray *heightList;
@property (nonatomic, retain) ListViewEndCell *reloadCell;

- (void)measureData;
- (void)reloadTable:(BOOL)scrollToTop;
- (void)fetchOlderTweets;
- (void)beginUpdating;
- (void)stopUpdating;

@end

@implementation QWTweetViewController

@synthesize listContent = _listContent;
@synthesize listView = _listView;
@synthesize heightList = _heightList;
@synthesize reloadCell = _reloadCell;
@synthesize mainWindowController = _mainWindowController;
@synthesize newTweetCount = _newTweetCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tweetType:(TweetType)type
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.newTweetCount = 0;
        tweetType = type;
        self.listContent = [[[NSMutableArray alloc] init] autorelease];
        self.heightList = [[[NSMutableArray alloc] init] autorelease];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowResized:) name:LISTVIEW_RESIZED_NOTIFICATION object:nil];
        api = [[QWeiboAsyncApi alloc] init];
        api.delegate = self;
        
        hasNext = YES;
        oldestPageTime = 0;
        newestPageTime = 0;
        isLoading = NO;
        
        [self getLastTweets];
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (void)awakeFromNib
{
    switch (tweetType) {
        case TweetTypeTimeline: {
            self.title = @"Timeline";
            break;
        }
        case TweetTypeMethions: {
            self.title = @"Methions";
            break;
        }
        case TweetTypeMessages: {
            self.title = @"Messages";
            break;
        }
        case TweetTypeFavorites: {
            self.title = @"Favorites";
            break;
        }
        default:
            break;
    }
    [self.listView setCellSpacing:0.0f];
	[self.listView setAllowsEmptySelection:YES];
	[self.listView setAllowsMultipleSelection:YES];
}

- (void)windowResized:(NSNotification *)notification
{
    [self reloadTable:NO];
}

- (void)getLastTweets
{
    isLoading = YES;
    [api getLastTweetsWithTweetType:tweetType pageSize:20];
}

- (void)fetchOlderTweets
{
    isLoading = YES;
    [api getOlderTweetsWithTweetType:tweetType pageSize:20 pageTime:oldestPageTime];
}

- (void)fetchNewerTweets
{
    [api getNewerTweetsWithTweetType:tweetType pageSize:10 pageTime:newestPageTime];
}

- (void)beginUpdating
{
    NSTimeInterval interval;
    switch (tweetType) {
        case TweetTypeTimeline: {
            interval = UPDATE_INTERVAL_TIMELINE;
            break;
        }
        case TweetTypeMethions: {
            interval = UPDATE_INTERVAL_MENTHIONS;
            break;
        }
        case TweetTypeMessages: {
            interval = UPDATE_INTERVAL_MESSAGES;
            break;
        }
        case TweetTypeFavorites: {
            interval = UPDATE_INTERVAL_FAVORITES;
            break;
        }
        default:
            break;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(fetchNewerTweets) userInfo:nil repeats:YES];
}

- (void)stopUpdating
{
    [timer invalidate];
}

#pragma mark - QWeiboAsyncApiDelegate

- (void)receivedLastTweets:(NSArray *)tweets info:(NSDictionary *)info
{
    isLoading = NO;
    [self.listContent removeAllObjects];
    [self.listContent addObjectsFromArray:tweets];
    oldestPageTime = ((QWMessage *)[tweets lastObject]).timestamp;
    if (tweets.count > 0)
        newestPageTime = ((QWMessage *)[tweets objectAtIndex:0]).timestamp;
    hasNext = ![[info objectForKey:@"hasNext"] boolValue];
    [self reloadTable:YES];
    //[self beginUpdating];
}

- (void)receivedOlderTweets:(NSArray *)tweets info:(NSDictionary *)info
{
    isLoading = NO;
    [self.listContent addObjectsFromArray:tweets];
    oldestPageTime = ((QWMessage *)[tweets lastObject]).timestamp;
    hasNext = ![[info objectForKey:@"hasNext"] boolValue];
    [self reloadTable:NO];
}

- (void)receivedNewerTweets:(NSArray *)tweets
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tweets.count)];
    [self.listContent insertObjects:tweets atIndexes:indexSet];
    if (tweets.count > 0) {
        newestPageTime = ((QWMessage *)[tweets objectAtIndex:0]).timestamp;
        for (QWMessage *message in tweets) {
            switch (tweetType) {
                case TweetTypeTimeline: {
                    [GrowlApplicationBridge notifyWithTitle:message.nick description:message.text notificationName:GROWL_NOTIFICATION_TIMELINE iconData:[NSData dataWithContentsOfURL:[NSURL URLWithString:message.head]] priority:0 isSticky:NO clickContext:nil];
                    if (tweetType != self.mainWindowController.selectedTweetType)
                        [self.mainWindowController.timelineBadge setHidden:NO];
                    break;
                }
                case TweetTypeMethions: {
                    [GrowlApplicationBridge notifyWithTitle:message.nick description:message.text notificationName:GROWL_NOTIFICATION_MENTHIONS iconData:[NSData dataWithContentsOfURL:[NSURL URLWithString:message.head]] priority:0 isSticky:NO clickContext:nil];
                    if (tweetType != self.mainWindowController.selectedTweetType)
                        [self.mainWindowController.timelineBadge setHidden:NO];
                    break;
                }
                case TweetTypeMessages: {
                    [GrowlApplicationBridge notifyWithTitle:message.nick description:message.text notificationName:GROWL_NOTIFICATION_MESSAGES iconData:[NSData dataWithContentsOfURL:[NSURL URLWithString:message.head]] priority:0 isSticky:NO clickContext:nil];
                    if (tweetType != self.mainWindowController.selectedTweetType)
                        [self.mainWindowController.timelineBadge setHidden:NO];
                    break;
                }
                default:
                    break;
            }
        }
        [self reloadTable:YES];
//        [NSApp setApplicationIconImage:[NSImage imageNamed:@"weibo_badge.icns"]];
    }
}

- (void)reloadTable:(BOOL)scrollToTop
{
    [self measureData];
	[self.listView reloadData];
    if (scrollToTop)
        [self.listView scrollToTop];
}

- (void)measureData
{
    [self.heightList removeAllObjects];
    for (QWMessage *message in self.listContent) {
        CGFloat width = self.listView.contentView.frame.size.width;
        NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, width-60-15, 1000)];
        textField.font = [NSFont systemFontOfSize:12];
        textField.stringValue = message.text;
        NSSize size = [textField.cell cellSizeForBounds:textField.frame];
        [textField release];
        [self.heightList addObject:[NSNumber numberWithFloat:size.height]];
    }
}

#pragma mark - List View Delegate Methods

- (NSUInteger)numberOfRowsInListView: (PXListView*)aListView
{
	return [self.listContent count] + 1;
}

- (PXListViewCell*)listView:(PXListView*)aListView cellForRow:(NSUInteger)row
{
    if (row == [self.listContent count]) {
        static NSString *LISTVIEW_CELL_IDENTIFIER = @"ListViewEndCell";
        ListViewEndCell *cell = (ListViewEndCell *)[aListView dequeueCellWithReusableIdentifier:LISTVIEW_CELL_IDENTIFIER];
        if(!cell) {
            cell = [ListViewEndCell cellLoadedFromNibNamed:@"ListViewEndCell" reusableIdentifier:LISTVIEW_CELL_IDENTIFIER];
        }
        self.reloadCell = [cell retain];
        if (hasNext) {
            if (!isLoading) {
                [self.reloadCell startAnimating];
                [self performSelector:@selector(fetchOlderTweets) withObject:nil afterDelay:1];
            }
        } else {
            [self.reloadCell stopAnimating];
        }
        return cell;
    } else {
        static NSString *LISTVIEW_CELL_IDENTIFIER = @"MyListViewCell";
        MyListViewCell *cell = (MyListViewCell *)[aListView dequeueCellWithReusableIdentifier:LISTVIEW_CELL_IDENTIFIER];
        if(!cell) {
            cell = [MyListViewCell cellLoadedFromNibNamed:@"MyListViewCell" reusableIdentifier:LISTVIEW_CELL_IDENTIFIER];
        }
        
        // Set up the new cell:
        CGRect textLabelFrame = cell.textLabel.frame;
        float diffHeight = [[self.heightList objectAtIndex:row] floatValue] - textLabelFrame.size.height;
        textLabelFrame.size.height += diffHeight;
        textLabelFrame.origin.y -= diffHeight;
        cell.textLabel.frame = textLabelFrame;
        
//        CGRect imageViewFrame = cell.imageView.frame;
//        imageViewFrame.origin.y = CGRectGetMinY(cell.textLabel.frame);
//        cell.imageView.frame = imageViewFrame;
        
        QWMessage *message = [self.listContent objectAtIndex:row];
        cell.isNew = message.isNew;
        cell.nameLabel.stringValue = message.nick;
        if (message.head && ![message.head isEqualToString:@""])
            cell.headButton.image = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:message.head]] autorelease];
        else
            cell.headButton.image = [NSImage imageNamed:@"NSUser"];
        cell.textLabel.stringValue = message.text;
        cell.timeLabel.stringValue = message.time;
        cell.imageView.image = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:message.image]] autorelease];
        
        return cell;
	}
}

- (CGFloat)listView:(PXListView*)aListView heightOfRow:(NSUInteger)row
{
    if (row == [self.listContent count]) 
        return 40;
    else {
        float height = [[self.heightList objectAtIndex:row] floatValue] + 24;
        QWMessage *message = [self.listContent objectAtIndex:row];
        if (![message.image isEqualToString:@""])
            height += 145;
        if (height < MIN_HEIGHT)
            height = MIN_HEIGHT;
        return height;
    }
}

- (void)listViewSelectionDidChange:(NSNotification*)aNotification
{
    NSLog(@"Selection changed");
}

- (void)listView:(PXListView *)aListView retweetForRow:(NSUInteger)rowIndex
{
    [self.mainWindowController retweetMessage:[self.listContent objectAtIndex:rowIndex]];
}

- (void)listView:(PXListView *)aListView addFavoriteForRow:(NSUInteger)rowIndex
{
    
}

- (void)listViewResize:(PXListView *)aListView
{
    [self reloadTable:NO];
}

- (void)dealloc
{
    [self stopUpdating];
    [_listContent release];
    [_heightList release];
    [_reloadCell release];
    [api release];
    [super dealloc];  
}

@end
