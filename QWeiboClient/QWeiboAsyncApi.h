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
	JSONURLConnectionTagGetTimeline = 0,
	JSONURLConnectionTagGetUserInfo,
	JSONURLConnectionTagPublishMessage,
    JSONURLConnectionTagGetMethions,
    JSONURLConnectionTagGetMessages,
    JSONURLConnectionTagGetFavorites,
};

@interface QWeiboAsyncApi : NSObject<JSONURLConnectionDelegate> {

}

- (void)getTimelineWithPageFlag:(int)pageFlag pageSize:(int)pageSize pageTime:(double)pageTime;
- (void)getMethionsWithPageFlag:(int)pageFlag pageSize:(int)pageSize pageTime:(double)pageTime;
- (void)getMessagesWithPageFlag:(int)pageFlag pageSize:(int)pageSize pageTime:(double)pageTime;
- (void)getFavoritesWithPageFlag:(int)pageFlag pageSize:(int)pageSize pageTime:(double)pageTime;
- (void)getUserInfo;
- (void)publishMessage:(NSString *)message;

@end
