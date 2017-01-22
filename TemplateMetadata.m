//
//  TemplateMetadata.m
//  Lonkero
//
//  Created by Kati Haapamäki on 21.11.2013.
//  Copyright (c) 2013 Kati Haapamäki. All rights reserved.
//

#import "TemplateMetadata.h"

@implementation TemplateMetadata


/**
 *  Returns number of items in the metadata array
 *
 *  @return NSInteger
 */

-(NSInteger)count {
    return [_metadataArray count];
}

/**
 *  Adds a new metadata item to the metadata array
 *
 *  @param item A metadata item to be added
 */

-(void)addItem:(TemplateMetadataItem *)item {
    [_metadataArray addObject:item];
}

/**
 *  Writes metadata to given folder
 *
 *  Uses METADATA_FILENAME as file name.
 *
 *  @param folder A folder to write metadata to
 */


-(void) encodeWithCoder: (NSCoder *) coder {

}

-(id) initWithCoder:(NSCoder *) coder {
    _metadataArray = [coder decodeObjectForKey:@"metadataArrayForTemplates"];
    return self;
}


-(id) initByReadingFromFolder:(NSString*)path isRoot:(NSNumber**)isRoot Parent:(NSNumber**)isParent Master:(NSNumber**)isMaster {
   // NSString *path = [NSString stringWithFormat:@"%@/%@", folder.pathByExpandingTildeInPath, @".Template Metadata.plist"];
    NSFileManager *fm = [[NSFileManager alloc] init];
    _hasMaster = NO;
    _hasParent = NO;
    _hasRoot = NO;
    if (self = [super init]) {
        if ([fm fileExistsAtPath:path]) {
            TemplateMetadata *newMetadata = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            [newMetadata checkAnyTypeIsRoot:isRoot Parent:isParent Master:isMaster];
            self = newMetadata;
        } else {
            _metadataArray = nil;
        }
    }
    return self;
}



-(BOOL)checkAnyTypeIsRoot:(NSNumber**)isRoot Parent:(NSNumber**)isParent Master:(NSNumber**)isMaster {
    for (TemplateMetadataItem *metaItem in _metadataArray) {
        if ([metaItem.isMasterFolder boolValue]) *isMaster = @YES;
        if ([metaItem.isParentFolder boolValue]) *isParent = @YES;
        if ([metaItem.isTargetFolder boolValue]) *isRoot = @YES;
    }
    return (*isParent || *isRoot || isMaster);
}

/**
 *  Returns YES is any metadata item of the metadata array is set as master
 *
 */

-(BOOL)hasAnyMaster {
    BOOL result = NO;
    for (TemplateMetadataItem *metaItem in _metadataArray) {
        if  ([metaItem.isMasterFolder boolValue]) result = YES;
    }
    return result;
}

/**
 *  Returns YES is any metadata item of the metadata array is set as parent
 *
 */

-(BOOL)hasAnyParent {
    for (TemplateMetadataItem *metaItem in _metadataArray) {
        if  ([metaItem.isParentFolder boolValue]) return YES;
    }
    return NO;
}

-(id) init {
    if (self = [super init]) {
        _metadataArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return self;
}
@end
