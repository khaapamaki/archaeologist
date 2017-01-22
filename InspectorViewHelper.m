//
//  InscpetorViewHelper.m
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 19.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import "InspectorViewHelper.h"

@implementation InspectorViewHelper

-(void)awakeFromNib {
    [_inspectorTableView setRowSizeStyle:NSTableViewRowSizeStyleCustom];
    [_inspectorTableView setNeedsDisplay:YES];
    [_inspectorTableView display];
}

-(void)inspectDirectoryItem:(FSItem*)fsItem {
    _inspectedItem = fsItem;
    [_inspectorTableView reloadData];
}

-(id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    NSTableCellView *result;

    if (_inspectedItem == nil && [tableColumn.identifier isEqualToString:@"fieldvalue"]) {
        result = [tableView makeViewWithIdentifier:@"multilineCell" owner:self];
        result.textField.stringValue = @"";
        return result;
    }

    NSString *fieldName = @"";

    switch (row) {
        case 0:
            fieldName = @"Path";
            break;
        case 1:
            fieldName = @"Contains:";
            break;
        case 2:
            fieldName = @"Total Size:";
            break;
        case 3:
            fieldName = @"Folder Modification Date:";
            break;
        case 4:
            fieldName = @"Newest File:";
            break;
        case 5:
            fieldName = @"Date:";
            break;
        case 6:
            fieldName = @"Oldest File:";
            break;
        case 7:
            fieldName = @"Date:";
            break;
        default:
            break;
    }

    if ([tableColumn.identifier isEqualToString:@"fieldname"]) {

        result = [tableView makeViewWithIdentifier:@"fieldnameCell" owner:self];
        result.textField.stringValue = [fieldName copy];
        return result;
    }

    result = [tableView makeViewWithIdentifier:@"multilineCell" owner:self];
    NSString *strValue = @"";

    switch (row) {
        case 0:
            strValue = _inspectedItem.path;
            break;
        case 1:
            strValue = [NSString stringWithFormat:@"%li file%@ in %li folder%@ (%li file%@ in %li folder%@ in root)",
                        _inspectedItem.scanData.recursiveFileCounter,
                        _inspectedItem.scanData.recursiveFileCounter != 1 ? @"s" : @"",
                        _inspectedItem.scanData.recursiveDirectoryCounter,
                        _inspectedItem.scanData.recursiveDirectoryCounter != 1 ? @"s" : @"",
                        _inspectedItem.scanData.fileCounter,
                        _inspectedItem.scanData.fileCounter != 1 ? @"s" : @"",
                        _inspectedItem.scanData.directoryCounter,
                        _inspectedItem.scanData.directoryCounter != 1 ? @"s" : @""
                        ];
            break;
        case 2:
            strValue = convertToFileSizeString([_inspectedItem.fileSize longLongValue]);
            break;
        case 3:
            strValue = formattedDate(_inspectedItem.modificationDate);
            break;
        case 4:
            strValue = _inspectedItem.scanData.latestRecursiveFilePath;
            break;
        case 5:
            strValue = formattedDate(_inspectedItem.scanData.latestRecursiveFileDate);
            break;
        case 6:
            strValue = _inspectedItem.scanData.earliestRecursiveFilePath;
            break;
        case 7:
            strValue = formattedDate(_inspectedItem.scanData.earliestRecursiveFileDate);
            break;
        default:
            break;
    }

   // NSLog(@"%li - %@", row, strValue);
    if (strValue == nil) {
        strValue = @"";
    }
    if (_inspectedItem == nil) {
     //   NSLog(@"NIL ALERT");
    }
    result = [tableView makeViewWithIdentifier:@"multilineCell" owner:self];
    result.textField.stringValue = [strValue copy];
    return result;
}

//- (CGFloat)tableView:(NSTableView *)tableView
//         heightOfRow:(NSInteger)row {
//    if (row==0) {
//        return 34.0f;
//    }
//    return 17.0f;
//}


-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 8;
}

//
//-(id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
//    
//    NSTableCellView *result;
//    
//    if (_inspectedItem == nil && [tableColumn.identifier isEqualToString:@"fieldvalue"]) {
//        result = [tableView makeViewWithIdentifier:@"multilineCell" owner:self];
//        result.textField.stringValue = @"";
//        return result;
//        
//    }
//    
//    NSString *fieldName = @"";
//    
//    switch (row) {
//        case 0:
//            fieldName = @"Path";
//            break;
//        case 1:
//            fieldName = @"Contains:";
//            break;
//        case 2:
//            fieldName = @"Total Size:";
//            break;
//        case 3:
//            fieldName = @"Folder Modification Date:";
//            break;
//        case 4:
//            fieldName = @"Newest File (total):";
//            break;
//        case 5:
//            fieldName = @"Date:";
//            break;
//        case 6:
//            fieldName = @"Newest File (root):";
//            break;
//        case 7:
//            fieldName = @"Date:";
//            break;
//        case 8:
//            fieldName = @"Newest Dir (total):";
//            break;
//        case 9:
//            fieldName = @"Date:";
//            break;
//        case 10:
//            fieldName = @"Newest Dir (root):";
//            break;
//        case 11:
//            fieldName = @"Date:";
//            break;
//        case 12:
//            fieldName = @"Oldest File (total):";
//            break;
//        case 13:
//            fieldName = @"Date:";
//            break;
//        case 14:
//            fieldName = @"Oldest File (root):";
//            break;
//        case 15:
//            fieldName = @"Date:";
//            break;
//        case 16:
//            fieldName = @"Oldest Dir (total):";
//            break;
//        case 17:
//            fieldName = @"Date:";
//            break;
//        case 18:
//            fieldName = @"Oldest Dir (root):";
//            break;
//        case 19:
//            fieldName = @"Date:";
//            break;
//        default:
//            break;
//    }
//    
//    if ([tableColumn.identifier isEqualToString:@"fieldname"]) {
//        
//        result = [tableView makeViewWithIdentifier:@"fieldnameCell" owner:self];
//        result.textField.stringValue = fieldName;
//        return result;
//    }
//    
//    
//    result = [tableView makeViewWithIdentifier:@"multilineCell" owner:self];
//    NSString *strValue = @"";
//    
//    switch (row) {
//        case 0:
//            strValue = _inspectedItem.path;
//            break;
//        case 1:
//            strValue = [NSString stringWithFormat:@"%li file%@ in %li folder%@ (%li file%@ in %li folder%@ in root)",
//                        _inspectedItem.scanData.recursiveFileCounter,
//                        _inspectedItem.scanData.recursiveFileCounter != 1 ? @"s" : @"",
//                        _inspectedItem.scanData.recursiveDirectoryCounter,
//                        _inspectedItem.scanData.recursiveDirectoryCounter != 1 ? @"s" : @"",
//                        _inspectedItem.scanData.fileCounter,
//                        _inspectedItem.scanData.fileCounter != 1 ? @"s" : @"",
//                        _inspectedItem.scanData.directoryCounter,
//                        _inspectedItem.scanData.directoryCounter != 1 ? @"s" : @""
//                        ];
//            break;
//        case 2:
//            strValue = convertToFileSizeString([_inspectedItem.fileSize longLongValue]);
//            break;
//        case 3:
//            strValue = formattedDate(_inspectedItem.modificationDate);
//            break;
//        case 4:
//            strValue = _inspectedItem.scanData.latestRecursiveFilePath;
//            break;
//        case 5:
//            strValue = formattedDate(_inspectedItem.scanData.latestRecursiveFileDate);
//            break;
//        case 6:
//            strValue = _inspectedItem.scanData.latestFilePath;
//            break;
//        case 7:
//            strValue = formattedDate(_inspectedItem.scanData.latestFileDate);
//            break;
//        case 8:
//            strValue = _inspectedItem.scanData.latestRecursiveDirectoryPath;
//            break;
//        case 9:
//            strValue = formattedDate(_inspectedItem.scanData.latestRecursiveDirectoryDate);
//            break;
//        case 10:
//            strValue = _inspectedItem.scanData.latestDirectoryPath;
//            break;
//        case 11:
//            strValue = formattedDate(_inspectedItem.scanData.latestDirectoryDate);
//            break;
//        case 12:
//            strValue = _inspectedItem.scanData.earliestRecursiveFilePath;
//            break;
//        case 13:
//            strValue = formattedDate(_inspectedItem.scanData.earliestRecursiveFileDate);
//            break;
//        case 14:
//            strValue = _inspectedItem.scanData.earliestFilePath;
//            break;
//        case 15:
//            strValue = formattedDate(_inspectedItem.scanData.earliestFileDate);
//            break;
//        case 16:
//            strValue = _inspectedItem.scanData.earliestRecursiveDirectoryPath;
//            break;
//        case 17:
//            strValue = formattedDate(_inspectedItem.scanData.earliestRecursiveDirectoryDate);
//            break;
//        case 18:
//            strValue = _inspectedItem.scanData.earliestDirectoryPath;
//            break;
//        case 19:
//            strValue = formattedDate(_inspectedItem.scanData.earliestDirectoryDate);
//            break;
//        default:
//            break;
//    }
//    
//
//    // NSLog(@"%li - %@", row, strValue);
//    if (strValue == nil) {
//        strValue = @"";
//    }
//    if (_inspectedItem == nil) {
//        //   NSLog(@"NIL ALERT");
//    }
//    result = [tableView makeViewWithIdentifier:@"multilineCell" owner:self];
//    result.textField.stringValue = strValue;
//    return result;
//}


@end
