//
//  FSItem.m
//  File System Item
//
//  Created by Kati Haapamäki on 12.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import "FSItem.h"


@implementation FSItem

#pragma mark - Notifications

-(void)cancelScan:(id)sender {
    _rootScanData.isCancelled = YES; // rootScanData is seen for all recursive levels
    _contentsFullyRead = NO;
}


#pragma mark - Scan

// for rereading
-(void)setFileURL:(NSURL *)fileURL depth:(long)depth foldersOnly:(BOOL)foldersOnly {
    _contentsFullyRead = NO;
    FSScanData *rootScanData = [[FSScanData alloc] init];
    rootScanData.fileURL = fileURL;
    rootScanData.foldersOnly = foldersOnly;
    _rootScanData = rootScanData;
    FSScanData *myScanData = [[FSScanData alloc] init];
    myScanData.fileURL = fileURL;
    _scanData = myScanData;
    _fileURL = fileURL;
    _path = [_fileURL path];
    [self readFileParametersWithDepth:depth];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ScanTreeDisplayProgressTime"
     object:self];
    [_scanData setScanEndTime:[NSDate date]];
}

// for rereading
-(void)setPath:(NSString *)path depth:(long)depth foldersOnly:(BOOL)foldersOnly {
    _contentsFullyRead = NO;
    _path = [path stringByExpandingTildeInPath];
    _fileURL = [NSURL fileURLWithPath:_path];
    
    FSScanData *rootScanData = [[FSScanData alloc] init];
    rootScanData.fileURL = _fileURL;
    rootScanData.foldersOnly = foldersOnly;
    _rootScanData = rootScanData;
    FSScanData *myScanData = [[FSScanData alloc] init];
    myScanData.fileURL = _fileURL;
    _scanData = myScanData;
    _path = [_fileURL path];
    [self readFileParametersWithDepth:depth];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ScanTreeDisplayProgressTime"
     object:self];
}

-(void)readFileParametersWithDepth:(long)depth {
    NSNumber *isDirectory = @NO;
    NSDate *modificationDate = nil;
    NSNumber *isHidden = @NO;
    NSMutableArray *nameTags = nil;
    [_fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
    [_fileURL getResourceValue:&modificationDate forKey:NSURLContentModificationDateKey error:nil];
    [_fileURL getResourceValue:&isHidden forKey:NSURLIsHiddenKey error:nil];
    [_fileURL getResourceValue:&nameTags forKey:NSURLTagNamesKey error:nil];
    
    _isDirectory = isDirectory;
    _modificationDate = modificationDate;
    _isHidden = isHidden;
    
    // check user-cancellation status
    if (_rootScanData.isCancelled == YES) {
        _isCancelled = YES;
        return;
    }
    
    if ([_rootScanData.lastProgressDisplayTime timeIntervalSinceNow] < -(DISPLAYTIMEINTERVAL)) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ScanTreeDisplayProgressTime"
         object:self];
        [_rootScanData setProgressDisplayTime];
    }
    
    if (![isDirectory boolValue]) {
        // I am FILE
        NSNumber *fileSize = @0;
        [_fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        _fileSize = [fileSize copy];
        _scanData = nil; // no scan data for file
        if ([_isHidden boolValue] == NO) {
            [_rootScanData incrementByteCountBy:[_fileSize longLongValue]];
            [_rootScanData incrementFileCount];
        }
        
    } else {
        // I am DIRECTORY -> dig in deeper?
        
        if ([_isHidden boolValue] == NO) {
            [_rootScanData incrementDirectoryCount];
            
            _fileSize = @0;
            _scanData.recursiveFileCounter = 0;
            _scanData.recursiveDirectoryCounter = 0;
            
            if (depth > 0) {
                _directoryContents = [self readDirectoryContentsWithRemainingDepth:depth-1];
            }
            if (depth < 0) { // infinite depth
                _directoryContents = [self readDirectoryContentsWithRemainingDepth:depth];
                _contentsFullyRead = YES;
            }
            
            TagType tagPattern = 0;
            if (nameTags != nil) {
                if ([nameTags containsObject:ARCHIVETAG] == YES) {
                    tagPattern |= ArchiveTag;
                }
                if ([nameTags containsObject:DELETETAG] == YES) {
                    tagPattern |= DeleteTag;
                }
                if ([nameTags containsObject:CANDIDATETAG] == YES) {
                    tagPattern |= CandidateTag;
                }
                if ([nameTags containsObject:CHECKTAG] == YES) {
                    tagPattern |= CheckTag;
                }
            }
            _tags = @(tagPattern);
        }
    }
}

-(NSArray*)readDirectoryContentsWithRemainingDepth:(long)depth {
    NSMutableArray *contents = [[NSMutableArray alloc] initWithCapacity:1000];
    int dirEnumOptions = NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants ; // mandatory, recursion is handled manually
    
    // Piilotiedostoja ei voi jättää pois koska lonkero metadata pitää voida lukea
    //dirEnumOptions |=  NSDirectoryEnumerationSkipsHiddenFiles;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtURL:_fileURL
                              includingPropertiesForKeys:[NSArray arrayWithObjects:
                                                          NSURLNameKey,
                                                          NSURLIsDirectoryKey,
                                                          NSURLContentModificationDateKey,
                                                          NSURLFileSizeKey,
                                                          NSURLIsPackageKey,
                                                          NSURLIsAliasFileKey,
                                                          NSURLIsHiddenKey,
                                                          NSURLHasHiddenExtensionKey,
                                                          NSURLTagNamesKey,
                                                          nil]
                                                 options:dirEnumOptions
                                            errorHandler:nil];
    
    // initialize direct non-recursive content data
    NSDate *latestFileDate = nil;
    NSDate *latestDirectoryDate = nil;
    _scanData.latestDirectoryPath = nil;
    NSDate *earliestFileDate = nil;
    NSDate *earliestDirectoryDate = nil;
    // initialize recursive content data
    NSDate *latestRecursiveFileDate = nil;
    NSDate *latestRecursiveDirectoryDate = nil;
    _scanData.latestRecursiveDirectoryPath = nil;
    NSDate *earliestRecursiveFileDate = nil;
    NSDate *earliestRecursiveDirectoryDate = nil;
    
    //long long myFileSize = 0;
    _scanData.recursiveFileCounter = 0;
    _scanData.recursiveDirectoryCounter = 0;
    
    for (NSURL *thisURL in dirEnum) {
        
        FSItem *newItem = [[FSItem alloc] initAndScanWithURL:thisURL depth:depth rootScanData:_rootScanData];
        
        newItem.parent = self; // must be weak! backreference, not much used atm
        
        // calculate folder size
        
        if ([newItem.isHidden boolValue] == NO) {
            _fileSize = @([_fileSize longLongValue] + [newItem.fileSize longLongValue]);
        }
        
        if (([newItem.isDirectory boolValue] || _rootScanData.foldersOnly == NO) && [newItem.isHidden boolValue] == NO) {
            [contents addObject:newItem];
        }
        
        // Date comparison and file/folder counters
        // ----------------------------------------
        // (hidden items are not taken into account in date comparison, this could be optional...)
        
        if ([newItem.isDirectory boolValue]) {
            // Child is DIRECTORY
            // if ([newItem.isHidden boolValue] == NO) myFolderCounter++;
            if ([newItem.isHidden boolValue] == NO) {
                
                BOOL isNewDirecetoryDateLater = ([latestDirectoryDate compare:newItem.modificationDate] == NSOrderedAscending || latestDirectoryDate == nil) && newItem.modificationDate != nil;
                if (isNewDirecetoryDateLater) {
                    latestDirectoryDate = newItem.modificationDate;
                    _scanData.latestDirectoryPath = newItem.path;
                }
                
                BOOL isNewDirecetoryDateEarlier = ([earliestDirectoryDate compare:newItem.modificationDate] == NSOrderedDescending || earliestDirectoryDate == nil) && newItem.modificationDate != nil;
                if (isNewDirecetoryDateEarlier) {
                    earliestDirectoryDate = newItem.modificationDate;
                    _scanData.earliestDirectoryPath = newItem.path;
                }
                
                // alikansiossa ei välttämättä ole yhtään alikansiota, siinä tapauksessa käytätään suoraan tämän alikansion dataa rekursion alkupisteenä
                NSDate *compareDate = newItem.scanData.directoryCounter > 0 ? newItem.scanData.latestRecursiveDirectoryDate : newItem.modificationDate;
                NSString *comparePath = newItem.scanData.directoryCounter > 0 ? newItem.scanData.latestRecursiveDirectoryPath : newItem.path;
                
                BOOL isNewRecursiveDirectoryDateLater = ([latestRecursiveDirectoryDate compare:compareDate] == NSOrderedAscending
                                                         || latestRecursiveDirectoryDate == nil)
                                                            && compareDate != nil;
                if (isNewRecursiveDirectoryDateLater) {
                    latestRecursiveDirectoryDate = compareDate;
                    _scanData.latestRecursiveDirectoryPath = comparePath;
                }
                
                BOOL isNewRecursiveDirectoryDateEarlier =
                    ([earliestRecursiveDirectoryDate compare:compareDate] == NSOrderedDescending
                                                           || earliestRecursiveDirectoryDate == nil)
                                                            && compareDate != nil;
                if (isNewRecursiveDirectoryDateEarlier) {
                    earliestRecursiveDirectoryDate = compareDate;
                    _scanData.earliestRecursiveDirectoryPath = comparePath;
                }
                
                BOOL isNewRecursiveFileDateLater = ([latestRecursiveFileDate compare:newItem.scanData.latestRecursiveFileDate] == NSOrderedAscending || latestRecursiveFileDate == nil) && newItem.scanData.latestRecursiveFileDate != nil;
                if (isNewRecursiveFileDateLater) {
                    latestRecursiveFileDate = newItem.scanData.latestRecursiveFileDate;
                    _scanData.latestRecursiveFilePath = newItem.scanData.latestRecursiveFilePath;
                }
                
                BOOL isNewRecursiveFileDateEarlier = ([earliestRecursiveFileDate compare:newItem.scanData.earliestRecursiveFileDate] == NSOrderedDescending || earliestRecursiveFileDate == nil) && newItem.scanData.earliestRecursiveFileDate != nil;
                if (isNewRecursiveFileDateEarlier) {
                    earliestRecursiveFileDate = newItem.scanData.earliestRecursiveFileDate;
                    _scanData.earliestRecursiveFilePath = newItem.scanData.earliestRecursiveFilePath;
                }                
            }
            
            // read recursive data from child dir
            if ([newItem.isHidden boolValue] == NO) {
                _scanData.directoryCounter += 1;
                _scanData.recursiveDirectoryCounter += 1;
            }
            _scanData.recursiveDirectoryCounter += newItem.scanData.recursiveDirectoryCounter;
            _scanData.recursiveFileCounter += newItem.scanData.recursiveFileCounter;
            
        } else {
            
            // Child is FILE
            
            if ([newItem.isHidden boolValue] == NO) {
               // myFileSize += [newItem.fileSize longLongValue];
                
                BOOL isNewFileDateLater = ([latestFileDate compare:newItem.modificationDate] == NSOrderedAscending || latestFileDate == nil) && newItem.modificationDate != nil;
                if (isNewFileDateLater) {
                    latestFileDate = newItem.modificationDate;
                    _scanData.latestFilePath = newItem.path;
                    
                }
                BOOL isNewFileDateEarlier = ([earliestFileDate compare:newItem.modificationDate] == NSOrderedDescending || earliestFileDate == nil) && newItem.modificationDate != nil;
                if (isNewFileDateEarlier) {
                    earliestFileDate = newItem.modificationDate;
                    _scanData.earliestFilePath = newItem.path;
                    
                }
                BOOL isNewRecursiveFileDateLater = ([latestRecursiveFileDate compare:newItem.modificationDate] == NSOrderedAscending || latestRecursiveFileDate == nil) && newItem.modificationDate != nil;
                if (isNewRecursiveFileDateLater) {
                    latestRecursiveFileDate = newItem.modificationDate;
                    _scanData.latestRecursiveFilePath = newItem.path;
                }
                
                BOOL isNewRecursiveFileDateEarlier = ([earliestRecursiveFileDate compare:newItem.modificationDate] == NSOrderedDescending || earliestRecursiveFileDate == nil) && newItem.modificationDate != nil;
                if (isNewRecursiveFileDateEarlier) {
                    earliestRecursiveFileDate = newItem.modificationDate;
                    _scanData.earliestRecursiveFilePath = newItem.path;
                }
                
                // latestFile = newItem;
                _scanData.fileCounter += 1;
                _scanData.recursiveFileCounter += 1;
            } else {
                
            }
        }
        
        // ---- LONKERO SPECIAL ---
        if ([newItem.isDirectory boolValue] == NO && [[newItem.path lastPathComponent] isEqualToString:@".Template Metadata.plist"]) {
            _isLonkeroFolder = YES;
            NSNumber *isRoot = @NO;
            NSNumber *isParent = @NO;
            NSNumber *isMaster = @NO;
            TemplateMetadata *lonkeroMetadata = [[TemplateMetadata alloc] initByReadingFromFolder:newItem.path isRoot:&isRoot Parent:&isParent Master:&isMaster];
            _isLonkeroMaster = isMaster;
            _isLonkeroParent = isParent;
            _isLonkeroRoot = isRoot;
            lonkeroMetadata = nil;
        }
        
        // ------------------------
    }
    
    // direct non-recursive content data
    _scanData.latestDirectoryDate = latestDirectoryDate;
    _scanData.latestFileDate = latestFileDate;
    _scanData.earliestDirectoryDate = earliestDirectoryDate;
    _scanData.earliestFileDate = earliestFileDate;
    
    // recursive content data
    _scanData.latestRecursiveFileDate = latestRecursiveFileDate;
    _scanData.latestRecursiveDirectoryDate = latestRecursiveDirectoryDate;
    _scanData.earliestRecursiveFileDate = earliestRecursiveFileDate;
    _scanData.earliestRecursiveDirectoryDate = earliestRecursiveDirectoryDate;
    
    NSArray *result = [contents copy];
    contents = nil; // release
    
    return result;
}

#pragma mark - File Operations

-(BOOL)setTagByPattern:(TagType) tag {
    TagType currentTags = [_tags shortValue];
    if ((tag & ArchiveTag) != 0) {
        if ([self setTag:ARCHIVETAG]) {
            _tags = @([_tags shortValue] | ArchiveTag);
        }
    }
    if ((tag & DeleteTag) != 0) {
        if ([self setTag:DELETETAG]) {
            _tags = @([_tags shortValue] | DeleteTag);
        }
    }
    if ((tag & CandidateTag) != 0) {
        if ([self setTag:CANDIDATETAG]) {
            _tags = @([_tags shortValue] | CandidateTag);
        }
    }
    if ((tag & CheckTag) != 0) {
        if ([self setTag:CHECKTAG]) {
            _tags = @([_tags shortValue] | CheckTag);
        }
    }
    if (currentTags != [_tags shortValue]) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)removeTagByPattern:(TagType) tag {
    TagType currentTags = [_tags shortValue];
    if ((tag & ArchiveTag) != 0) {
        if ([self removeTag:ARCHIVETAG]) {
                _tags = @([_tags shortValue] & ~ArchiveTag);
        }
    }
    if ((tag & DeleteTag) != 0) {
        if ([self removeTag:DELETETAG]) {
            _tags = @([_tags shortValue] & ~DeleteTag);
        }
    }
    if ((tag & CandidateTag) != 0) {
        if ([self removeTag:CANDIDATETAG]) {
            _tags = @([_tags shortValue] & ~CandidateTag);
        }
    }
    if ((tag & CheckTag) != 0) {
        if ([self removeTag:CHECKTAG]) {
            _tags = @([_tags shortValue] & ~CheckTag);
        }
    }
    if (currentTags != [_tags shortValue]) {
        return YES;
    } else {
        return NO;
    }
}


-(BOOL)setTag:(NSString *)tagString {
    @try {
        if ([self hasTag:tagString]) {
            return NO;
        }
        NSMutableArray *existingTags = nil;
        [_fileURL getResourceValue:&existingTags forKey:NSURLTagNamesKey error:nil];
        if (existingTags == nil) {
            existingTags = [NSMutableArray arrayWithCapacity:1];
        }
        [existingTags addObject:tagString];
        [_fileURL setResourceValue:existingTags forKey:NSURLTagNamesKey error:nil];
        return YES;
    }
    @catch(NSException * e) {
        
    }
    return NO;
}

-(BOOL)removeTag:(NSString *)tagString {
    @try {
        if (![self hasTag:tagString]) {
            return NO;
        }
        NSMutableArray *existingTags = nil;
        [_fileURL getResourceValue:&existingTags forKey:NSURLTagNamesKey error:nil];
        [existingTags removeObject:tagString];
        [_fileURL setResourceValue:existingTags forKey:NSURLTagNamesKey error:nil];
        return YES;
    }
    @catch(NSException * e) {
        
    }
    return NO;
}

-(BOOL)hasTag:(NSString *)tagString {
    NSMutableArray *existingTags = nil;
    [_fileURL getResourceValue:&existingTags forKey:NSURLTagNamesKey error:nil];
    if ([existingTags containsObject:tagString]) {
        return YES;
    }
    return NO;
}

#pragma mark - Cool Stuff

-(NSDate*)latestRecursiveModificationDate {
    if ([_isDirectory boolValue] == NO) {
        return _modificationDate;
    }
    if (_modificationDate == nil) {
        return _scanData.latestRecursiveDirectoryDate;
    }
    if (_scanData.latestRecursiveDirectoryDate == nil) {
        return _modificationDate;
    }
    return [[_modificationDate laterDate:_scanData.latestRecursiveDirectoryDate]
            laterDate:_scanData.latestRecursiveFileDate];
}

-(NSDate*)earliestRecursiveModificationDate {
    if ([_isDirectory boolValue] == NO) {
        return _modificationDate;
    }
    if (_modificationDate == nil) {
        return _scanData.earliestRecursiveDirectoryDate;
    }
    if (_scanData.earliestRecursiveDirectoryDate == nil) {
        return _modificationDate;
    }
    return [[_modificationDate earlierDate:_scanData.earliestRecursiveDirectoryDate]
            earlierDate:_scanData.earliestRecursiveFileDate];
}

#pragma mark - Print info

-(void)printDebugInfo {
    NSString *simplePath = [NSString stringWithFormat:@"%@%@",
                            [[self.scanData.fileURL path] lastPathComponent],
                            [self.path substringFromIndex:[[self.scanData.fileURL path] length]]];
    
    
    if ([_isDirectory boolValue]) {
        printStdErrWithFormat(@"DIR:  %@ %@ (%@)\n", _modificationDate, simplePath, convertToFileSizeString([_fileSize longLongValue]));
        
    } else {
        printStdErrWithFormat(@"FILE: %@ %@ (%@)\n", _modificationDate, simplePath, convertToFileSizeString([_fileSize longLongValue]));
    }
}

-(void)printProgressInfoWithNewLine:(BOOL)newLine {
    
    NSString *fSize = convertToFileSizeString(self.scanData.byteCount);
    
    NSString *info = [NSString stringWithFormat:@"Scanned: %ld folders, %ld files, %@        %@",
                      self.scanData.directoryCounter,
                      self.scanData.fileCounter,
                      fSize,
                      newLine ? @"\n" : @"\r" ];
    printStdOut(info);
    fflush(__stdoutp);
}

#pragma mark - Init

-(instancetype)initWithURL:(NSURL*)fileURL depth:(long)depth foldersOnly:(BOOL)foldersOnly {
    if (self = [super init]) {
        _contentsFullyRead = NO;
        _amIScanRoot = YES;
        FSScanData *rootScanData = [[FSScanData alloc] init];
        rootScanData.fileURL = fileURL;
        rootScanData.foldersOnly = foldersOnly;
        _rootScanData = rootScanData;
        FSScanData *myScanData = [[FSScanData alloc] init];
        myScanData.fileURL = fileURL;
        _scanData = myScanData;
        _fileURL = fileURL;
        _path = [_fileURL path];
        _tags = @(0);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cancelScan:)
                                                     name:@"CancelScan"
                                                   object:nil];

        [self readFileParametersWithDepth:depth];
        
        if (_rootScanData.isCancelled == YES) _isCancelled = YES;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CancelScan" object:nil];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ScanTreeDisplayProgressTime"
         object:self];
    }
    return self;
}

/**
 Initializes new FSItem and continue scanning. Used only internally when rootScanData is initilized

 @param fileURL URL to be scanned
 @param depth depth for recursion, negative means no limits
 @param scanData overall data about the scanning process
 @return initialized FSItem
 */
-(instancetype)initAndScanWithURL:(NSURL*)fileURL depth:(long)depth rootScanData:(FSScanData*)scanData {
    if (self = [super init]) {
        _contentsFullyRead = NO;
        _initialScanningDepth = depth;
        _amIScanRoot = NO;
        FSScanData *myScanData = [[FSScanData alloc] init];
        myScanData.fileURL = fileURL;
        _scanData = myScanData;
        _rootScanData = scanData;
        _fileURL = fileURL;
        _path = [_fileURL path];
        _isCancelled = NO;
        _tags = @(0);
        [self readFileParametersWithDepth:depth];
    }
    return self;
}

-(instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

-(void) dealloc {

}

@end
