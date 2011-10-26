//
//  QWTimelineView.h
//  QWeiboClient
//
//  Created by  on 11-9-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXListView.h"
#import <QWeiboSDK/QWeiboAsyncApi.h>
#import "ListViewEndCell.h"
#import "QWMainWindowController.h"

@interface QWTweetViewController : NSViewController<PXListViewDelegate, QWeiboAsyncApiDelegate> {
    QWeiboAsyncApi *api;
    
    //for older
    BOOL hasNext;
    double oldestPageTime;
    int pos;
    
    //for newer
    double newestPageTime;
    
    BOOL isLoading;
    NSTimer *timer;
}


@property (nonatomic, retain) NSMutableArray *listContent;
@property (assign) IBOutlet PXListView *listView;
@property (assign) QWMainWindowController *mainWindowController;
@property (assign) int newTweetCount;
@property (copy) NSString *userName;
@property (assign) TweetType tweetType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tweetType:(TweetType)type userName:(NSString *)userName;
- (void)getLastTweets;
- (void)fetchNewerTweets;
- (void)retweet;
- (BOOL)canRetweet;

@end
