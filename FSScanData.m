//
//  FSScanData.m
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 15.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import "FSScanData.h"


@implementation FSScanData

-(void)incrementFileCount {
    _fileCounter++;
}

-(void)incrementDirectoryCount {
    _directoryCounter++;
}

-(void)incrementByteCountBy:(long long)fileSize {
    _byteCount += fileSize;
}

-(void)setProgressDisplayTime {
    _lastProgressDisplayTime = [NSDate date];
}

-(instancetype)init {
    if (self = [super init]) {
        _scanStartTime = [NSDate date];
        _lastProgressDisplayTime = [NSDate date];
        _byteCount = 0;
        _directoryCounter = 0;
        _fileCounter = 0;
        _recursiveFileCounter = 0;
        _recursiveDirectoryCounter = 0;
        _recursiveByteCount = 0;
        _isCancelled = NO;
    }
    return self;
}

-(void) dealloc {
    
   // NSLog(@"Deallocating: %@", self);
}

@end
