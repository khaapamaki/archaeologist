//
//  FileSystemItem.h
//  Lonkero
//
//  Created by Kati Haapamäki on 31.10.2013.
//  Copyright (c) 2013 Kati Haapamäki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileSystemItem : NSObject <NSCopying>

@property (strong) NSString *path;
@property (strong) NSString *nickName;
@property BOOL isRootObject;
@property BOOL isExpanded;
@property BOOL isExpandable;
@property BOOL isDirectory;
@property long long fileSize;
@property NSDate *creationDate;
@property NSDate *modificationDate;
@property NSString *createdBy;
@property BOOL isLocked;
@property NSString *lockedBy;
@property BOOL isAlias;
@property BOOL isPackage;
@property NSString *relativePath;
@property NSInteger labelNumber;
@property BOOL hasHiddenExtension;
@property NSNumber *posix;
@property NSString *groupName;
@property NSString *ownerName;
@property NSNumber *groupId;
@property NSNumber *ownerId;
@property BOOL isParent;
@property BOOL isMaster;
@property BOOL isTarget;

// extras, not to be archived:

@property BOOL isCopied;
@property BOOL shouldCopy;
@property BOOL isPathToCopyValid;
@property BOOL pathToCopyExists;
@property BOOL pathToCopyIsDirectory;
@property BOOL itemExists;
@property NSString *pathToCopy;
@property NSImage *icon;
@property BOOL filteredOut;


-(NSURL *) URL;
-(NSURL *) fileURL;

-(id)initWithURL:(NSURL *)URL;
-(id)initWithPath:(NSString *)path andNickName:(NSString *)name;
-(id)initWithPathByAbbreviatingTildeInPath:(NSString *)path andNickName:(NSString *)name ;

-(NSString *) itemName;
-(NSString *) parentItemName;
-(NSString *) pathByExpandingTildeInPath;
-(void) setPathByAbbreviatingTildeInPath:(NSString *)path;
+(FileSystemItem *) systemRootFolder;
-(NSString *) URLStylePath;

+(BOOL)isURLDirectory:(NSURL *)URL;
-(void)setPropertiesByURL:(NSURL *) URL;
-(void)updateExistingStatus;
-(void)readPropertiesFromFileSystem;

@end
