//
//  QWVerifyWindow.m
//  QWeiboClient
//
//  Created by Leon on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QWVerifyWindowController.h"
#import "AppDelegate.h"
#import <WebKit/WebFrame.h>
#import <WebKit/WebPolicyDelegate.h>
#import <QWeiboSDK/QWeiboAsyncApi.h>
#import <QWeiboSDK/NSURL+QAdditions.h>

@interface QWVerifyWindowController (Private)

- (NSString *)valueForParam:(NSString *)key ofQuery:(NSString*)query;

@end

@implementation QWVerifyWindowController

@synthesize delegate;
@synthesize webView = _webView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.webView setPolicyDelegate:self];
    [self.webView setFrameLoadDelegate:self];
    NSString *requestToken = [[NSUserDefaults standardUserDefaults] stringForKey:REQUEST_TOKEN_KEY];
	NSString *url = [NSString stringWithFormat:@"%@%@", VERIFY_URL, requestToken];
	NSURL *requestUrl = [NSURL URLWithString:url];
	NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
	[self.webView.mainFrame loadRequest:request];
}

- (void)windowWillClose:(NSNotification *)aNotification {
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN_KEY];
    NSString *accessTokenSecret = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN_SECRET_KEY];
    if (!(accessToken && ![accessToken isEqualToString:@""] && accessTokenSecret && ![accessTokenSecret isEqualToString:@""]))
        [NSApp terminate:self];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
//    if ([request respondsToSelector:@selector(setValue:forHTTPHeaderField:)]) {
//        [request setValue:@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; zh-cn) AppleWebKit/533.17.9 (KHTML, like Gecko) Mobile/8H7" forHTTPHeaderField:@"User-Agent"];
//    }
    
    NSString *query = [request.URL query];
	NSString *verifier = [self valueForParam:@"oauth_verifier" ofQuery:query];
    if (verifier && ![verifier isEqualToString:@""]) {
        NSString *requestToken = [[NSUserDefaults standardUserDefaults] stringForKey:REQUEST_TOKEN_KEY];
        NSString *requestTokenSecret = [[NSUserDefaults standardUserDefaults] stringForKey:REQUEST_TOKEN_SECRET_KEY];
		QWeiboAsyncApi *api = [[[QWeiboAsyncApi alloc] init] autorelease];
		NSString *retString = [api getAccessTokenWithRequestTokenKey:requestToken 
											  requestTokenSecret:requestTokenSecret 
														  verify:verifier];
		NIF_TRACE(@"\nget access token:%@", retString);
        NSDictionary *params = [NSURL parseURLQueryString:retString];
        [[NSUserDefaults standardUserDefaults] setObject:[params objectForKey:@"oauth_token"] forKey:ACCESS_TOKEN_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:[params objectForKey:@"oauth_token_secret"] forKey:ACCESS_TOKEN_SECRET_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([self.delegate conformsToProtocol:@protocol(QWVerifyDelegate)]) {
            [self.delegate loginFinished:self];
        }
        [listener ignore];
	} else {
        [listener use];
    }
}

- (NSString *)valueForParam:(NSString *)key ofQuery:(NSString *)query
{
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	for(NSString *aPair in pairs){
		NSArray *keyAndValue = [aPair componentsSeparatedByString:@"="];
		if([keyAndValue count] != 2) continue;
		if([[keyAndValue objectAtIndex:0] isEqualToString:key]){
			return [keyAndValue objectAtIndex:1];
		}
	}
	return nil;
}

@end
