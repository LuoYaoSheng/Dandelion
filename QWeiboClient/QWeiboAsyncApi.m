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

- (void)getDataWithURL:(NSString *)url Parameters:(NSMutableDictionary *)parameters delegate:(id)aDelegate tag:(JSONURLConnectionTag)tag;
- (void)postDataWithURL:(NSString *)url Parameters:(NSMutableDictionary *)parameters delegate:(id)aDelegate tag:(JSONURLConnectionTag)tag;

@end

@implementation QWeiboAsyncApi

- (id)init
{
    if ((self = [super init])) {
        connectionList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)getTimelineWithPageFlag:(int)pageFlag pageSize:(int)pageSize pageTime:(double)pageTime
{
    NSString *url = GET_TIMELINE_URL;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	[parameters setObject:[NSString stringWithFormat:@"%d", pageFlag] forKey:@"pageflag"];
	[parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"reqnum"];
    [parameters setObject:[NSString stringWithFormat:@"%.f", pageTime] forKey:@"pagetime"];
    [self getDataWithURL:url Parameters:parameters delegate:self tag:JSONURLConnectionTagGetTimeline];
}

- (void)getMenthionsWithPageFlag:(int)pageFlag pageSize:(int)pageSize pageTime:(double)pageTime
{
    NSString *url = GET_METHIONS_URL;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	[parameters setObject:[NSString stringWithFormat:@"%d", pageFlag] forKey:@"pageflag"];
	[parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"reqnum"];
    [parameters setObject:[NSString stringWithFormat:@"%.f", pageTime] forKey:@"pagetime"];
    [self getDataWithURL:url Parameters:parameters delegate:self tag:JSONURLConnectionTagGetMethions];
}

- (void)getMessagesWithPageFlag:(int)pageFlag pageSize:(int)pageSize pageTime:(double)pageTime
{
    NSString *url = GET_MESSAGES_URL;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	[parameters setObject:[NSString stringWithFormat:@"%d", pageFlag] forKey:@"pageflag"];
	[parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"reqnum"];
    [parameters setObject:[NSString stringWithFormat:@"%.f", pageTime] forKey:@"pagetime"];
    [self getDataWithURL:url Parameters:parameters delegate:self tag:JSONURLConnectionTagGetMessages];
}

- (void)getFavoritesWithPageFlag:(int)pageFlag pageSize:(int)pageSize pageTime:(double)pageTime
{
    NSString *url = GET_FAVORITES_URL;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	[parameters setObject:[NSString stringWithFormat:@"%d", pageFlag] forKey:@"pageflag"];
	[parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"reqnum"];
    [parameters setObject:[NSString stringWithFormat:@"%.f", pageTime] forKey:@"pagetime"];
    [self getDataWithURL:url Parameters:parameters delegate:self tag:JSONURLConnectionTagGetFavorites];
}

- (void)getUserInfo
{
    NSString *url = GET_USER_INFO_URL;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [self getDataWithURL:url Parameters:parameters delegate:self tag:JSONURLConnectionTagGetUserInfo];
}

- (void)publishMessage:(NSString *)message
{
    NSString *url = PUBLISH_MESSAGE_URL;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:message forKey:@"content"];
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
							 resultType:(ResultType)aResultType 
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
	if (aResultType == RESULTTYPE_XML) {
		format = @"xml";
	} else if (aResultType == RESULTTYPE_JSON) {
		format = @"json";
	} else {
		format = @"json";
	}
	
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
        case JSONURLConnectionTagGetTimeline:
        {
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            NSDictionary *userInfo = nil;
            if ([json valueForKeyPath:@"data"] != [NSNull null]) {
                for (NSDictionary *dict in [json valueForKeyPath:@"data.info"]) {
                    [messages addObject:[[[QWMessage alloc] initWithJSON:dict] autorelease]];
                }
                userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[json valueForKeyPath:@"data.hasnext"], @"hasNext", nil];
            } else {
                userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"hasNext", nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_TIMELINE_NOTIFICATION object:messages userInfo:userInfo];
            [messages release];
            [userInfo release];
            break;
        }
        case JSONURLConnectionTagGetMethions:
        {
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            NSDictionary *userInfo = nil;
            if ([json valueForKeyPath:@"data"] != [NSNull null]) {
                for (NSDictionary *dict in [json valueForKeyPath:@"data.info"]) {
                    [messages addObject:[[[QWMessage alloc] initWithJSON:dict] autorelease]];
                }
                userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[json valueForKeyPath:@"data.hasnext"], @"hasNext", nil];
            } else {
                userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"hasNext", nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_METHIONS_NOTIFICATION object:messages userInfo:userInfo];
            [messages release];
            [userInfo release];
            break;
        }
        case JSONURLConnectionTagGetMessages:
        {
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            NSDictionary *userInfo = nil;
            if ([json valueForKeyPath:@"data"] != [NSNull null]) {
                for (NSDictionary *dict in [json valueForKeyPath:@"data.info"]) {
                    [messages addObject:[[[QWMessage alloc] initWithJSON:dict] autorelease]];
                }
                userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[json valueForKeyPath:@"data.hasnext"], @"hasNext", nil];
            } else {
                userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"hasNext", nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_MESSAGES_NOTIFICATION object:messages userInfo:userInfo];
            [messages release];
            [userInfo release];
            break;
        }
        case JSONURLConnectionTagGetFavorites:
        {
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            NSDictionary *userInfo = nil;
            if ([json valueForKeyPath:@"data"] != [NSNull null]) {
                for (NSDictionary *dict in [json valueForKeyPath:@"data.info"]) {
                    [messages addObject:[[[QWMessage alloc] initWithJSON:dict] autorelease]];
                }
                userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[json valueForKeyPath:@"data.hasnext"], @"hasNext", nil];
            } else {
                userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"hasNext", nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_FAVORITES_NOTIFICATION object:messages userInfo:userInfo];
            [messages release];
            [userInfo release];
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

- (void)dealloc
{
    for (JSONURLConnection *conn in connectionList) {
        if ([conn respondsToSelector:@selector(cancelConnection)]) {
            [conn cancelConnection];
        }
    }
    [connectionList release]; connectionList = nil;
    [super dealloc];
}

@end
