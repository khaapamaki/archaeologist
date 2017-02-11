//
//  NSDate+DateExtra.m
//  Dates wihtout time component
//
//  Created by Kati Haapamäki on 5.10.2012.
//  Copyright (c) 2012-2017 Kati Haapamäki. All rights reserved.
//

#import "NSDate+DateExtra.h"

@implementation NSDate (DateExtra)

+(NSDate *)dateWithoutTime:(NSDate *)myDate {
    NSDate * result = [[NSCalendar currentCalendar] startOfDayForDate:myDate];
    return result;
}

+(NSDate *)endOfTheDayForDate:(NSDate *)myDate {
    NSTimeZone *timeZone = [[NSCalendar currentCalendar] timeZone];
    NSDateComponents *dateComp = [[NSCalendar currentCalendar] componentsInTimeZone:timeZone fromDate:myDate];
    [dateComp setHour:23];
    [dateComp setMinute:59];
    [dateComp setSecond:59];
    [dateComp setNanosecond:999999999];
    NSDate * result = [[NSCalendar currentCalendar] dateFromComponents:dateComp];
    return result;
}


@end
