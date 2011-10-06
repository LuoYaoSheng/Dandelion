//
//  QWMessage.m
//  QWeiboClient
//
//  Created by Leon on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QWMessage.h"

@interface QWMessage ()

@property (assign) double timestamp;

@end

@implementation QWMessage

@synthesize nick = _nick;
@synthesize head = _head;
@synthesize text = _text;
@synthesize timestamp = _timestamp;
@synthesize image = _image;
@synthesize source = _source;
@synthesize type = _type;

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

- (id)initWithNick:(NSString *)aNick head:(NSString *)aHead text:(NSString *)aText timestamp:(double)aTimestamp image:(NSString *)aImage source:(QWMessage *)aSource type:(QWMessageType)aType
{
    if ((self = [super init])) {
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
    NSString *nick = [dict objectForKey:@"nick"];
    NSString *head = [[[dict objectForKey:@"head"] stringByReplacingOccurrencesOfString:@"app" withString:@"t2"] stringByAppendingPathComponent:@"50"];
    NSString *text = [[dict objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    double timestamp = [[dict objectForKey:@"timestamp"] doubleValue];
    NSString *image = [dict objectForKey:@"image"];
    QWMessage *source = nil;
    if ([dict objectForKey:@"source"] && [dict objectForKey:@"source"] != [NSNull null]) {
        source = [[[QWMessage alloc] initWithJSON:[dict objectForKey:@"source"]] autorelease];
    }
    QWMessageType type = (QWMessageType)[dict objectForKey:@"type"];
    return [self initWithNick:nick head:head text:text timestamp:timestamp image:image source:source type:type];
}

- (void)dealloc
{
    [_nick release];
    [_head release];
    [_text release];
    [_image release];
    [_source release];
    
    [super dealloc];
}

@end
