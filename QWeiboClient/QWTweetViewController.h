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

typedef enum {
    TweetTypeNone = 0,
    TweetTypeTimeline,
    TweetTypeMethions,
    TweetTypeMessages,
    TweetTypeFavorites,
} TweetType;

@interface QWTweetViewController : NSViewController<PXListViewDelegate> {
    QWeiboAsyncApi *api;
    BOOL hasNext;
    int pageFlag;
    int pageSize;
    double pageTime;
    BOOL isLoading;
    TweetType tweetType;
}


@property (nonatomic, retain) NSMutableArray *listContent;
@property (assign) IBOutlet PXListView *listView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tweetType:(TweetType)type;
- (void)reloadData:(BOOL)reset;

@end
