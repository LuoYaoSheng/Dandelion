//
//  QWeiboAsyncApi.m
//  QWeiboSDK4iOSDemo
//
//  Created   on 11-1-18.
//   
//

#import "QWeiboAsyncApi.h"
#import "QOauthKey.h"
#import "QweiboRequest.h"
#import "AppDelegate.h"
#import "QWMessage.h"
#import "QWPerson.h"

@interface QWeiboAsyncApi()

- (void)getUpdateCount:(BOOL)reset udpateType:(UpdateType)updateType;
- (void)getDataWithURL:(NSString *)url Parameters:(NSMutableDictionary *)parameters delegate:(id)aDelegate tag:(JSONURLConnectionTag)tag;
- (void)postDataWithURL:(NSString *)url Parameters:(NSMutableDictionary *)parameters delegate:(id)aDelegate tag:(JSONURLConnectionTag)tag;
- (void)getTweetsWithTweetType:(TweetType)tweetType pageFlag:(PageFlag)pageFlag pageSize:(int)pageSize pageTime:(double)pageTime tag:(JSONURLConnectionTag)tag;

@end

@implementation QWeiboAsyncApi

@synthesize delegate = _delegate;

- (id)init
{
    if ((self = [super init])) {
        connectionList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)getRequestTokenWithConsumerKey:(NSString *)aConsumerKey consumerSecret:(NSString *)aConsumerSecret 
{
	
	NSString *url = @"https://open.t.qq.com/cgi-bin/request_token";//for example
	
	QOauthKey *oauthKey = [[QOauthKey alloc] init];
	oauthKey.consumerKey = aConsumerKey;
	oauthKey.consumerSecret = aConsumerSecret;
	oauthKey.callbackUrl = @"http://www.qq.com";//for example
	
	QWeiboRequest *request = [[QWeiboRequest alloc] init];
	NSString *retString = [request syncRequestWithUrl:url httpMethod:@"GET" oauthKey:oauthKey parameters:nil files:nil];
	
	[request release];
	[oauthKey release];
	return retString;
}

- (NSString *)getAccessTokenWithConsumerKey:(NSString *)aConsumerKey 
							 consumerSecret:(NSString *)aConsumerSecret 
							requestTokenKey:(NSString *)aRequestTokenKey
						 requestTokenSecret:(NSString *)aRequestTokenSecret 
									 verify:(NSString *)aVerify {
	
	NSString *url = @"https://open.t.qq.com/cgi-bin/access_token";
	
	QOauthKey *oauthKey = [[QOauthKey alloc] init];
	oauthKey.consumerKey = aConsumerKey;
	oauthKey.consumerSecret = aConsumerSecret;
	oauthKey.tokenKey = aRequestTokenKey;
	oauthKey.tokenSecret= aRequestTokenSecret;
	oauthKey.verify = aVerify;
	
	QWeiboRequest *request = [[QWeiboRequest alloc] init];
	NSString *retString = [request syncRequestWithUrl:url httpMethod:@"GET" oauthKey:oauthKey parameters:nil files:nil];
	
	[request release];
	[oauthKey release];
	return retString;
}

- (void)getLastTweetsWithTweetType:(TweetType)tweetType pageSize:(int)pageSize
{
    [self getTweetsWithTweetType:tweetType pageFlag:PageFlagLast pageSize:pageSize pageTime:0 tag:JSONURLConnectionTagGetLastTweets];
}

- (void)getOlderTweetsWithTweetType:(TweetType)tweetType pageSize:(int)pageSize pageTime:(double)pageTime
{
    if (pageTime == 0)
        [self getTweetsWithTweetType:tweetType pageFlag:PageFlagLast pageSize:pageSize pageTime:0 tag:JSONURLConnectionTagGetOlderTweets];
    else
        [self getTweetsWithTweetType:tweetType pageFlag:PageFlagOlder pageSize:pageSize pageTime:pageTime tag:JSONURLConnectionTagGetOlderTweets];
}

- (void)getNewerTweetsWithTweetType:(TweetType)tweetType pageSize:(int)pageSize pageTime:(double)pageTime
{
    if (pageTime == 0)
        [self getTweetsWithTweetType:tweetType pageFlag:PageFlagLast pageSize:pageSize pageTime:0 tag:JSONURLConnectionTagGetNewerTweets];
    else
        [self getTweetsWithTweetType:tweetType pageFlag:PageFlagNewer pageSize:pageSize pageTime:pageTime tag:JSONURLConnectionTagGetNewerTweets];
}

- (void)getTweetsWithTweetType:(TweetType)tweetType pageFlag:(PageFlag)pageFlag pageSize:(int)pageSize pageTime:(double)pageTime tag:(JSONURLConnectionTag)tag
{
    NSString *url;
    switch (tweetType) {
        case TweetTypeTimeline: {
            url = GET_TIMELINE_URL;
            break;
        }
        case TweetTypeMethions: {
            url = GET_METHIONS_URL;
            break;
        }
        case TweetTypeMessages: {
            url = GET_MESSAGES_URL;
            break;
        }
        case TweetTypeFavorites: {
            url = GET_FAVORITES_URL;
            break;
        }
        default:
            break;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	[parameters setObject:[NSString stringWithFormat:@"%d", pageFlag] forKey:@"pageflag"];
	[parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"reqnum"];
    [parameters setObject:[NSString stringWithFormat:@"%.f", pageTime] forKey:@"pagetime"];
    [self getDataWithURL:url Parameters:parameters delegate:self tag:tag];
}

- (void)getUserInfo
{
    NSString *url = GET_USER_INFO_URL;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [self getDataWithURL:url Parameters:parameters delegate:self tag:JSONURLConnectionTagGetUserInfo];
}

- (void)getUpdateCount:(BOOL)reset udpateType:(UpdateType)updateType
{
    NSString *url = UPDATE_URL;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    int op = 0;
    if (reset) {
        [parameters setObject:[NSString stringWithFormat:@"%d", updateType] forKey:@"type"];
        op = 1;
    }
    [parameters setObject:[NSString stringWithFormat:@"%d", op] forKey:@"op"];
    [self getDataWithURL:url Parameters:parameters delegate:self tag:JSONURLConnectionTagGetUpdateCount];
}

- (void)publishMessage:(NSString *)message
{
    NSString *url = PUBLISH_MESSAGE_URL;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:message forKey:@"content"];
    [self postDataWithURL:url Parameters:parameters delegate:self tag:JSONURLConnectionTagPublishMessage];
}

- (void)retweet:(NSString *)message reid:(NSString *)reid
{
    NSString *url = RETWEET_URL;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:message forKey:@"content"];
    [parameters setObject:@"127.0.0.1" forKey:@"clientip"];
    [parameters setObject:reid forKey:@"reid"];
    [self postDataWithURL:url Parameters:parameters delegate:self tag:JSONURLConnectionTagPublishMessage];
}

- (void)getDataWithURL:(NSString *)url Parameters:(NSMutableDictionary *)parameters delegate:(id)aDelegate tag:(JSONURLConnectionTag)tag
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN_KEY];
    NSString *accessTokenSecret = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN_SECRET_KEY];
	QOauthKey *oauthKey = [[QOauthKey alloc] init];
	oauthKey.consumerKey = APP_KEY;
	oauthKey.consumerSecret = APP_SECRET;
	oauthKey.tokenKey = accessToken;
	oauthKey.tokenSecret= accessTokenSecret;
	
	[parameters setObject:@"json" forKey:@"format"];
    
    JSONURLConnection *jsonConnection = [[JSONURLConnection alloc] initWithDelegate:self connectionTag:tag];
    [connectionList addObject:jsonConnection];
	QWeiboRequest *request = [[QWeiboRequest alloc] init];
	NSURLConnection *connection = [request asyncRequestWithUrl:url httpMethod:@"GET" oauthKey:oauthKey parameters:parameters files:nil delegate:jsonConnection];
    jsonConnection.innerConnection = connection;
	[connection start];
	[request release];
	[oauthKey release];
}

- (void)postDataWithURL:(NSString *)url Parameters:(NSMutableDictionary *)parameters delegate:(id)aDelegate tag:(JSONURLConnectionTag)tag
{
    NSMutableDictionary *files = [NSMutableDictionary dictionary];
	
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN_KEY];
    NSString *accessTokenSecret = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN_SECRET_KEY];
	QOauthKey *oauthKey = [[QOauthKey alloc] init];
	oauthKey.consumerKey = APP_KEY;
	oauthKey.consumerSecret = APP_SECRET;
	oauthKey.tokenKey = accessToken;
	oauthKey.tokenSecret= accessTokenSecret;
	
	[parameters setObject:@"json" forKey:@"format"];
    [parameters setObject:@"127.0.0.1" forKey:@"clientip"];
	
    JSONURLConnection *jsonConnection = [[JSONURLConnection alloc] initWithDelegate:self connectionTag:tag];
    [connectionList addObject:jsonConnection];
    [jsonConnection release];
	QWeiboRequest *request = [[QWeiboRequest alloc] init];
	NSURLConnection *connection = [request asyncRequestWithUrl:url httpMethod:@"POST" oauthKey:oauthKey parameters:parameters files:files delegate:jsonConnection];
	[connection start];
	[request release];
	[oauthKey release];
}

- (NSURLConnection *)publishMsgWithConsumerKey:(NSString *)aConsumerKey 
						 consumerSecret:(NSString *)aConsumerSecret 
						 accessTokenKey:(NSString *)aAccessTokenKey 
					  accessTokenSecret:(NSString *)aAccessTokenSecret 
								content:(NSString *)aContent 
							  imageFile:(NSString *)aImageFile  
							   delegate:(id)aDelegate {
	
	NSMutableDictionary *files = [NSMutableDictionary dictionary];
	NSString *url;
	
	if (aImageFile) {
		url = @"http://open.t.qq.com/api/t/add_pic";
		[files setObject:aImageFile forKey:@"pic"];
	} else {
		url = @"http://open.t.qq.com/api/t/add";
	}
	
	QOauthKey *oauthKey = [[QOauthKey alloc] init];
	oauthKey.consumerKey = aConsumerKey;
	oauthKey.consumerSecret = aConsumerSecret;
	oauthKey.tokenKey = aAccessTokenKey;
	oauthKey.tokenSecret= aAccessTokenSecret;
	
	NSString *format = nil;
    format = @"json";
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	[parameters setObject:aContent forKey:@"content"];
	[parameters setObject:@"127.0.0.1" forKey:@"clientip"];
	
	QWeiboRequest *request = [[QWeiboRequest alloc] init];
	NSURLConnection *connection = [request asyncRequestWithUrl:url httpMethod:@"POST" oauthKey:oauthKey parameters:parameters files:files delegate:aDelegate];
	
	[request release];
	[oauthKey release];
	return connection;
}

#pragma mark - JSONURLConnectionDelegate

- (void)dURLConnection:(JSONURLConnection *)connection didFinishLoadingJSONValue:(NSDictionary *)json
{
    switch (connection.connectionTag) {
        case JSONURLConnectionTagGetLastTweets:
        {
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            NSDictionary *userInfo = nil;
            if ([json valueForKeyPath:@"data"] != [NSNull null]) {
                for (NSDictionary *dict in [json valueForKeyPath:@"data.info"]) {
                    QWMessage *message = [[QWMessage alloc] initWithJSON:dict];
                    [messages addObject:message];
                    [message release];
                }
                userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[json valueForKeyPath:@"data.hasnext"], @"hasNext", nil];
            } else {
                userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"hasNext", nil];
            }
            if ([self.delegate respondsToSelector:@selector(receivedLastTweets:info:)]) {
                [self.delegate receivedLastTweets:messages info:userInfo];
            }
            [messages release];
            [userInfo release];
            break;
        }
        case JSONURLConnectionTagGetOlderTweets:
        {
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            NSDictionary *userInfo = nil;
            if ([json valueForKeyPath:@"data"] != [NSNull null]) {
                for (NSDictionary *dict in [json valueForKeyPath:@"data.info"]) {
                    QWMessage *message = [[QWMessage alloc] initWithJSON:dict];
                    [messages addObject:message];
                    [message release];
                }
                userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[json valueForKeyPath:@"data.hasnext"], @"hasNext", nil];
            } else {
                userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"hasNext", nil];
            }
            if ([self.delegate respondsToSelector:@selector(receivedLastTweets:info:)]) {
                [self.delegate receivedOlderTweets:messages info:userInfo];
            }
            [messages release];
            [userInfo release];
            break;        
        } 
        case JSONURLConnectionTagGetNewerTweets:
        {
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            if ([json valueForKeyPath:@"data"] != [NSNull null]) {
                for (NSDictionary *dict in [json valueForKeyPath:@"data.info"]) {
                    QWMessage *message = [[QWMessage alloc] initWithJSON:dict];
                    message.isNew = YES;
                    [messages addObject:message];
                    [message release];
                }
            }
            if ([self.delegate respondsToSelector:@selector(receivedNewerTweets:)]) {
                [self.delegate receivedNewerTweets:messages];
            }
            [messages release];
            break;
        }   
        case JSONURLConnectionTagGetUserInfo:
        {
            QWPerson *person = [[QWPerson alloc] initWithJSON:[json valueForKeyPath:@"data"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_USER_INFO_NOTIFICATION object:person];
            [person release];
            break;
        }
        case JSONURLConnectionTagPublishMessage:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PUBLISH_MESSAGE_NOTIFICATION object:[json objectForKey:@"msg"]];
            break;
        }
        case JSONURLConnectionTagGetUpdateCount:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_UPDATE_COUNT_NOTIFICATION object:[json objectForKey:@"data"]];
            break;            
        }
        default:
            break;
    }
    [connection release]; 
    connection = nil;
}

- (void)dURLConnection:(JSONURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection release]; 
    connection = nil;
}

- (void)beginUpdating
{
    timer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL_TIMELINE target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)timerMethod
{
    [self getUpdateCount:NO udpateType:UpdateTypeAll];
}

- (void)stopUpdating
{
    [timer invalidate];
}

- (void)dealloc
{
    [self stopUpdating];
    for (JSONURLConnection *conn in connectionList) {
        [conn cancelConnection];
    }
    [connectionList release]; connectionList = nil;
    [super dealloc];
}

@end
