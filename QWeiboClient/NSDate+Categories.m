//
//  NSDate+Categories.m
//  DDCoupon
//
//  Created by Ryan Wang on 11-3-31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Categories.h"

#define kDEFAULT_DATE_TIME_FORMAT (@"yyyy/MM/dd")

@implementation NSDate(Categories)

+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format{    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
  //  [formatter setDateFormat:kDEFAULT_DATE_TIME_FORMAT];
	[formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:string];
    [formatter release];
   
	return date;
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
	[formatter setDateFormat:format];
    NSString *dateString = [formatter stringFromDate:date];
    [formatter release];
    
	return dateString;
}

- (NSString *)normalizeDateString
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:self toDate:[NSDate date] options:0];
    if ([components day] > 30) {
        return [NSDate stringFromDate:self format:@"yyyy-MM-dd"];
    } else if ([components day] > 0) {
        return [NSString stringWithFormat:@"%d天前", [components day]];
    } else if ([components hour] > 0) {
        return [NSString stringWithFormat:@"%d小时前", [components hour]];
    } else {
        return @"刚刚";
    }
}

@end
