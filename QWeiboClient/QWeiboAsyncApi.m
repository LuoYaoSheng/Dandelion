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

- (void)getHomeMessage
{
    NSString *url = GET_HOME_MESSAGE_URL;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	[parameters setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"pageflag"];
	[parameters setObject:[NSString stringWithFormat:@"%d", 20] forKey:@"reqnum"];
    [self getDataWithURL:url Parameters:parameters delegate:self tag:JSONURLConnectionTagGetHomeMessage];
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
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
	QOauthKey *oauthKey = [[QOauthKey alloc] init];
	oauthKey.consumerKey = appDelegate.appKey;
	oauthKey.consumerSecret = appDelegate.appSecret;
	oauthKey.tokenKey = appDelegate.tokenKey;
	oauthKey.tokenSecret= appDelegate.tokenSecret;
	
	[parameters setObject:@"json" forKey:@"format"];
    
    JSONURLConnection *jsonConnection = [[JSONURLConnection alloc] initWithDelegate:self connectionTag:tag];
	QWeiboRequest *request = [[QWeiboRequest alloc] init];
	NSURLConnection *connection = [request asyncRequestWithUrl:url httpMethod:@"GET" oauthKey:oauthKey parameters:parameters files:nil delegate:jsonConnection];
	[connection start];
	[request release];
	[oauthKey release];
}

- (void)postDataWithURL:(NSString *)url Parameters:(NSMutableDictionary *)parameters delegate:(id)aDelegate tag:(JSONURLConnectionTag)tag
{
    NSMutableDictionary *files = [NSMutableDictionary dictionary];
	
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
	QOauthKey *oauthKey = [[QOauthKey alloc] init];
	oauthKey.consumerKey = appDelegate.appKey;
	oauthKey.consumerSecret = appDelegate.appSecret;
	oauthKey.tokenKey = appDelegate.tokenKey;
	oauthKey.tokenSecret= appDelegate.tokenSecret;
	
	[parameters setObject:@"json" forKey:@"format"];
    [parameters setObject:@"127.0.0.1" forKey:@"clientip"];
	
    JSONURLConnection *jsonConnection = [[JSONURLConnection alloc] initWithDelegate:self connectionTag:tag];
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
        case JSONURLConnectionTagGetHomeMessage:
        {
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in [json valueForKeyPath:@"data.info"]) {
                [messages addObject:[[[QWMessage alloc] initWithJSON:dict] autorelease]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_HOME_MESSAGE_NOTIFICATION object:messages];
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

@end
