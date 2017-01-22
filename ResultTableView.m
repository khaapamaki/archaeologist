//
//  MainView.m
//  Archaelogist
//
//  Created by Kati Haapamäki on 18.1.2017.
//  Copyright © 2017 Kati Haapamäki. All rights reserved.
//

#import "ResultTableView.h"
#import "UtilityFunctions.h"
#import "AppDelegate.h"
#import "Definitions.h"

@interface ResultTableView ()

@end


@implementation ResultTableView

-(void)awakeFromNib {
    
}


#pragma mark - Keyboard Events

-(BOOL)acceptsFirstResponder{;
//    printStdErrLine(@"ResultTableView accepts first responder");
    return YES;
}
-(BOOL)resignFirstResponder{
//        printStdErrLine(@"ResultTableView resigns first responder");
    return YES;
}
-(BOOL)becomeFirstResponder{
//        printStdErrLine(@"ResultTableView becomes first responder");
    return YES;
}

- (void)keyDown:(NSEvent *)event
{
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

    // Mask out everything but the key flags
    NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;

    unsigned short key = [event keyCode];
    NSString *chars = [event characters];
    if (key == kVK_ANSI_C) {
        
    }
    
    if (key == kVK_ANSI_X) {
        
    }
    
    if (key == kVK_ANSI_A || [chars isEqualToString:@"a"] || [chars isEqualToString:@"A"] ) {
        if (flags == 0 || [chars isEqualToString:@"a"]) {
            [appDelegate markForArchiving:self];
        } else if (flags == NSShiftKeyMask || [chars isEqualToString:@"A"]) {
            [appDelegate unmarkForArchiving:self];
        } 
    }
    if (key == kVK_ANSI_D || [chars isEqualToString:@"d"] || [chars isEqualToString:@"D"]) {
        if (flags == 0 || [chars isEqualToString:@"d"]) {
            [appDelegate markForRemoval:self];
        } else if (flags == NSShiftKeyMask || [chars isEqualToString:@"D"]) {
            [appDelegate unmarkForRemoval:self];
        }
    }
    if (key == kVK_ANSI_C && (flags & NSCommandKeyMask) != 0) {
        [self copyToClipboard:self];
    }
}

- (IBAction)copyToClipboard:(id)sender {
    NSIndexSet *selectedIndexes = [self selectedRowIndexes];
    if ([selectedIndexes count] == 0)
        return;
    
    NSArray *FSItems = [self getFSItemsByIndexSet:selectedIndexes];
    NSMutableString *copyContentString = [[NSMutableString alloc] initWithCapacity:100*[selectedIndexes count]];
    NSString *rootPath = nil;
    
    for (FSItem *thisItem in FSItems) {
        if (rootPath == nil) {
            rootPath = [thisItem.rootScanData.fileURL path];
        }
        //[copyContentString appendString:sizeStringWithFiller([thisItem.fileSize longLongValue], 13)];
        
        [copyContentString appendString:extractRootFromPath(rootPath, thisItem.path)];
        [copyContentString appendString:@"\n"];
    }

    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:copyContentString forType:NSStringPboardType];
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

- (NSIndexSet*)getClickedRowOrSelectedRows {
    NSInteger row = [self clickedRow];
    NSIndexSet *selectedIndexes = [self selectedRowIndexes];
    
    if ([selectedIndexes count] == 0) {
        if (row < 0 && row > [_tableContents count]) {
            return [NSIndexSet new];
        }
        selectedIndexes = [NSIndexSet indexSetWithIndex:row];
    }
    return selectedIndexes;
}

- (NSIndexSet*)getSelectedRows {
    NSIndexSet *selectedIndexes = [self selectedRowIndexes];
    return selectedIndexes;
}
@end
