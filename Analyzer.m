//
//  Analyzer.m
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 16.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import "Analyzer.h"


@implementation Analyzer

-(void)scanDirectory:(FSItem*)fsItem olderThan:(NSDate*)dateTreshold minSize:(long)sizeTreshold minDepth:(long)minDepth maxDepth:(long)maxDepth {
    [self scanDirectory:fsItem olderThan:dateTreshold minSize:sizeTreshold minDepth:(long)minDepth maxDepth:maxDepth mode:0];
}

-(void)scanDirectory:(FSItem*)fsItem olderThan:(NSDate*)dateTreshold minSize:(long)sizeTreshold minDepth:(long)minDepth maxDepth:(long)maxDepth mode:(int)mode {
    _rootDirectory = fsItem;
    [_resultArray removeAllObjects];
    _scanData = [[FSScanData alloc] init];
    _scanData.fileURL = fsItem.fileURL;
    [self scanDirectoryInnerLoop:fsItem olderThan:dateTreshold minSize:sizeTreshold minDepth:minDepth maxDepth:maxDepth mode:mode subLevel:0];
}

// internal use only, result/item arrays must be emptied before
-(void)scanDirectoryInnerLoop:(FSItem*)fsItem olderThan:(NSDate*)dateTreshold minSize:(long)sizeTreshold minDepth:(long)minDepth maxDepth:(long)maxDepth mode:(int)mode subLevel:(int)subLevel {
    
    BOOL hideDirectoriesWithoutDates = (mode & FCAHideDirectoriesWithoutDates) > 0;
    BOOL lonkeroMode = (mode & FCALonkeroMode) > 0;
    BOOL invertDateFilters = (mode & FCAInvertDateFilter) > 0;
    BOOL invertSizeFilter = (mode & FCAInvertSizeFilter) > 0;
    long currentRelativeDepth = [[[fsItem path] pathComponents] count] - [[[_rootDirectory path] pathComponents] count];
    BOOL stopOnNextNonLonkeroFolder = (mode & FCALonkeroStopOnNextNonLonkeroFolder) > 0;
    BOOL lonkeroSearchForMaster = (mode & FCALonkeroSearchMasters) > 0;
    BOOL lonkeroRespectLevels = (mode & FCALonkeroRespectMaxLimit) > 0;
    BOOL lonkeroOnly = (mode & FCALonkeroOnly) > 0;
    BOOL noByteCount = (mode & FCAByteCountStopped) > 0;
    BOOL stopAtFirstMatch = (mode & FCAShowSubDirectories) == 0;
    BOOL found = NO;
    BOOL lonkeroDontContinue = NO; // to enable showing 1 non-lonkero folder but not going further
    
    if ([fsItem.isDirectory boolValue] == YES) {
        BOOL dateSelect = NO;
        
        if (dateTreshold != nil) {
            if (fsItem.scanData.latestRecursiveFileDate != nil) {
                dateSelect = [fsItem.scanData.latestRecursiveFileDate compare:dateTreshold] == NSOrderedAscending;
                if (invertDateFilters) {
                    dateSelect = !dateSelect;
                }
            } else {
                 dateSelect = !hideDirectoriesWithoutDates;
            }
        } else {
            dateSelect = YES;
        }
        
        BOOL lonkeroContinue = NO;
        BOOL lonkeroStop = NO;
        BOOL lonkeroSkipCurrent = NO;
        
        BOOL isMaster = [fsItem.isLonkeroMaster boolValue];
        BOOL isParent = [fsItem.isLonkeroParent boolValue];
        BOOL isRoot = [fsItem.isLonkeroRoot boolValue];
        BOOL isLonkeroFolder = isMaster || isParent || isRoot;
        
        BOOL lastLevel = maxDepth < 1 && ((lonkeroMode && lonkeroRespectLevels) || !lonkeroMode || (lonkeroMode && !isLonkeroFolder));
        
        // Lonkero
        if (lonkeroMode) {
            if (isLonkeroFolder) {
                if (isMaster) {
                    lonkeroDontContinue = YES;  // this is master, dont look for deep (will be overridden if this is parent at the same time
                }
                
                if (isParent || isRoot){
                    if ((isRoot || lonkeroSearchForMaster) && !lastLevel && !isMaster) {
                        lonkeroSkipCurrent = YES; // myös muissa tapauksissa kun ei masteria? root?
                    }
                    if (!lastLevel) {
                        lonkeroContinue = YES; // is lonkero folder but not yet master -> move on
                        lonkeroDontContinue = NO;
                    }
                }
            } else {
                if (lonkeroOnly) lonkeroSkipCurrent = YES;
            }
        }
        
        if (lonkeroMode && !isLonkeroFolder && stopOnNextNonLonkeroFolder) {
            lonkeroSkipCurrent = YES; // full stop, this is folder after master level
            lonkeroDontContinue = YES;
        }
        
        BOOL sizeSelect;
        if (invertSizeFilter) {
            if (sizeTreshold == 0) {
                sizeSelect = [fsItem.fileSize longValue] == 0;
            } else {
                sizeSelect = !([fsItem.fileSize longValue] >= sizeTreshold);
            }
            
        } else {
            sizeSelect = [fsItem.fileSize longValue] >= sizeTreshold;
        }
    
        if (dateSelect && sizeSelect && currentRelativeDepth >= minDepth && !lonkeroStop && !lonkeroSkipCurrent)
        {
            // found something to show
            found = YES;
            
            if ([[fsItem isHidden] boolValue] == NO) {
                if (!noByteCount) _scanData.byteCount += [fsItem.fileSize longLongValue];
                _scanData.directoryCounter++;
            }
            NSDictionary *rowDictionary = [self makeDictionaryForTableViewRow:fsItem subLevel:subLevel];
            [_resultArray addObject:rowDictionary];
            
        }
        
        // No match -> dig in deeper if max depth not reached
        
        BOOL secondarySizeSelect = invertSizeFilter ? YES : sizeSelect;
        
        // if ((found == NO || lonkeroContinue || (!lonkeroMode && !lonkeroStopAtParent)) && secondarySizeSelect && !lastLevel && !lonkeroStop && !lonkeroDontContinue)
        if ((found == NO || !stopAtFirstMatch) && secondarySizeSelect && !lastLevel && !lonkeroStop && !lonkeroDontContinue)
        {
            int newSubLevel = subLevel;
            int newMode = mode;
            if (found == YES) { // is current item shown and still going further..
                newSubLevel++;
                newMode = mode |= found ? FCAByteCountStopped : 0; // stop byte count at succeeding levels
            }
            if (isLonkeroFolder && lonkeroMode && isMaster && !isParent) {
                newMode |= (newMode | FCALonkeroStopOnNextNonLonkeroFolder);
            }
            
            for (FSItem * subItem in fsItem.directoryContents) {
                if ([subItem.isDirectory boolValue] == YES) {
                    [self scanDirectoryInnerLoop:subItem
                                       olderThan:dateTreshold
                                         minSize:sizeTreshold
                                        minDepth:(long)minDepth
                                        maxDepth:maxDepth-1
                                            mode:newMode
                                        subLevel:newSubLevel];
                }
            }
        }
    }
}

-(void)scanTaggedItems:(FSItem*)fsItem tags:(TagType)tagPattern {
    _rootDirectory = fsItem;
    [_resultArray removeAllObjects];
    _scanData = [[FSScanData alloc] init];
    _scanData.fileURL = fsItem.fileURL;
    [self recurseTaggedItems:fsItem tags:tagPattern subLevel:0];
}

// internal use only, result/item arrays must be emptied before
- (void)recurseTaggedItems:(FSItem*)fsItem tags:(TagType)tagPattern subLevel:(int)subLevel {
    
    TagType tagsForItem = [[fsItem tags] shortValue];
    
    if ((tagsForItem & tagPattern) != 0) {
        if ([[fsItem isHidden] boolValue] == NO) {
            _scanData.byteCount += [fsItem.fileSize longLongValue];
            _scanData.directoryCounter++;
        }
        NSDictionary *rowDictionary = [self makeDictionaryForTableViewRow:fsItem subLevel:0];
        [_resultArray addObject:rowDictionary];
    }
    
    for (FSItem *thisItem in fsItem.directoryContents) {
        if (thisItem == nil)
            continue;
        if ([[thisItem isDirectory] boolValue] == NO)
            continue;
        if ([[thisItem isDirectory] boolValue]) {
            [self recurseTaggedItems:thisItem tags:tagPattern subLevel:0];
        }
    }
}

-(NSDictionary*)makeDictionaryForTableViewRow:(FSItem*)fsItem subLevel:(int)subLevel {
    NSString *rootPath = _rootDirectory.path; //[fsItem.rootScanData.fileURL path];
    NSString *simplePath = extractRootFromPath(rootPath, fsItem.path);
    
    id theDate = fsItem.scanData.latestRecursiveFileDate != nil ? fsItem.scanData.latestRecursiveFileDate : [NSNull null];
    
    NSDictionary *rowDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                   theDate, @"date",
                                   fsItem.fileSize, @"size",
                                   simplePath, @"path",
                                   fsItem, @"fsitem",
                                   @(subLevel), @"sublevel",
                                   getTagString(fsItem.tags), @"tags",
                                   nil];
    return rowDictionary;
}



-(instancetype)init{
    if (self = [super init]) {
        _resultArray = [[NSMutableArray alloc] initWithCapacity:200];
    }
    return self;
}


@end
