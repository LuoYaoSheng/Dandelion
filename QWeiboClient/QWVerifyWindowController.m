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
#import "QWeiboSyncApi.h"

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
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
	NSString *url = [NSString stringWithFormat:@"%@%@", VERIFY_URL, appDelegate.tokenKey];
	NSURL *requestUrl = [NSURL URLWithString:url];
	NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
	[self.webView.mainFrame loadRequest:request];
}

- (void)windowWillClose:(NSNotification *)aNotification {
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
    NSString *query = [request.URL query];
	NSString *verifier = [self valueForParam:@"oauth_verifier" ofQuery:query];
    if (verifier && ![verifier isEqualToString:@""]) {
		AppDelegate *appDelegate = [NSApp delegate];
		QWeiboSyncApi *api = [[[QWeiboSyncApi alloc] init] autorelease];
		NSString *retString = [api getAccessTokenWithConsumerKey:appDelegate.appKey 
												  consumerSecret:appDelegate.appSecret 
												 requestTokenKey:appDelegate.tokenKey 
											  requestTokenSecret:appDelegate.tokenSecret 
														  verify:verifier];
		NSLog(@"\nget access token:%@", retString);
		[appDelegate parseTokenKeyWithResponse:retString];
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
