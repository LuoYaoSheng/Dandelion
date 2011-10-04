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

@property (copy) NSString *nick;
@property (copy) NSString *head;
@property (copy) NSString *text;
@property (copy, readonly) NSString *time;
@property (copy) NSString *image;
@property (retain) QWMessage *source;
@property (assign) QWMessageType type;

- (id)initWithNick:(NSString *)aNick head:(NSString *)aHead text:(NSString *)aText timestamp:(double)aTimestamp image:(NSString *)aImage source:(QWMessage *)aSource type:(QWMessageType)aType;
- (id)initWithJSON:(NSDictionary *)dict;

@end
