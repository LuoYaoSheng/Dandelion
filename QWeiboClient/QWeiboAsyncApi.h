//
//  QWeiboAsyncApi.h
//  QWeiboSDK4iOSDemo
//
//  Created   on 11-1-18.
//   
//

#import <Foundation/Foundation.h>
#import "QWeiboSyncApi.h"
#import "JSONURLConnection.h"

enum {
    JSONURLConnectionTagGetTweets = 0,
    JSONURLConnectionTagGetNewTweets,
	JSONURLConnectionTagGetUserInfo,
	JSONURLConnectionTagPublishMessage,
    JSONURLConnectionTagGetUpdateCount,
};

typedef enum {
    TweetTypeNone = 0,
    TweetTypeTimeline = 5,
    TweetTypeMethions,
    TweetTypeMessages,
    TweetTypeFavorites,
} TweetType;

typedef enum {
    UpdateTypeAll = 0,
    UpdateTypeTimeline = 5,
    UpdateTypeMentions,
    UpdateTypeMessages,
} UpdateType;

@protocol QWeiboAsyncApiDelegate <NSObject>

- (void)receivedTweets:(NSArray *)tweets info:(NSDictionary *)info;
- (void)receivedNewTweets:(NSArray *)tweets;

@end

@interface QWeiboAsyncApi : NSObject<JSONURLConnectionDelegate> {
    NSMutableArray *connectionList;
    NSTimer *timer;
}

@property(assign) id<QWeiboAsyncApiDelegate> delegate;

- (void)getTweetsWithTweetType:(TweetType)tweetType pageFlag:(int)pageFlag pageSize:(int)pageSize pageTime:(double)pageTime new:(BOOL)new;
- (void)getNewTweetsWithTweetType:(TweetType)tweetType newTweetsCount:(int)count;
- (void)getUserInfo;
- (void)publishMessage:(NSString *)message;
- (void)beginUpdating;
- (void)stopUpdating;

@end
