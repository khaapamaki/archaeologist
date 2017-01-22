//
//  FSScanData.h
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 15.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSScanData : NSObject

@property NSDate *lastProgressDisplayTime; // used only for scan root object
@property NSDate *scanStartTime;
@property NSDate *scanEndTime;
@property (nonatomic) BOOL foldersOnly;

@property (nonatomic) NSURL *fileURL;
@property BOOL isCancelled;

@property long fileCounter;
@property long directoryCounter;
@property long long byteCount;
@property long recursiveFileCounter;
@property long recursiveDirectoryCounter;
@property long long recursiveByteCount;
@property NSDate *earliestFileDate;
@property NSDate *latestFileDate;
@property NSDate *earliestRecursiveFileDate;
@property NSDate *latestRecursiveFileDate;
@property NSDate *earliestDirectoryDate;
@property NSDate *latestDirectoryDate;
@property NSDate *earliestRecursiveDirectoryDate;
@property NSDate *latestRecursiveDirectoryDate;
@property NSString *earliestFilePath;
@property NSString *latestFilePath;
@property NSString *earliestRecursiveFilePath;
@property NSString *latestRecursiveFilePath;
@property NSString *earliestDirectoryPath;
@property NSString *latestDirectoryPath;
@property NSString *earliestRecursiveDirectoryPath;
@property NSString *latestRecursiveDirectoryPath;
-(void)incrementFileCount;
-(void)incrementDirectoryCount;
-(void)incrementByteCountBy:(long long)fileSize;
-(void)setProgressDisplayTime;

@end
