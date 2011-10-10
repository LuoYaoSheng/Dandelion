//
//  QWTimelineView.h
//  QWeiboClient
//
//  Created by  on 11-9-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXListView.h"
#import "QWeiboAsyncApi.h"
#import "ListViewEndCell.h"

@interface QWMentionsViewController : NSViewController<PXListViewDelegate> {
    QWeiboAsyncApi *api;
    BOOL hasNext;
    int pageFlag;
    int pageSize;
    double pageTime;
    BOOL isLoading;
}


@property (nonatomic, retain) NSMutableArray *listContent;
@property (assign) IBOutlet PXListView *listView;

- (void)reloadData:(BOOL)reset;

@end
