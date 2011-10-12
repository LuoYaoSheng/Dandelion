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

#define MIN_HEIGHT  70

@interface QWTweetViewController()

@property (nonatomic, retain) NSMutableArray *heightList;
@property (nonatomic, retain) ListViewEndCell *reloadCell;

- (void)measureData;
- (void)reloadTable:(BOOL)scrollToTop;

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
        pageFlag = 0;
        pageSize = 20;
        pageTime = 0;
        isLoading = NO;
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
    [self reloadTable:NO];
}

- (void)windowResized:(NSNotification *)notification
{
    [self reloadTable:NO];
}

- (void)reloadData:(BOOL)reset
{
    if (reset || !isLoading) {
        isLoading = YES;
        if (reset) {
            pageFlag = 0;
            pageTime = 0;
        }
        [api getTweetsWithTweetType:tweetType pageFlag:pageFlag pageSize:pageSize pageTime:pageTime new:NO];
    }
}

- (void)fetchNewTweets
{
    if (self.newTweetCount > 0) {
        [api getNewTweetsWithTweetType:tweetType newTweetsCount:self.newTweetCount];
        self.newTweetCount = 0;
    }
}

#pragma mark - QWeiboAsyncApiDelegate

- (void)receivedTweets:(NSArray *)tweets info:(NSDictionary *)info
{
    isLoading = NO;
    BOOL reset = NO; // reset mean set scollbar to top
    if (pageTime == 0) {
        [self.listContent removeAllObjects];
        reset = YES;
    }
    [self.listContent addObjectsFromArray:tweets];
    pageTime = ((QWMessage *)[tweets lastObject]).timestamp;
    hasNext = ![[info objectForKey:@"hasNext"] boolValue];
    if (hasNext)
        pageFlag = 1;
    [self reloadTable:reset];
}

- (void)receivedNewTweets:(NSArray *)tweets
{
//    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tweets.count)];
//    [self.listContent insertObjects:tweets atIndexes:indexSet];
    if (tweets.count > 0) {
        for (int i=(int)(tweets.count-1); i>-1; i--) {
            QWMessage *message = [tweets objectAtIndex:i];
            BOOL exists = NO;
            for (QWMessage *existMessage in self.listContent) {
                if ([existMessage.tweetId isEqualToString:message.tweetId]) {
                    exists = YES;
                    break;
                }
            }
            if (!exists)
                [self.listContent insertObject:message atIndex:0];
        }
    }
    [self reloadTable:YES];
//    switch (tweetType) {
//        case TweetTypeTimeline: {
//            [self.mainWindowController.timelineBadge setHidden:YES];
//            break;
//        }
//        case TweetTypeMethions: {
//            [self.mainWindowController.mentionsBadge setHidden:YES];
//            break;
//        }
//        case TweetTypeMessages: {
//            [self.mainWindowController.messagesBadge setHidden:YES];
//            break;
//        }
//        default:
//            break;
//    }
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
        float height = (size.height+24)<MIN_HEIGHT ? MIN_HEIGHT : (size.height+24);
        [self.heightList addObject:[NSNumber numberWithFloat:height]];
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
            [self.reloadCell startAnimating];
            [self performSelector:@selector(reloadData:) withObject:nil afterDelay:1];
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
        QWMessage *message = [self.listContent objectAtIndex:row];
        cell.isNew = message.isNew;
        cell.nameLabel.stringValue = message.nick;
        if (message.head && ![message.head isEqualToString:@""])
            cell.headButton.image = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:message.head]] autorelease];
        else
            cell.headButton.image = [NSImage imageNamed:@"NSUser"];
        cell.textLabel.stringValue = message.text;
        cell.timeLabel.stringValue = message.time;
        
        return cell;
	}
}

- (CGFloat)listView:(PXListView*)aListView heightOfRow:(NSUInteger)row
{
    if (row == [self.listContent count]) 
        return 40;
    else
        return [[self.heightList objectAtIndex:row] floatValue];
}

- (void)listViewSelectionDidChange:(NSNotification*)aNotification
{
    NSLog(@"Selection changed");
}

- (void)listViewResize:(PXListView *)aListView
{
    [self reloadTable:NO];
}

- (void)dealloc
{
    [_listContent release];
    [_heightList release];
    [_reloadCell release];
    [api release];
    [super dealloc];  
}

@end
