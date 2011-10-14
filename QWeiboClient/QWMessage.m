//
//  QWMessage.m
//  QWeiboClient
//
//  Created by Leon on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QWMessage.h"

@interface QWMessage ()

@end

@implementation QWMessage

@synthesize tweetId = _tweetId;
@synthesize nick = _nick;
@synthesize head = _head;
@synthesize text = _text;
@synthesize timestamp = _timestamp;
@synthesize image = _image;
@synthesize source = _source;
@synthesize type = _type;
@synthesize isNew = _isNew;

- (NSString *)time
{
    return [[NSDate dateWithTimeIntervalSince1970:self.timestamp] normalizeDateString];
}

- (id)init
{
    if ((self = [super init])) {
    }
    return self;
}

- (id)initWithTweetId:(NSString *)tweetId Nick:(NSString *)aNick head:(NSString *)aHead text:(NSString *)aText timestamp:(double)aTimestamp image:(NSString *)aImage source:(QWMessage *)aSource type:(QWMessageType)aType
{
    if ((self = [super init])) {
        self.tweetId = tweetId;
        self.nick = aNick;
        self.head = aHead;
        self.text = aText;
        self.timestamp = aTimestamp;
        self.image = aImage;
        self.source = aSource;
        self.type = aType;
    }
    return self;
}

- (id)initWithJSON:(NSDictionary *)dict
{
    NSString *tweetId = [dict objectForKey:@"id"];
    NSString *nick = [dict objectForKey:@"nick"];
    NSString *head = [dict objectForKey:@"head"];
    if (head && ![head isEqualToString:@""])
        head = [head stringByAppendingPathComponent:@"50"];
    NSString *text = [[dict objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    double timestamp = [[dict objectForKey:@"timestamp"] doubleValue];
    NSString *image = @"";
    if ([dict objectForKey:@"image"] && [dict objectForKey:@"image"] != [NSNull null])
        image = [[[dict objectForKey:@"image"] objectAtIndex:0] stringByAppendingPathComponent:@"160"];
    QWMessage *source = nil;
    if ([dict objectForKey:@"source"] && [dict objectForKey:@"source"] != [NSNull null]) {
        source = [[[QWMessage alloc] initWithJSON:[dict objectForKey:@"source"]] autorelease];
        if ([text isEqualToString:@""])
            text = [NSString stringWithFormat:@"-------------------\n@%@:%@", source.nick, source.text];
        else 
            text = [NSString stringWithFormat:@"%@\n-------------------\n@%@:%@", text, source.nick, source.text];
        if (![source.image isEqualToString:@""])
            image = source.image;
    }
    QWMessageType type = (QWMessageType)[dict objectForKey:@"type"];
    return [self initWithTweetId:tweetId Nick:nick head:head text:text timestamp:timestamp image:image source:source type:type];
}

- (void)dealloc
{
    [_tweetId release];
    [_nick release];
    [_head release];
    [_text release];
    [_image release];
    [_source release];
    
    [super dealloc];
}

@end
