
#import <Foundation/Foundation.h>

@protocol JSONURLConnectionDelegate;

enum {
	JSONURLConnectionTagDefault	= 0,
	JSONURLConnectionTagFirst,
	JSONURLConnectionTagSecond,
	JSONURLConnectionTagThird,
	JSONURLConnectionTagForth,
	JSONURLConnectionTagFifth
};

typedef NSUInteger JSONURLConnectionTag;

@interface JSONURLConnection : NSObject<NSURLConnectionDelegate> {

}

@property (nonatomic) JSONURLConnectionTag connectionTag;
@property (nonatomic, assign)  id <JSONURLConnectionDelegate> delegate;

- (id)initWithDelegate:(id<JSONURLConnectionDelegate>)delegate;	// default tag
- (id)initWithDelegate:(id<JSONURLConnectionDelegate>)delegate connectionTag:(JSONURLConnectionTag)tag;

@end


@protocol JSONURLConnectionDelegate <NSObject>

@optional

- (void)dURLConnectionDidStartLoading:(JSONURLConnection *)connection;
- (void)dURLConnection:(JSONURLConnection *)connection didFinishLoadingJSONValue:(NSDictionary *)json;
- (void)dURLConnection:(JSONURLConnection *)connection didFailWithError:(NSError *)error;
- (void)dURLConnection:(JSONURLConnection *)connection didFinishLoadingJSONValue:(NSDictionary *)json string:(NSString *)content;
- (BOOL)dURLConnectionPopViewControllerWhenFail:(JSONURLConnection *)connection;

@end
