//
//  ResultTableViewController.m
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 18.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import "ResultTableViewController.h"
#import "AppDelegate.h"

@interface ResultTableViewController ()

@end

@implementation ResultTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _tableContents = nil;
    _useDirectoryDates = NO;
}

-(void)awakeFromNib {
    NSTableColumn *dateColumn = [_resultTableView tableColumnWithIdentifier:@"date"];
    NSTableColumn *sizeColumn = [_resultTableView tableColumnWithIdentifier:@"size"];
    NSTableColumn *pathColumn = [_resultTableView tableColumnWithIdentifier:@"path"];
    NSTableColumn *archiveColumn = [_resultTableView tableColumnWithIdentifier:@"tags"];
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date"
                                                                         ascending:YES
                                                                          selector:@selector(compare:)];
    
    NSSortDescriptor *sizeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"size"
                                                                         ascending:YES
                                                                          selector:@selector(compare:)];
    
    NSSortDescriptor *pathSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"path"
                                                                         ascending:YES
                                                                          selector:@selector(caseInsensitiveCompare:)];
    
    NSSortDescriptor *archiveSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tags"
                                                                            ascending:YES
                                                                             selector:@selector(caseInsensitiveCompare:)];
    
    [dateColumn setSortDescriptorPrototype:dateSortDescriptor];
    [sizeColumn setSortDescriptorPrototype:sizeSortDescriptor];
    [pathColumn setSortDescriptorPrototype:pathSortDescriptor];
    [archiveColumn setSortDescriptorPrototype:archiveSortDescriptor];
    
    _resultTableView.tableContents = _tableContents;
}

#pragma mark - Setters and Getters 

-(void)setTableContents:(NSMutableArray *)tableContents {
    //NSArray * visibleRows = [_resultTableView visibleRows];
    
    NSSortDescriptor *defaultSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"path"
                                                                         ascending:YES
                                                                          selector:@selector(caseInsensitiveCompare:)];
    _tableContents = tableContents;
    if (_lastUsedSortDescriptors == nil) {
        _lastUsedSortDescriptors = [NSArray arrayWithObject:defaultSortDescriptor];
    }
    
    [_tableContents sortUsingDescriptors:_lastUsedSortDescriptors];
    _resultTableView.tableContents = _tableContents;
    
    [_resultTableView reloadData];
    
    // scroll to previous position if possible
    
    
    //[_resultTableView scrollRowToVisible:[self firstFoundRowInLastVisibleRows:visibleRows]];
}

-(NSArray*)getFSItemsByIndexSet:(NSIndexSet *)indexes {
    NSUInteger rowIndex = 0;
    NSMutableArray *selectedFSItems = [[NSMutableArray alloc] initWithCapacity:[_tableContents count]];
    for (NSDictionary *rowData in _tableContents) {
        if ([indexes containsIndex:rowIndex]) {
            [selectedFSItems addObject:[rowData objectForKey:@"fsitem"]];
        }
        rowIndex++;
    }
    return [NSArray arrayWithArray:selectedFSItems];
}

#pragma mark - Delegation and Data Source Protocol

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (_tableContents == nil)
        return 0;
    return [_tableContents count];
}

// Draw table
-(id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSTableCellView *result;
    // get contents from this array
    NSDictionary *item = [_tableContents objectAtIndex:row];
    if ([item isKindOfClass:[NSDictionary class]]) {
        
        if ([tableColumn.identifier isEqualToString:@"tags"]) {
            result = [tableView makeViewWithIdentifier:@"tagView" owner:self];
            FSItem *folder = [item objectForKey:@"fsitem"];
            if (folder != nil) {
                result.textField.stringValue = [item objectForKey:@"tags"];
            } else {
                result.textField.stringValue = @"";
            }
       
        } else if ([tableColumn.identifier isEqualToString:@"date"]) {
            result = [tableView makeViewWithIdentifier:@"dateView" owner:self];
            id dateObject = [item objectForKey:@"date"];
            if (dateObject != nil && dateObject != [NSNull null]) {
                result.textField.objectValue = dateObject;
            } else {
                result.textField.objectValue = @"";
            }
            
        } else if ([tableColumn.identifier isEqualToString:@"size"]) {
            result = [tableView makeViewWithIdentifier:@"sizeView" owner:self];
            if ([[item objectForKey:@"fsitem"] contentsFullyRead]) {
                NSString *fileSize = [NSString stringWithFormat:@"%@", convertToFileSizeString([[item objectForKey:@"size"] longLongValue])];
                result.textField.stringValue = fileSize;
            } else {
                result.textField.stringValue = @"?";
            }
            
        } else if ([tableColumn.identifier isEqualToString:@"path"]) {
            result = [tableView makeViewWithIdentifier:@"pathView" owner:self];
            NSNumber *prefixCount = [item objectForKey:@"sublevel"];
            int pref = [prefixCount intValue]; // indentation if parent is also displayed
            result.textField.stringValue = [NSString stringWithFormat:@"%@%@%@",
                                            [@"" stringByPaddingToLength:pref withString:@"-" startingAtIndex:0],
                                            pref > 0 ? @" " : @"",
                                            [item objectForKey:@"path"]];
            
        } else if ([tableColumn.identifier isEqualToString:@"lonkero"]) {
            result = [tableView makeViewWithIdentifier:@"lonkeroView" owner:self];
            FSItem *fsitem = [item objectForKey:@"fsitem"];
            NSMutableString *str = [NSMutableString new];
            if (fsitem.isLonkeroFolder) {
                //[str appendString:[fsitem.isLonkeroRoot boolValue] ? @"R" : @""];
                [str appendString:([fsitem.isLonkeroParent boolValue] || [fsitem.isLonkeroRoot boolValue]) ? @"Parent" : @""];
                [str appendString:[fsitem.isLonkeroMaster boolValue] ? @"Master" : @""];
                int test = [fsitem.isLonkeroRoot boolValue] ? 1 : 0
                + [fsitem.isLonkeroMaster boolValue] ? 1 : 0
                + [fsitem.isLonkeroParent boolValue] ? 1 : 0;
                if (test == 0) {
                    [str appendString:@""];
                }
            }

            result.textField.stringValue = str;
            
        }  else {
            result = [tableView makeViewWithIdentifier:@"dateView" owner:self];
            result.textField.stringValue = @""; //error
        }
        
    } else {
        result = [tableView makeViewWithIdentifier:@"dateView" owner:self];
        result.textField.stringValue = @""; // error
    }
    return result;
}

#pragma mark - Sorting

-(void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    _lastUsedSortDescriptors = [tableView sortDescriptors];
    [_tableContents sortUsingDescriptors:[tableView sortDescriptors]];
    [tableView reloadData];
}

#pragma mark - Display

-(void)reload {
    [_resultTableView reloadData];
}

-(NSUInteger)firstFoundRowInLastVisibleRows:(NSArray*)rows {
    // NOT IMPLEMENTED
    return 0;
}

@end
