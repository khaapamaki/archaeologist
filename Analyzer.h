//
//  Analyzer.h
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 16.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSItem.h"
#import "UtilityFunctions.h"
#import "Definitions.h"
#import "NSDate+DateExtra.h"

@interface Analyzer : NSObject {
    BOOL _lonkeroMode;
}

@property (readonly) FSItem *rootDirectory;
@property (nonatomic) NSMutableArray *resultArray; // dictionary array for table view
@property (readonly) FSScanData *scanData;

-(void)scanDirectory:(FSItem*)fsItem olderThan:(NSDate*)dateThreshold minSize:(long)sizeThreshold minDepth:(long)minDepth maxDepth:(long)maxDepth;
-(void)scanDirectory:(FSItem*)fsItem olderThan:(NSDate*)dateThreshold minSize:(long)sizeThreshold minDepth:(long)minDepth maxDepth:(long)maxDepth options:(int)options;
-(void)scanTaggedItems:(FSItem*)fsItem tags:(TagType)tagPattern;

@end
