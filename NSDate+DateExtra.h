//
//  NSDate+DateExtra.m
//  Dates wihtout time component
//
//  Created by Kati Haapamäki on 5.10.2012.
//  Copyright (c) 2012-2017 Kati Haapamäki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DateExtra)

+(NSDate *)dateWithoutTime:(NSDate *)myDate;
+(NSDate *)endOfTheDayForDate:(NSDate *)myDate;
@end
