//
//  QWTimelineView.m
//  QWeiboClient
//
//  Created by  on 11-9-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "QWFavoritesViewController.h"
#import <YAJL/YAJL.h>
#import "QWMessage.h"
#import "MyListViewCell.h"
#import "ListViewEndCell.h"

#define MIN_HEIGHT  70

@interface QWFavoritesViewController()

@property (nonatomic, retain) NSMutableArray *heightList;
@property (nonatomic, retain) ListViewEndCell *reloadCell;

- (void)measureData;
- (void)reloadTable:(BOOL)scrollToTop;

@end

@implementation QWFavoritesViewController

@synthesize listContent = _listContent;
@synthesize listView = _listView;
@synthesize heightList = _heightList;
@synthesize reloadCell = _reloadCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.listContent = [[[NSMutableArray alloc] init] autorelease];
        self.heightList = [[[NSMutableArray alloc] init] autorelease];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowResized:) name:LISTVIEW_RESIZED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedHomeMessage:) name:GET_TIMELINE_NOTIFICATION object:nil];
        api = [[QWeiboAsyncApi alloc] init];
        
        hasNext = YES;
        pageFlag = 0;
        pageSize = 20;
        pageTime = 0;
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (void)awakeFromNib
{
    self.title = @"Favorites";
    [self.listView setCellSpacing:0.0f];
	[self.listView setAllowsEmptySelection:YES];
	[self.listView setAllowsMultipleSelection:YES];
//    [self reloadData:YES];
}

- (void)windowResized:(NSNotification *)notification
{
    [self reloadTable:NO];
}

- (void)reloadData:(BOOL)reset
{
    if (reset) {
        pageFlag = 0;
        pageTime = 0;
    }
    [api getHomeMessageWithPageFlag:pageFlag pageSize:pageSize pageTime:pageTime];
}

- (void)receivedHomeMessage:(NSNotification *)notification
{
    BOOL reset = NO;
    if (pageTime == 0) {
        [self.listContent removeAllObjects];
        reset = YES;
    }
    NSArray *messages = (NSArray *)notification.object;
    [self.listContent addObjectsFromArray:messages];
    pageTime = ((QWMessage *)[messages lastObject]).timestamp;
    hasNext = ![[notification.userInfo objectForKey:@"hasNext"] boolValue];
    if (hasNext)
        pageFlag = 1;
    [self reloadTable:reset];
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
            [self reloadData:NO];
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
        cell.nameLabel.stringValue = message.nick;
        cell.headButton.image = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:message.head]] autorelease];
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
    [super dealloc];  
}

@end
