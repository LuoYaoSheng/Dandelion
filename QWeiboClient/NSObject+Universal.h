//
//  NSObject+Universal.h
//  DDCoupon
//
//  Created by ryan on 11-6-8.
//  Copyright 2011 DDmap. All rights reserved.
//

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////////////

NSString * EmptyString(id anMaybeEmptyString);

////////////////////////////////////////////////////////////////////////////////////////

@interface NSUserDefaults (standardUserDefaults)

+ (NSString *)stringOfKeyInStandardDefaults:(NSString *)key;
+ (void)setStandardDefaultsObject:(id)object forKey:(NSString *)key;

@end
