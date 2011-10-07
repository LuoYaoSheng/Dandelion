//
//  QWTimelineView.m
//  QWeiboClient
//
//  Created by  on 11-9-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "QWTimelineViewController.h"
#import <YAJL/YAJL.h>
#import "QWMessage.h"
#import "MyListViewCell.h"

#define MIN_HEIGHT  70

@interface QWTimelineViewController()

@property (nonatomic, retain) NSMutableArray *heightList;

- (void)reloadData;
- (void)measureData;

@end

@implementation QWTimelineViewController

@synthesize listContent = _listContent;
@synthesize listView = _listView;
@synthesize heightList = _heightList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.listContent = [[[NSMutableArray alloc] init] autorelease];
        self.heightList = [[[NSMutableArray alloc] init] autorelease];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowResized:) name:LISTVIEW_RESIZED_NOTIFICATION object:nil];
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (void)awakeFromNib
{
    self.title = @"Timeline";
    [self.listView setCellSpacing:0.0f];
	[self.listView setAllowsEmptySelection:YES];
	[self.listView setAllowsMultipleSelection:YES];
    [self reloadData];
}

- (void)windowResized:(NSNotification *)notification
{
    [self measureData];
	[self.listView reloadData];
}

- (void)reloadData
{
    [self.listContent removeAllObjects];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"json" ofType:@"txt"];
    NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *json = [jsonString yajl_JSON];
    for (NSDictionary *dict in [json valueForKeyPath:@"data.info"]) {
        QWMessage *message = [[QWMessage alloc] initWithJSON:dict];
//        [self willChangeValueForKey:@"listContent"];
        [self.listContent addObject:message];
//        [self didChangeValueForKey:@"listContent"];
        [message release];
    }
    [self measureData];
	[self.listView reloadData];
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
	return [self.listContent count];
}

- (PXListViewCell*)listView:(PXListView*)aListView cellForRow:(NSUInteger)row
{
    static NSString *LISTVIEW_CELL_IDENTIFIER = @"MyListViewCell";
	MyListViewCell *cell = (MyListViewCell*)[aListView dequeueCellWithReusableIdentifier:LISTVIEW_CELL_IDENTIFIER];
	
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

- (CGFloat)listView:(PXListView*)aListView heightOfRow:(NSUInteger)row
{
    return [[self.heightList objectAtIndex:row] floatValue];
}

- (void)listViewSelectionDidChange:(NSNotification*)aNotification
{
    NSLog(@"Selection changed");
}

- (void)listViewResize:(PXListView *)aListView
{
    [self reloadData];
}

- (void)dealloc
{
    [_listContent release];
    [_heightList release];
    [super dealloc];  
}

@end
