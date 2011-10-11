//
//  QWMessage.h
//  QWeiboClient
//
//  Created by Leon on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//NSString *nick
//NSString *head
//NSString *text
//double timestamp
//NSString *image
//QWMessage *source
//int type

typedef enum {
    QWMessageTypeOriginal,
    QWMessageTypeRetweet,
    QWMessageTypeReply
} QWMessageType;

#import <Foundation/Foundation.h>

@interface QWMessage : NSObject

@property (copy) NSString *tweetId;
@property (copy) NSString *nick;
@property (copy) NSString *head;
@property (copy) NSString *text;
@property (copy, readonly) NSString *time;
@property (copy) NSString *image;
@property (assign) double timestamp;
@property (retain) QWMessage *source;
@property (assign) QWMessageType type;

- (id)initWithTweetId:(NSString *)tweetId Nick:(NSString *)aNick head:(NSString *)aHead text:(NSString *)aText timestamp:(double)aTimestamp image:(NSString *)aImage source:(QWMessage *)aSource type:(QWMessageType)aType;
- (id)initWithJSON:(NSDictionary *)dict;

@end
