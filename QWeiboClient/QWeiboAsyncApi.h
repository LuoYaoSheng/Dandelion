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
	JSONURLConnectionTagGetHomeMessage = 0,
	JSONURLConnectionTagGetUserInfo,
	JSONURLConnectionTagPublishMessage,
};

@interface QWeiboAsyncApi : NSObject<JSONURLConnectionDelegate> {

}

- (void)getHomeMessage;
- (void)getUserInfo;
- (void)publishMessage:(NSString *)message;

@end
