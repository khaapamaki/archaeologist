//
//  ResultTableViewController.h
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 18.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FSItem.h"
#import "ResultTableView.h"

@interface ResultTableViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate> {
    NSArray *_lastUsedSortDescriptors;
}

@property (nonatomic) BOOL ageFormat;
@property (nonatomic) NSMutableArray *tableContents;
@property (weak) IBOutlet ResultTableView *resultTableView;
@property (nonatomic) BOOL useDirectoryDates;
@property (weak) IBOutlet NSScrollView *resultScrollView;
@property (weak) IBOutlet NSScroller *verticalScroller;

-(NSArray*)getFSItemsByIndexSet:(NSIndexSet *)indexes;

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView; // NSTableViewDataSource

-(id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row; // NSTableViewDelegate

-(void)reload;

//DATA in resultTableView 
//NSDictionary *rowDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                               theDate, @"date",
//                               fsItem.fileSize, @"size",
//                               simplePath, @"path",
//                               fsItem, @"fsitem",
//                               [NSNumber numberWithInt:subLevel], @"sublevel",
//                               nil];

@end
