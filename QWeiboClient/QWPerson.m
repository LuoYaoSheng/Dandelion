//
//  QWPerson.m
//  QWeiboClient
//
//  Created by  on 11-9-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "QWPerson.h"


@implementation QWPerson

@synthesize name = _name;
@synthesize head = _head;

//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    if ((self = [super init])) {
    }
    return self;
}

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithName:(NSString*)aName head:(NSString*)anHead 
{
    if ((self = [super init])) {
        self.name = aName;
        self.head = anHead;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
