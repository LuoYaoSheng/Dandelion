//
//  QWeiboAsyncApi.h
//  QWeiboSDK4iOSDemo
//
//  Created   on 11-1-18.
//   
//

#import <Foundation/Foundation.h>
#import "JSONURLConnection.h"

enum {
    JSONURLConnectionTagGetLastTweets = 0,
    JSONURLConnectionTagGetOlderTweets,
    JSONURLConnectionTagGetNewerTweets,
	JSONURLConnectionTagGetUserInfo,
	JSONURLConnectionTagPublishMessage,
    JSONURLConnectionTagGetUpdateCount,
    JSONURLConnectionTagGetPublicTimeline,
};

typedef enum {
    TweetTypeNone = 0,
    TweetTypeTimeline = 5,
    TweetTypeMethions,
    TweetTypeMessages,
    TweetTypeFavorites,
    TweetTypeMyBroadcast,
    TweetTypeUserBroadcast,
    TweetTypeSearch,
} TweetType;

typedef enum {
    UpdateTypeAll = 0,
    UpdateTypeTimeline = 5,
    UpdateTypeMentions,
    UpdateTypeMessages,
} UpdateType;

typedef enum {
    PageFlagLast = 0,
    PageFlagOlder,
    PageFlagNewer,
} PageFlag;

@protocol QWeiboAsyncApiDelegate <NSObject>

- (void)receivedLastTweets:(NSArray *)tweets info:(NSDictionary *)info;
- (void)receivedOlderTweets:(NSArray *)tweets info:(NSDictionary *)info;
- (void)receivedNewerTweets:(NSArray *)tweets;

@end

@interface QWeiboAsyncApi : NSObject<JSONURLConnectionDelegate> {
    NSMutableArray *connectionList;
    NSTimer *timer;
}

@property(assign) id<QWeiboAsyncApiDelegate> delegate;

- (NSString *)getRequestTokenWithConsumerKey:(NSString *)aConsumerKey consumerSecret:(NSString *)aConsumerSecret;
- (NSString *)getAccessTokenWithConsumerKey:(NSString *)aConsumerKey 
							 consumerSecret:(NSString *)aConsumerSecret 
							requestTokenKey:(NSString *)aRequestTokenKey
						 requestTokenSecret:(NSString *)aRequestTokenSecret 
									 verify:(NSString *)aVerify;
- (void)getLastTweetsWithTweetType:(TweetType)tweetType pageSize:(int)pageSize userName:(NSString *)userName;
- (void)getOlderTweetsWithTweetType:(TweetType)tweetType pageSize:(int)pageSize pageTime:(double)pageTime userName:(NSString *)userName;
- (void)getNewerTweetsWithTweetType:(TweetType)tweetType pageSize:(int)pageSize pageTime:(double)pageTime userName:(NSString *)userName;
- (void)getPublicTimelineWithPos:(int)pos pageSize:(int)pageSize;
- (void)getUserInfo;
- (void)publishMessage:(NSString *)message;
- (void)publishMessage:(NSString *)message withPicture:(NSString *)filePath;
- (void)retweet:(NSString *)message reid:(NSString *)reid;
- (void)beginUpdating;
- (void)stopUpdating;

@end
