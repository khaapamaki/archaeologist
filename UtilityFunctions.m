//
//  UtilityFunctions.m
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 14.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import "UtilityFunctions.h"

float logx(float value, float base)
{
    return log10f(value) / log10f(base);
}


void printStdErr(NSString *str) {
    [str writeToFile:@"/dev/stderr" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

void printStdOut(NSString *str) {
    [str writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

void printStdErrLine(NSString *str) {
    NSString *str2 = [str stringByAppendingString:@"\n"];
    [str2 writeToFile:@"/dev/stderr" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

void printStdOutLine(NSString *str) {
    NSString *str2 = [str stringByAppendingString:@"\n"];
    [str2 writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

void printStdErrWithFormat(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *prtStr = [[NSString alloc] initWithFormat:format arguments:args];
    printStdErr(prtStr);
}

void printStdOutWithFormat(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *prtStr = [[NSString alloc] initWithFormat:format arguments:args];
    printStdOut(prtStr);
}

NSString* convertToFileSizeString(long long fileSize) {
    NSString *unit = @"";
    float floatSize;
    long long teras = 1000*1000*1000;
    teras *= 1000;
    
    if (fileSize < 1000*1000) {
        floatSize = (double) fileSize / (1000.0f);
        unit = @" KB";
    } else {
        if (fileSize < 1000*1000*1000) {
            floatSize = (double) fileSize / (1000.0f*1000.0f);
            unit = @" MB";
        } else {
            if (fileSize < (teras)) {
                floatSize = (double) fileSize / (1000.0f*1000.0f*1000.0f);
                unit = @" GB";
            } else {
                floatSize = (double) fileSize / (1000.0f*1000.0f*1000.0f*1000.0f);
                unit = @" TB";
            }
        }
    }
    
    NSString *result = [NSString stringWithFormat:@"%F", floatSize];
    result = [result substringToIndex:[result length] -4];
    result = [result stringByAppendingString:unit];
    
    return result;
}

long long getFileSizeWithString(NSString *fileSizeString) {
    NSString *lowerCaseString = [fileSizeString lowercaseString];
    long long result = -1;
    long long multiplier = 1;
    
    if (fileSizeString != nil) {
        if ([[lowerCaseString substringFromIndex:[lowerCaseString length] - 1] isEqualToString:@"b"] && [lowerCaseString length] > 1) {
            lowerCaseString = [lowerCaseString substringToIndex:[lowerCaseString length] -1];
        }
        
        const char testChar = [lowerCaseString characterAtIndex:[lowerCaseString length] -1];
        switch (testChar) {
            case 'k':
                multiplier = 1000ll;
                break;
            case 'm':
                multiplier = 1000ll * 1000ll;
                break;
            case 'g':
                multiplier = 1000ll * 1000ll * 1000ll;
                break;
            case 't':
                multiplier = 1000ll * 1000ll * 1000ll * 1000ll;
                break;
            default:
                break;
        }
        result = (long long)([fileSizeString floatValue] * multiplier);
    }
    
    return result;
}

NSString *formattedDate(NSDate *aDate) {
    NSDateFormatter *logTimeFormatter = [[NSDateFormatter alloc] init];
    [logTimeFormatter setDateFormat:@"yyyy-MM-dd"];
    [logTimeFormatter setDateFormat:@"d.M.yyyy"];
    return [logTimeFormatter stringFromDate:aDate];
}

NSString *cutStartOfString(NSString *str, unsigned long newLength) {
    long originalLength = [str length];
    NSString *result = @"";
    
    if (originalLength > newLength && newLength > 0) {
        result = [str substringFromIndex:originalLength - newLength -1];
    } else {
        result = str;
    }
    return result;
}

NSDate *dateSinceNow(int years, int months, int days) {
    NSDate *now = [NSDate date];
    NSDateComponents *dateToAdd = [[NSDateComponents alloc] init];
    [dateToAdd setYear:-years];
    [dateToAdd setMonth:-months];
    [dateToAdd setDay:-days];
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateToAdd toDate:now options:0];
}

NSTimeInterval elapsedTimeFrom(NSDate* start, NSDate* end) {
    NSTimeInterval et = [end timeIntervalSinceDate:start];
    return et;
}

NSString* minSecString(NSTimeInterval time) {
    int min = (int) floor(time / 60.0);
    int sec = (int) floor(time - (double)min * 60.0);
    return [NSString stringWithFormat:@"%i min %i secs", min, sec];
    
}

NSString* fillToLength(NSString * str, short length) {
    return [str stringByPaddingToLength:length withString:@" " startingAtIndex:0];
}

NSString* getTagString(NSNumber *tagAsNSNumber) {
    TagType tag = [tagAsNSNumber shortValue];
    NSMutableArray *tagArray = [[NSMutableArray alloc] initWithCapacity:4];
    if ((tag & ArchiveTag) != 0)
        [tagArray addObject:@"Arc"];
    if ((tag & DeleteTag) != 0)
        [tagArray addObject:@"DEL"];
    if ((tag & CandidateTag) != 0)
        [tagArray addObject:@"Cnd"];
    if ((tag & CheckTag) != 0)
        [tagArray addObject:@"Chk"];
    NSMutableString *tagString = [NSMutableString stringWithString:@""];
    for (int i=0; i < [tagArray count]; i++) {
        [tagString appendString:[tagArray objectAtIndex:i]];
        if (i < [tagArray count] - 1)
            [tagString appendString:@"/"];
    }
    return [NSString stringWithString:tagString];
}
NSString* extractRootFromPath(NSString *rootPath, NSString *path) {
    return [NSString stringWithFormat:@"%@/", [path substringFromIndex:[rootPath length]]];
//    return [NSString stringWithFormat:@"%@%@", [rootPath lastPathComponent], [path substringFromIndex:[rootPath length]]];
}
