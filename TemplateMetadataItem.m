//
//  TemplateMetadataItem.m
//  Lonkero
//
//  Created by Kati Haapamäki on 21.11.2013.
//  Copyright (c) 2013 Kati Haapamäki. All rights reserved.
//

#import "TemplateMetadataItem.h"


@implementation TemplateMetadataItem

/**
 *  Reads directory contents form the original template location and stores it
 *
 *  Is used for master level metadata items to store extra data about deployed templete
 *
 *  @see readDeployedDirectoryContents
 */
-(void)readTemplateDirectoryContents {

}


/**
 *  Sets master folder flag to YES and parent folder flag to NO, and sets depth to a given value.
 *
 *  @param depth A depth
 */

-(void)setAsMasterFolderAsDepthOf:(NSInteger) depth {
    _isMasterFolder = @YES;
    _isParentFolder = @NO;
    _depth = @(depth);
}
/**
 *  Sets parent folder flag to YES and master folder flag to NO, and sets depth to a given value.
 *
 *  @param depth A depth
 */
-(void)setAsParenFolderAsDepthOf:(NSInteger)depth {
    _isMasterFolder = @NO;
    _isParentFolder = @YES;
    _isTargetFolder = @NO;
    _depth = @(depth);
}

/**
 *  Sets target folder flag to YES and parent folder flag to NO, and sets depth to 0.
 *
 *  @note Target folder can also be a master folder at the same time, but not a parent.
 *
 *  Target folder simply means the root folder of the whole deployment process. Folder above parent folders.
 *  Master folder is the root for the template structure, below parent folders
 */

-(void)setAsTargetFolder {
    // don't get confused here, target can be master but not a parent.
    _isTargetFolder = @YES;
    _isParentFolder = @NO;
    _depth = @0;
}

-(void) encodeWithCoder: (NSCoder *) coder {


}

-(id) initWithCoder:(NSCoder *) coder {
//    _metadataVersion = [coder decodeObjectForKey:@"metadataVersion"];
//    _deploymentID = [coder decodeObjectForKey:@"deploymentID"];
//    _templateID = [coder decodeObjectForKey:@"templateID"];
//    _groupID = [coder decodeObjectForKey:@"groupID"];
//    _creationDate = [coder decodeObjectForKey:@"creationDate"];
//    _creator = [coder decodeObjectForKey:@"creator"];
//    _creatorFullName = [coder decodeObjectForKey:@"creatorFullName"];
    _isMasterFolder = [coder decodeObjectForKey:@"isMasterFolder"];
    _isParentFolder = [coder decodeObjectForKey:@"isParentFolder"];
    _isTargetFolder = [coder decodeObjectForKey:@"isTargetFolder"];
    _depth = [coder decodeObjectForKey:@"depthInFolderHierarchy"];
//    _creationRootFolder = [coder decodeObjectForKey:@"rootFolder"];
//    _creationMasterFolder = [coder decodeObjectForKey:@"masterFolder"];
//    _templateContents = [coder decodeObjectForKey:@"templateDirectoryContents"];
//    _deployedContents = [coder decodeObjectForKey:@"deployedDirectoryContents"];
//    _parametersForParentLevel = [coder decodeObjectForKey:@"usedParametersTillParentLevel"];
//    _isArchived = [coder decodeObjectForKey:@"isArchived"];
//    _markedToBeArchived = [coder decodeObjectForKey:@"isMarkedToBeArchived"];
//    _isRemoved = [coder decodeObjectForKey:@"isRemoved"];
//    _isPartialDeployment = [coder decodeObjectForKey:@"isPartialDeployment"];
//    _isAdditionalDeployment = [coder decodeObjectForKey:@"isAdditionalDeployment"];
//    _archiveLocation = [coder decodeObjectForKey:@"archiveLocation"];
//    _archiveDescription = [coder decodeObjectForKey:@"archiveDescription"];
//    _parentFolders = [coder decodeObjectForKey:@"parentFolders"];

    return self;
}

-(id)init {
    if (self = [super init]) {
//        _groupID = @"";
//        _templateID = @"";
//        _deploymentID = @"";
//        _creationRootFolder = nil;
//        _templateContents = @[];
//        _deployedContents = @[];
//        _isArchived = @NO;
//        _markedToBeArchived = @NO;
//        _isRemoved = @NO;
//        _isAdditionalDeployment = @NO;
//        _archiveLocation = [[FileSystemItem alloc] init];
//        _archiveDescription = @"";
//        _depth = @0L;
//        _creationDate = [NSDate date];
//        _creator = NSUserName();
//        _creatorFullName = NSFullUserName();
//        _parametersForParentLevel = [[NSDictionary alloc] init];
//        _parentFolders = [NSArray array];
        _isMasterFolder = @NO;
        _isParentFolder = @NO;
        _isTargetFolder = @NO;
    }
    return self;
}

@end
