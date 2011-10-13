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
#import "QWMainWindowController.h"

@interface QWTweetViewController : NSViewController<PXListViewDelegate, QWeiboAsyncApiDelegate> {
    QWeiboAsyncApi *api;
    
    //for older
    BOOL hasNext;
    double oldestPageTime;
    
    //for newer
    double newestPageTime;
    
    BOOL isLoading;
    TweetType tweetType;
    NSTimer *timer;
}


@property (nonatomic, retain) NSMutableArray *listContent;
@property (assign) IBOutlet PXListView *listView;
@property (assign) QWMainWindowController *mainWindowController;
@property (assign) int newTweetCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tweetType:(TweetType)type;
- (void)getLastTweets;
- (void)fetchNewerTweets;

@end
