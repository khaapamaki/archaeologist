//
//  TemplateMetadata.h
//  Lonkero
//
//  Created by Kati Haapamäki on 21.11.2013.
//  Copyright (c) 2013 Kati Haapamäki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TemplateMetadataItem.h"

@interface TemplateMetadata : NSObject

@property NSMutableArray *metadataArray;
-(void)addItem:(TemplateMetadataItem*)item;


-(id) initByReadingFromFolder:(NSString*)path isRoot:(NSNumber**)isRoot Parent:(NSNumber**)isParent Master:(NSNumber**)isMaster;
-(BOOL) hasAnyMaster;
-(BOOL) hasAnyParent;


@property BOOL hasParent;
@property BOOL hasMaster;
@property BOOL hasRoot;

@end
