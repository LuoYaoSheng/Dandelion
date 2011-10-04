//
//  QWPerson.h
//  QWeiboClient
//
//  Created by  on 11-9-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface QWPerson : NSObject {

}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *head;

- (id)initWithName:(NSString*)aName head:(NSString*)anHead;

@end
