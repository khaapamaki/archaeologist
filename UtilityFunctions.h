//
//  UtilityFunctions.h
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 14.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Definitions.h"

float logx(float value, float base);
void printStdErr(NSString *str);
void printStdOut(NSString *str);
void printStdErrLine(NSString *str);
void printStdOutLine(NSString *str);
void printStdErrWithFormat(NSString *format, ...);
void printStdOutWithFormat(NSString *format, ...);
NSString* convertToFileSizeString(long long fileSize);
long long getFileSizeWithString(NSString *fileSizeString);
NSString* formattedDate(NSDate *aDate);
NSString* cutStartOfString(NSString *str, unsigned long newLength);
NSDate *dateSinceNow(int years, int months, int days);
NSTimeInterval elapsedTimeFrom(NSDate* start, NSDate* end);

NSString* minSecString(NSTimeInterval time);
NSString* sizeStringWithFiller(long long size, short length);
NSString* getTagString(NSNumber *tagAsNSNumber);
NSString* extractRootFromPath(NSString *rootPath, NSString *path);
NSString* fillToLength(NSString * str, short length);
