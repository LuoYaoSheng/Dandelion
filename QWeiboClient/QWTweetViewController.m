//
//  QWTimelineView.m
//  QWeiboClient
//
//  Created by  on 11-9-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "QWTweetViewController.h"
//#import <YAJL/YAJL.h>
#import <QWeiboSDK/QWMessage.h>
#import "MyListViewCell.h"
#import "ListViewEndCell.h"
#import <Growl/Growl.h>
#import "QWViewImageWindowController.h"
#import "NS(Attributed)String+Geometrics.h"

#define MIN_HEIGHT  70

@interface QWTweetViewController()

@property (nonatomic, retain) NSMutableArray *heightList;
@property (nonatomic, retain) ListViewEndCell *reloadCell;

- (void)measureData;
- (void)reloadTable:(BOOL)scrollToTop;
- (void)fetchOlderTweets;
- (void)beginUpdating;
- (void)stopUpdating;
- (void)dealWithNewTweets:(NSArray *)tweets;

@end

@implementation QWTweetViewController

@synthesize listContent = _listContent;
@synthesize listView = _listView;
@synthesize heightList = _heightList;
@synthesize reloadCell = _reloadCell;
@synthesize mainWindowController = _mainWindowController;
@synthesize userName = _userName;
@synthesize tweetType = _tweetType;
@synthesize newTweetCount = _newTweetCount;
@synthesize lastId = _lastId;

- (NSString *)userName
{
    return _userName;
}

- (void)setUserName:(NSString *)userName
{
    if (!((!userName && !_userName) || (userName && _userName && [userName isEqualToString:_userName]))) { 
        [_userName release];
        _userName = [userName copy];
        [self getLastTweets];
    }
}

- (void)setNewTweetCount:(int)newTweetCount
{
    _newTweetCount = newTweetCount;
    // post new tweet change
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_NEWTWEET_NOTIFICATION object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tweetType:(TweetType)type userName:(NSString *)userName
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.tweetType = type;
        self.listContent = [[[NSMutableArray alloc] init] autorelease];
        self.heightList = [[[NSMutableArray alloc] init] autorelease];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowResized:) name:LISTVIEW_RESIZED_NOTIFICATION object:nil];
        api = [[QWeiboAsyncApi alloc] init];
        api.delegate = self;
        api.tweetType = self.tweetType;
        _userName = [userName copy];

        hasNext = YES;
        oldestPageTime = 0;
        newestPageTime = 0;
        _lastId = @"0";
        isLoading = NO;
        pos = 0;
        _newTweetCount = 0;
        
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
    [super awakeFromNib];
    [self.listView setCellSpacing:0.0f];
	[self.listView setAllowsEmptySelection:YES];
	[self.listView setAllowsMultipleSelection:YES];
}

- (void)windowResized:(NSNotification *)notification
{
    [self reloadTable:NO];
}

- (void)getUserInfo
{
    
}

- (void)getLastTweets
{
    switch (self.tweetType) {
        case TweetTypeTimeline: {
            self.title = @"主页";
            break;
        }
        case TweetTypeMethions: {
            self.title = @"提到我的";
            break;
        }
        case TweetTypeMessages: {
            self.title = @"私信";
            break;
        }
        case TweetTypeFavorites: {
            self.title = @"收藏";
            break;
        }
        case TweetTypeMyBroadcast: {
            self.title = @"我";
            break;
        }
        case TweetTypeUserBroadcast: {
            self.title = self.userName;
            break;
        }
        case TweetTypeSearch: {
            self.title = @"广播大厅";
            break;
        }
        default:
            self.title = @"";
            break;
    }
    self.newTweetCount = 0;
    isLoading = YES;
    if (self.tweetType == TweetTypeSearch) {
        pos = 0;
        [api getPublicTimelineWithPos:pos pageSize:20];
    }
    else
        [api getLastTweetsWithPageSize:20 userName:self.userName];
}

- (void)fetchOlderTweets
{
    isLoading = YES;
    if (self.tweetType == TweetTypeSearch)
        [api getPublicTimelineWithPos:pos pageSize:20];
    else
        [api getOlderTweetsWithPageSize:20 pageTime:oldestPageTime userName:self.userName];
}

- (void)fetchNewerTweets
{
    [api getNewerTweetsWithPageSize:10 pageTime:newestPageTime lastId:self.lastId userName:self.userName];
}

- (void)beginUpdating
{
    if (timer) {
        [timer invalidate];
    }
    NSTimeInterval interval;
    switch (self.tweetType) {
        case TweetTypeTimeline:
        {
            interval = UPDATE_INTERVAL_TIMELINE;
            timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(fetchNewerTweets) userInfo:nil repeats:YES];
            break;
        }
        case TweetTypeMethions: {
            interval = UPDATE_INTERVAL_MENTHIONS;
            timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(fetchNewerTweets) userInfo:nil repeats:YES];
            break;
        }
        case TweetTypeMessages: {
            interval = UPDATE_INTERVAL_MESSAGES;
            timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(fetchNewerTweets) userInfo:nil repeats:YES];
            break;
        }
        default:
            break;
    }
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
    if (tweets.count > 0) {
        QWMessage *lastMessage = (QWMessage *)[tweets objectAtIndex:0];
        newestPageTime = lastMessage.timestamp;
        self.lastId = lastMessage.tweetId;
    }
    hasNext = ![[info objectForKey:@"hasNext"] boolValue];
//    pos = [[info objectForKey:@"pos"] intValue];
    pos += 20;
    
    NSMutableArray *newTweets = [NSMutableArray array];
    for (QWMessage *message in tweets) {
        if (message.isNew)
            [newTweets addObject:message];
    }
    [self dealWithNewTweets:newTweets];
    
    [self reloadTable:YES];
    [self beginUpdating];
}

- (void)receivedOlderTweets:(NSArray *)tweets info:(NSDictionary *)info
{
    isLoading = NO;
    [self.listContent addObjectsFromArray:tweets];
    oldestPageTime = ((QWMessage *)[tweets lastObject]).timestamp;
    hasNext = ![[info objectForKey:@"hasNext"] boolValue];
//    pos = [[info objectForKey:@"pos"] intValue];
    pos += 20;
    [self reloadTable:NO];
}

- (void)receivedNewerTweets:(NSArray *)tweets
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tweets.count)];
    [self.listContent insertObjects:tweets atIndexes:indexSet];
    
    [self dealWithNewTweets:tweets];
    if (tweets.count > 0) {
        QWMessage *lastMessage = (QWMessage *)[tweets objectAtIndex:0];
        newestPageTime = lastMessage.timestamp;
        self.lastId = lastMessage.tweetId;
        [self reloadTable:YES];
    }
}

- (void)dealWithNewTweets:(NSArray *)tweets
{
    self.newTweetCount += tweets.count;
    if (tweets.count > 10) {
        [GrowlApplicationBridge notifyWithTitle:nil description:[NSString stringWithFormat:@"%d条新消息", tweets.count] notificationName:GROWL_NOTIFICATION_TIMELINE iconData:nil priority:0 isSticky:NO clickContext:[NSNumber numberWithInt:self.tweetType]];
    } else {
        for (QWMessage *message in tweets) {
            switch (self.tweetType) {
                case TweetTypeTimeline: {
                    [GrowlApplicationBridge notifyWithTitle:message.nick description:message.text notificationName:GROWL_NOTIFICATION_TIMELINE iconData:[NSData dataWithContentsOfURL:[NSURL URLWithString:message.head]] priority:0 isSticky:NO clickContext:[NSNumber numberWithInt:self.tweetType]];
                    break;
                }
                case TweetTypeMethions: {
                    if (message.type == QWMessageTypeDialog) { //Retweet will be shown in timeline also, needn't growl it
                        [GrowlApplicationBridge notifyWithTitle:message.nick description:message.text notificationName:GROWL_NOTIFICATION_MENTHIONS iconData:[NSData dataWithContentsOfURL:[NSURL URLWithString:message.head]] priority:0 isSticky:NO clickContext:[NSNumber numberWithInt:self.tweetType]];
                    }
                    break;
                }
                case TweetTypeMessages: {
                    [GrowlApplicationBridge notifyWithTitle:message.nick description:message.text notificationName:GROWL_NOTIFICATION_MESSAGES iconData:[NSData dataWithContentsOfURL:[NSURL URLWithString:message.head]] priority:0 isSticky:NO clickContext:[NSNumber numberWithInt:self.tweetType]];
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)addedFavorite
{
    
}

- (void)deletedFavorite
{
    
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
        [self.heightList addObject:[NSNumber numberWithFloat:[message.richText heightForWidth:width-61-15]]];
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
        CGRect textLabelFrame = cell.scrollView.frame;
        float diffHeight = [[self.heightList objectAtIndex:row] floatValue] - textLabelFrame.size.height;
        textLabelFrame.size.height += diffHeight;
        textLabelFrame.origin.y -= diffHeight;
        cell.scrollView.frame = textLabelFrame;
//        cell.progessIndicator.frame = NSMakeRect(CGRectGetMidX(cell.imageButton.frame), CGRectGetMidY(cell.imageButton.frame), 16, 16);
        
//        CGRect imageViewFrame = cell.imageView.frame;
//        imageViewFrame.origin.y = CGRectGetMinY(cell.textLabel.frame);
//        cell.imageView.frame = imageViewFrame;
        
        QWMessage *message = [self.listContent objectAtIndex:row];
        cell.isNew = message.isNew;
        cell.nameLabel.stringValue = message.nick;
        if (message.head && ![message.head isEqualToString:@""])
            cell.headButton.image = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:message.head]] autorelease];
        else
            cell.headButton.image = [NSImage imageNamed:@"head.jpg"];
        [cell.textLabel setLinkTextAttributes:nil];
        [cell.textLabel.textStorage setAttributedString:message.richText];
        cell.timeLabel.stringValue = message.time;
        if (message.thumbnailImageURL && ![message.thumbnailImageURL isEqualToString:@""]) {
            [cell.imageButton setHidden:NO];
//            cell.imageButton.image = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:message.thumbnailImageURL]] autorelease];
            [cell loadImageForMessage:message];
        }
        else 
            [cell.imageButton setHidden:YES];
        
        return cell;
	}
}

- (CGFloat)listView:(PXListView*)aListView heightOfRow:(NSUInteger)row
{
    if (row == [self.listContent count]) 
        return 40;
    else {
        float height = [[self.heightList objectAtIndex:row] floatValue] + 35;
        QWMessage *message = [self.listContent objectAtIndex:row];
        if (![message.thumbnailImageURL isEqualToString:@""])
            height += 145;
        if (height < MIN_HEIGHT)
            height = MIN_HEIGHT;
        return height;
    }
}

- (void)listViewSelectionDidChange:(NSNotification*)aNotification
{
    NIF_TRACE(@"Selection changed");
    QWMessage *message = [self.listContent objectAtIndex:self.listView.selectedRow];
    NIF_TRACE(@"%@", message);
    
}

- (void)retweet
{
    if (self.listView.selectedRow != NSUIntegerMax)
        [self listView:self.listView retweetForRow:self.listView.selectedRow];
}

- (BOOL)canRetweet
{
    return self.listView.selectedRow != NSUIntegerMax;
}

- (void)listView:(PXListView *)aListView retweetForRow:(NSUInteger)rowIndex
{
    [self.mainWindowController retweetMessage:[self.listContent objectAtIndex:rowIndex]];
}

- (void)listView:(PXListView *)aListView addFavoriteForRow:(NSUInteger)rowIndex
{
    QWMessage *message = [self.listContent objectAtIndex:rowIndex];
    if (self.tweetType == TweetTypeFavorites) {
        [api deleteFavorite:message.tweetId];
        [self.listContent removeObject:message];
        [self reloadTable:NO];
    } else {
        [api addFavorite:message.tweetId];
    }
}

- (void)listView:(PXListView *)aListView imageClickedForRow:(NSUInteger)rowIndex
{
    QWMessage *message = [self.listContent objectAtIndex:rowIndex];
    [self.mainWindowController.viewImageController showWindow:nil];
    [self.mainWindowController.viewImageController loadImageForMessage:message];
}

- (void)listView:(PXListView *)aListView headClickedForRow:(NSUInteger)rowIndex
{
    QWMessage *message = [self.listContent objectAtIndex:rowIndex];
    [self.mainWindowController toggleTab:QWShowTabPeople withInfo:[NSDictionary dictionaryWithObjectsAndKeys:message.name, @"userName", nil] refresh:YES];
}

- (void)listView:(PXListView *)aListView mouseMoved:(NSUInteger)rowIndex
{
    if (((QWMessage *)[self.listContent objectAtIndex:rowIndex]).isNew) {
        ((QWMessage *)[self.listContent objectAtIndex:rowIndex]).isNew = NO;
        self.newTweetCount--;
    }
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
    [_userName release];
    [_lastId release];
    [super dealloc];  
}

@end
