//
//  FSItem.h
//  File System Item
//
//  Created by Kati Haapamäki on 12.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSScanData.h"
#import "UtilityFunctions.h"
#import "TemplateMetadata.h"
#import "Definitions.h"

@interface FSItem : NSObject {
    BOOL _amIScanRoot;
}

@property BOOL isCancelled;
@property (atomic) NSURL *fileURL;
@property (atomic, copy) NSString *path;
@property (atomic) NSNumber *isDirectory;
@property (atomic) NSNumber *fileSize;
@property (atomic) NSArray *directoryContents; // nil if not read
@property (atomic) NSNumber *isMarkedForArchiving;
@property (atomic) NSNumber *isMarkedForRemoval;
@property (atomic) NSNumber *isMarkedAsCandidate;
@property (atomic) NSNumber *isMarkedForChecking;
@property (atomic) NSNumber *tags;
@property (atomic) FSScanData *scanData;
@property (atomic) FSScanData *rootScanData;
@property (atomic, weak) FSItem *parent;
@property (atomic) NSDate *creationDate;
@property (atomic) NSDate *modificationDate;
@property (atomic) BOOL contentsFullyRead;
@property (atomic) NSNumber *isHidden;
@property (readonly) BOOL isLonkeroFolder;
@property NSNumber *isLonkeroMaster;
@property NSNumber *isLonkeroParent;
@property NSNumber *isLonkeroRoot;
@property long initialScanningDepth;
/*
@property (nonatomic) NSInteger labelNumber;
@property (nonatomic) NSNumber *isAlias;
@property (nonatomic) NSNumber *isPackage;

@property (nonatomic) NSNumber *hasHiddenExtension;
@property (nonatomic) NSNumber *posix;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *ownerName;
*/

-(void)setFileURL:(NSURL *)fileURL depth:(long)depth foldersOnly:(BOOL)foldersOnly;
-(void)setPath:(NSString *)path depth:(long)depth foldersOnly:(BOOL)foldersOnly;

-(NSDate*)latestRecursiveModificationDate;
-(NSDate*)earliestRecursiveModificationDate;

// does the scanning recursively
-(instancetype)initWithURL:(NSURL*)fileURL depth:(long)depth foldersOnly:(BOOL)foldersOnly;

// set/unset archive flags
-(BOOL)markForArchiving;
-(BOOL)unmarkForArchiving;
-(BOOL)markForRemoval;
-(BOOL)unmarkForRemoval;
-(BOOL)setTag:(NSString *)tagString;
-(BOOL)setTagByPattern:(TagType)tag;
-(BOOL)removeTag:(NSString *)tagString;
-(BOOL)removeTagByPattern:(TagType)tag;
-(BOOL)hasTag:(NSString *)tagString;
-(void)printDebugInfo;
-(void)printProgressInfoWithNewLine:(BOOL)newLine;

@end
