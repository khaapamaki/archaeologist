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
    _bypassKeyDown = NO;
}

#pragma mark - Keyboard Events

-(BOOL)acceptsFirstResponder{;
    return YES;
}
-(BOOL)resignFirstResponder{
    return YES;
}
-(BOOL)becomeFirstResponder{
    return YES;
}

- (void)keyDown:(NSEvent *)event
{
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

    // Mask out everything but the key flags
    NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;

    unsigned short key = [event keyCode];
    NSString *chars = [event characters];
    
    if (key == kVK_ANSI_A || [chars isEqualToString:@"a"] || [chars isEqualToString:@"A"] ) {
        if (flags == 0 || [chars isEqualToString:@"a"]) {
            [appDelegate tagForArchiving:self];
        } else if (flags == NSShiftKeyMask || [chars isEqualToString:@"A"]) {
            [appDelegate untagForArchiving:self];
        } 
    }
    if (key == kVK_ANSI_D || [chars isEqualToString:@"d"] || [chars isEqualToString:@"D"]) {
        if (flags == 0 || [chars isEqualToString:@"d"]) {
            [appDelegate tagForRemoval:self];
        } else if (flags == NSShiftKeyMask || [chars isEqualToString:@"D"]) {
            [appDelegate untagForRemoval:self];
        }
    }
    if (key == kVK_ANSI_C && (flags & NSCommandKeyMask) != 0) {
        [self copyToClipboard:self];
    }
    
    if (key == kVK_ANSI_C || [chars isEqualToString:@"c"] || [chars isEqualToString:@"C"] ) {
        if (flags == 0 || [chars isEqualToString:@"c"]) {
            [appDelegate tagAsCandidate:self];
        } else if (flags == NSShiftKeyMask || [chars isEqualToString:@"C"]) {
            [appDelegate untagAsCandidate:self];
        }
    }
    
    if (key == kVK_ANSI_D || [chars isEqualToString:@"x"] || [chars isEqualToString:@"X"]) {
        if (flags == 0 || [chars isEqualToString:@"x"]) {
            [appDelegate tagForChecking:self];
        } else if (flags == NSShiftKeyMask || [chars isEqualToString:@"X"]) {
            [appDelegate untagForChecking:self];
        }
    }
    
    if (key == kVK_ANSI_C && (flags & NSCommandKeyMask) != 0) {
        [self copyToClipboard:self];
    }
    
    if (_bypassKeyDown == NO && (key == kVK_Space || [chars isEqualToString:@" "])) {
        [[appDelegate bypassFiltersButton] setState:YES];
        [appDelegate bypassFiltersClicked:self];
        _bypassKeyDown = YES;
    }
}

- (void)keyUp:(NSEvent *)event {
    if (_bypassKeyDown) {
        AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        [[appDelegate bypassFiltersButton] setState:NO];
        [appDelegate bypassFiltersClicked:self];
        _bypassKeyDown = NO;
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
        NSString *tagStr = getTagString(thisItem.tags);

        tagStr = fillToLength(tagStr, 5);
        [copyContentString appendString:getTagString(thisItem.tags)];
        
        [copyContentString appendString:@" \t"];
        [copyContentString appendString:extractRootFromPath(rootPath, thisItem.path)];
//        [copyContentString appendString:@"\t"];
//        [copyContentString appendString:convertToFileSizeString([thisItem.fileSize longLongValue])];
        [copyContentString appendString:@"\n"];
    }

    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:copyContentString forType:NSPasteboardTypeString]; //  NSStringPboardType];
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
