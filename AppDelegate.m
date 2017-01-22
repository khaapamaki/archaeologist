//
//  AppDelegate.m
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 17.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

#pragma mark - NSApplication

-(void)applicationDidBecomeActive:(NSNotification *)notification {
    
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    
    if (flag == YES) {
        
    } else {
        [_window makeKeyAndOrderFront:nil];
    }
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    _scanRootURL = nil;
    _maxDepth = 0;
    _ageDays = 0;
    _ageMonths = 0;
    _ageYears = 0;
    _minSize = 0;
    _analyzer = [[Analyzer alloc] init];
    _statusTextField.stringValue = @"";
#if DEBUG==1
    [_enterDebuggerMenuItem setEnabled:YES];
    [_enterDebuggerMenuItem setHidden:NO];
#else
    [_enterDebuggerMenuItem setEnabled:NO];
    [_enterDebuggerMenuItem setHidden:YES];
#endif
    // hide lonkero column by default
    [[_resultTableViewController.resultTableView tableColumnWithIdentifier:@"lonkero"] setHidden:!_optionLonkeroMode.state];
    
    if (_resultTableView.doubleAction != @selector(doubleClick:)) {
        [_resultTableView setTarget:self];
        [_resultTableView setDoubleAction:@selector(doubleClick:)];
    }
    
    [_optionLonkeroMode setToolTip:@"Uses Lonkero metadata to prevent showing folders inside folder structure. "
     "May exceed maximum level limit in search of Lonkero deployment master folder."];
    [_invertDateFiltersButton setToolTip:@"Shows folders that are newer than age treshold. Otherwise shows older folders."];
    [_invertSizeFilterButton setToolTip:@"Shows smaller folders than size treshold. Otherwise shows bigger folders."];
    [_optionDatelessDirectoriesAreOld setToolTip:@"Folders that have no date are considered as older than age limit."];
    [_optionShowDirectoriesWithoutDates setToolTip:@"If a folder has no files in it or in any subdirectory, the folder's age cannot be determined. "
     @"By default dateless folders are skipped from processing. By turning this option on, it is possible to show these too. "];
    [_optionLonkeroStopAtParent setToolTip:@"Do not show succeeding subfolders, if parent folder has a match. "
     @"This prevents displaying multiple levels from the same directory branch. "
     @"If 'Skip Lonkero Parents' option is set, Lonkero master folders are shown instead of parent levels."];
    [_optionLonkeroRespectMaxLimit setToolTip:@"By default maximum level limit may be exceed in Lonkero Compability Mode, because it tries "
     @"to reach the deployment master folder. With this option it is possible to force maximum level resctriction to be used."];
    [_optionLonkeroFoldersOnly setToolTip:@"Do not show other than folders with Lonkero metadata stored among them."];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateResultTableView:)
                                                 name:@"ResultTableViewShouldUpdate"
                                               object:nil];
    
    [_pathControl setURL:nil];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    if (_opQueue != nil) [_opQueue cancelAllOperations];
}

#pragma mark - Main Operations

- (void)scanTree:(id)sender {
    // Query for folder to be scanned -> File Open Panel
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection: NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setCanChooseFiles:NO];
    
    NSInteger result = [openPanel runModal];
    if (result == NSModalResponseOK ) {
        _scanRootURL = [openPanel URL];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserverForName:@"ScanTreeDisplayProgressTime"
                            object:nil
                             queue:[NSOperationQueue mainQueue]
                        usingBlock:^(NSNotification *aNotification) {
                            
                            if ([aNotification.object isKindOfClass:[FSItem class]]) {
                                FSItem *sender = aNotification.object;
                                
                                NSString *info = [NSString stringWithFormat:@"Scanned: %li files in %li folders - Size: %@ - Time: %@",
                                                  sender.rootScanData.fileCounter,
                                                  sender.rootScanData.directoryCounter,
                                                  convertToFileSizeString(sender.rootScanData.byteCount),
                                                  minSecString(elapsedTimeFrom(sender.rootScanData.scanStartTime, [NSDate date]))
                                                  ];
                                _scanningTextField.stringValue = info;
                                [_scanningTextField setNeedsDisplay:YES];
                                [_scanningTextField display];
                            }
                        }];
        
        
        // SET OBSERVER FOR SCAN FINISH
        [center addObserverForName:@"ScanFinished"
                            object:nil
                             queue:[NSOperationQueue mainQueue]
                        usingBlock:^(NSNotification *aNotification) {
                            
                            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ScanTreeDisplayProgressTime" object:nil];
                            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ScanFinished" object:nil];
                            _scanExitButton.title = @"OK";
                            
                            if (_scanner.isCancelledByUser == NO ) {
                                
                                [_analyzer.resultArray removeAllObjects];
                                _analyzer.resultArray = [[NSMutableArray alloc] initWithCapacity:200];
                                _scanRoot = _scanner.tree;
                                _displayRoot = _scanRoot;
                                [_pathControl setURL:_displayRoot.fileURL];
                                // ANALYZE
                                [self runAnalyzer];
                                
                                [_resultTableViewController setTableContents:_analyzer.resultArray];
                                
                                if ([_analyzer.resultArray count] > 0) {
                                    [_inspector inspectDirectoryItem:_scanRoot];
                                }
                            }
                        }];
        
        // START SCAN
        _scanExitButton.title = @"Cancel";
        [_window beginSheet:_scanProgressSheet completionHandler:^(NSModalResponse returnCode)
         {
             // completion code needed?
         }];
        
        _scanner = [[Scanner alloc] initWithURL:_scanRootURL];
        
        if (_opQueue == nil) {
            _opQueue = [NSOperationQueue new];
        }
        
        [_opQueue addOperation:_scanner];
    }
}

- (void)readFilterParameters {
    _maxDepth = _filterController.levelTextField.intValue;
    _ageDays = _filterController.daysTextField.intValue;
    _ageMonths = _filterController.monthsTextField.intValue;
    _ageYears = _filterController.yearsTextField.intValue;
    _minSize = _filterController.minSize;
    _minDepth = _filterController.minLevelTextField.intValue;
}

- (TagType)readTagSelectors {
    TagType tags = 0;
    if (_tagArchiveButton.state == YES)
        tags |= ArchiveTag;
    if (_tagRemovalButton.state == YES)
        tags |= DeleteTag;
    if (_tagCandidateButton.state == YES)
        tags |= CandidateTag;
    if (_tagCheckButton.state == YES)
        tags |= CheckTag;
    return tags;
}

- (void)runAnalyzer {
    if (_analyzer == nil) {
        _analyzer = [Analyzer new];
    }
    [self readFilterParameters];
    TagType tagSelector = [self readTagSelectors];
    if (tagSelector == NoTag) {
        NSDate *treshold = dateSinceNow(_ageYears, _ageMonths, _ageDays);
        int mode = 0;
        mode |= _optionLonkeroMode.state == YES ? FCALonkeroMode : 0;
        mode |= _invertDateFiltersButton.state == YES ? FCAInvertDateFilter : 0;
        mode |= _invertSizeFilterButton.state == YES ? FCAInvertSizeFilter : 0;
        mode |= _optionLonkeroFoldersOnly.state == YES ? FCALonkeroOnly : 0;
        mode |= _optionLonkeroRespectMaxLimit.state == YES ? FCALonkeroRespectMaxLimit : 0;
        mode |= _optionShowDirectoriesWithoutDates.state == YES ? FCASelectDirectoriesWithoutDates : 0;
        mode |= _optionLonkeroSearchMasters.state == YES ? FCALonkeroSearchMasters : 0;
        mode |= _optionLonkeroStopAtParent.state == YES ? FCALonkeroStopAtParent : 0;
        mode |= _optionDatelessDirectoriesAreOld.state == YES ? FCADatelessDirectoriesAreOld : 0;
        
        [_analyzer scanDirectory:_displayRoot olderThan:treshold minSize:_minSize minDepth:_minDepth maxDepth:_maxDepth mode:mode];

    } else {
        // To show tagged items instead of filtered
        [_analyzer scanTaggedItems:_scanRoot tags:tagSelector];
    }
    
    if ([_analyzer.resultArray count] > 0 || YES) {
        _statusTextField.stringValue = [NSString stringWithFormat:@"Total size of displayed folders: %@",
                                        convertToFileSizeString(_analyzer.scanData.byteCount)];
    } else {
        _statusTextField.stringValue = @"";
    }
}

#pragma mark - Display

- (void)updateResultTableView:(NSNotification *)aNotification {
    [self readFilterParameters];
    [self runAnalyzer];
    [_resultTableViewController setTableContents:_analyzer.resultArray];
}

- (void)enableFiltersAndOptions {
    [_invertSizeFilterButton setEnabled:YES];
    [_invertDateFiltersButton setEnabled:YES];
}

- (void)disableFiltersAndOptions {
    [_invertSizeFilterButton setEnabled:NO];
    [_invertDateFiltersButton setEnabled:NO];
}

#pragma mark - IBActions

- (IBAction)scanExitButtonPressed:(id)sender {
    [_window endSheet:_scanProgressSheet returnCode:NSModalResponseCancel];
    
    if (_scanner.isExecuting == YES) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"CancelScan"
         object:self];
        
    } else {
        if ([_analyzer.resultArray count] > 0) {
            [_inspector inspectDirectoryItem:_scanRoot];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ScanTreeDisplayProgressTime" object:nil];
    
}

- (IBAction)enterDebugger:(id)sender {
    
    NSLog(@"Degugger!");
}

- (IBAction)optionShowDirectoriesWithoutDatesChanged:(id)sender {
    _optionDatelessDirectoriesAreOld.enabled = _optionShowDirectoriesWithoutDates.state;
    [self runAnalyzer];
    [_resultTableViewController setTableContents:_analyzer.resultArray];
}

- (IBAction)optionLonkeroModeChanged:(id)sender {
    [[_resultTableViewController.resultTableView tableColumnWithIdentifier:@"lonkero"] setHidden:!_optionLonkeroMode.state];
    _optionLonkeroFoldersOnly.enabled = _optionLonkeroMode.state;
    _optionLonkeroRespectMaxLimit.enabled = _optionLonkeroMode.state;
    _optionLonkeroSearchMasters.enabled = _optionLonkeroMode.state;
    [self runAnalyzer];
    [_resultTableViewController setTableContents:_analyzer.resultArray];
}

- (IBAction)optionOnlyLonkeroFoldersChanged:(id)sender {
    [self runAnalyzer];
    [_resultTableViewController setTableContents:_analyzer.resultArray];
}

- (IBAction)optionSearchMastersChanged:(id)sender {
    [self runAnalyzer];
    [_resultTableViewController setTableContents:_analyzer.resultArray];
}

- (IBAction)optionLonkeroRespectMaxLimitChanged:(id)sender {
    [self runAnalyzer];
    [_resultTableViewController setTableContents:_analyzer.resultArray];
}

- (IBAction)optionStopAtParentChanged:(id)sender {
    [self runAnalyzer];
    [_resultTableViewController setTableContents:_analyzer.resultArray];
}

- (IBAction)optionDatelessDirectoriesAreOldChanged:(id)sender {
    [self runAnalyzer];
    [_resultTableViewController setTableContents:_analyzer.resultArray];
}

- (IBAction)invertDateFiltersButtonChanged:(id)sender {
    [self runAnalyzer];
    [_resultTableViewController setTableContents:_analyzer.resultArray];
}

- (IBAction)invertSizeFilterButtonChanged:(id)sender {
    [self runAnalyzer];
    [_resultTableViewController setTableContents:_analyzer.resultArray];
}

- (IBAction)tagButtonChanged:(id)sender {
    if ([self readTagSelectors] == 0) {
        [_filterController setFiltersAndOptionsEnabled:YES];
        [_pathControl setURL:_displayRoot.fileURL];
        [self runAnalyzer];
    }
    else {
        [_filterController setFiltersAndOptionsEnabled:NO];
        [_pathControl setURL:_scanRoot.fileURL];
        [self runAnalyzer];
    }
    [_resultTableViewController setTableContents:_analyzer.resultArray];
}

- (IBAction)showInspector:(id)sender {
    if (_showInspectorMenuItem.state == 0) {
        [_inpectorPanel orderFront:self];
        _showInspectorMenuItem.state = 1;
    } else {
        [_inpectorPanel orderOut:self];
        _showInspectorMenuItem.state = 0;
    }
}

/// WIP
- (void)doubleClick:(id)object {
    if (_resultTableViewController.resultTableView == nil) {
        return;
    }
    NSInteger rowNumber = [_resultTableViewController.resultTableView clickedRow];
    if (rowNumber < [_analyzer.resultArray count]) {
        FSItem *clickedItem = [[_analyzer.resultArray objectAtIndex:rowNumber] objectForKey:@"fsitem"];
        _displayRoot = clickedItem;
        [_pathControl setURL:_displayRoot.fileURL];
        if ([self readTagSelectors] != 0) {
            _tagCheckButton.state = NO;
            _tagArchiveButton.state = NO;
            _tagRemovalButton.state = NO;
            _tagCandidateButton.state = NO;
            [self tagButtonChanged:nil];
        } else {
            [self runAnalyzer];
            [_resultTableViewController setTableContents:_analyzer.resultArray]; // or reload?
        }
    }
}

- (IBAction)showMainMenu:(id)sender {
    [_window makeKeyAndOrderFront:self];
}

- (IBAction)resultTableViewAction:(id)sender {
    NSInteger row = [_resultTableViewController.resultTableView clickedRow];
    if ([[_resultTableViewController.resultTableView selectedRowIndexes] count] > 0) {
        if (row < [_analyzer.resultArray count] && row >= 0) {
            FSItem *targetItem = [[_analyzer.resultArray objectAtIndex:row] objectForKey:@"fsitem"];
            [_inspector inspectDirectoryItem:targetItem];
        }
    } else {
        if ([_analyzer.resultArray count] > 0) {
            [_inspector inspectDirectoryItem:_scanRoot];
        }
    }
}

- (IBAction)showInFinder:(id)sender {
    if (_resultTableViewController.resultTableView == nil) {
        return;
    }
    NSInteger rowNumber = [_resultTableViewController.resultTableView clickedRow];
    if (rowNumber >= 0) {
        if (rowNumber < [_analyzer.resultArray count]) {
            FSItem *clickedItem = [[_analyzer.resultArray objectAtIndex:rowNumber] objectForKey:@"fsitem"];
            NSArray *URLArray = [NSArray arrayWithObject:clickedItem.fileURL];
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:URLArray];
        }
    } else {
        if (_scanRootURL != nil) {
            NSArray *URLArray = [NSArray arrayWithObject:_displayRoot.fileURL];
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:URLArray];
        }
    }
}

- (IBAction)pathControlClicked:(id)sender {
    NSURL *clickURL = [[_pathControl clickedPathItem] URL];
    FSItem *lookForParent = _displayRoot;

    // find correspondinf FSItem for clicked path.
    BOOL found = NO;
    while (lookForParent != nil && found == NO) {
        if ([[lookForParent.path stringByStandardizingPath] isEqualToString:[clickURL.path stringByStandardizingPath]]) {
            found = YES;
            break;
        }
        lookForParent = lookForParent.parent;
    }
    if (found) {
        _displayRoot = lookForParent;
    } else {
        _displayRoot = _scanRoot;
    }
    [_pathControl setURL:_displayRoot.fileURL];
    if ([self readTagSelectors] != 0) {
        _tagCheckButton.state = NO;
        _tagArchiveButton.state = NO;
        _tagRemovalButton.state = NO;
        _tagCandidateButton.state = NO;
        [self tagButtonChanged:nil];
    } else {
        [self runAnalyzer];
        [_resultTableViewController setTableContents:_analyzer.resultArray]; // or reload?
    }

}

- (IBAction)parentFolderClicked:(id)sender {
    if ([self readTagSelectors] != 0) {
        _displayRoot = _scanRoot;
        _tagCheckButton.state = NO;
        _tagArchiveButton.state = NO;
        _tagRemovalButton.state = NO;
        _tagCandidateButton.state = NO;
        [self tagButtonChanged:nil];
        return;
    }
    
    if (_displayRoot.parent != nil) {
        _displayRoot = _displayRoot.parent;
        [_pathControl setURL:_displayRoot.fileURL];
        [self runAnalyzer];
        [_resultTableViewController setTableContents:_analyzer.resultArray]; // or reload?
    }
}



#pragma mark - Marking

- (IBAction)tagForArchiving:(id)sender {
    NSIndexSet *selectedIndexes = [_resultTableView getClickedRowOrSelectedRows];
    NSArray *FSItems = [_resultTableViewController getFSItemsByIndexSet:selectedIndexes];
    
    BOOL includesEmpty = NO;
    for (FSItem *thisItem in FSItems) {
        if ([[thisItem fileSize] longLongValue] == 0 && [thisItem contentsFullyRead] == YES) {
            includesEmpty = YES;
            break;
        }
    }
    
    if (includesEmpty) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Some folders are empty. Do you really want to tag them for archiving?"];
        [alert addButtonWithTitle:@"Tag For Archiving"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
            if (result == NSAlertFirstButtonReturn) {
                for (FSItem *thisItem in FSItems) {
                    [thisItem setTagByPattern:ArchiveTag];
                    [thisItem removeTagByPattern:DeleteTag];
                }
                [self runAnalyzer];
                [_resultTableViewController setTableContents:_analyzer.resultArray]; // dont just reload, otherwise sorting resets
            }
        }];
    } else {
        for (FSItem *thisItem in FSItems) {
            [thisItem setTagByPattern:ArchiveTag];
            [thisItem removeTagByPattern:DeleteTag];
        }
        [self runAnalyzer];
        [_resultTableViewController setTableContents:_analyzer.resultArray]; // dont just reload, otherwise sorting resets
        
    }
}

- (IBAction)untagForArchiving:(id)sender {
    NSIndexSet *selectedIndexes = [_resultTableView getClickedRowOrSelectedRows];
    NSArray *FSItems = [_resultTableViewController getFSItemsByIndexSet:selectedIndexes];
    for (FSItem *thisItem in FSItems) {
        [thisItem removeTagByPattern:ArchiveTag];
    }
    [self runAnalyzer];
    [_resultTableViewController setTableContents:_analyzer.resultArray]; // dont just reload, otherwise sorting resets
}

- (IBAction)tagForRemoval:(id)sender {
    NSIndexSet *selectedIndexes = [_resultTableView getClickedRowOrSelectedRows];
    NSArray *FSItems = [_resultTableViewController getFSItemsByIndexSet:selectedIndexes];
    
    BOOL includesNonEmpty = NO;
    for (FSItem *thisItem in FSItems) {
        if ([[thisItem fileSize] longLongValue] > 0 || [thisItem contentsFullyRead] == NO) {
            includesNonEmpty = YES;
            break;
        }
    }
    
    // warn if any folder is not empty
    if (includesNonEmpty) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Some folders are NOT EMPTY. Do you really want to tag them for removal?"];
        [alert addButtonWithTitle:@"Tag For Removal"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
            if (result == NSAlertFirstButtonReturn) {
                for (FSItem *thisItem in FSItems) {
                    [thisItem setTagByPattern:DeleteTag];
                    [thisItem removeTagByPattern:ArchiveTag];
                }
                [self runAnalyzer];
                [_resultTableViewController setTableContents:_analyzer.resultArray]; // dont just reload, otherwise sorting resets
            }
        }];
    } else {
        for (FSItem *thisItem in FSItems) {
            [thisItem setTagByPattern:DeleteTag];
            [thisItem removeTagByPattern:ArchiveTag];
        }
        [self runAnalyzer];
        [_resultTableViewController setTableContents:_analyzer.resultArray]; // dont just reload, otherwise sorting resets
    }
}

- (IBAction)untagForRemoval:(id)sender {
    NSIndexSet *selectedIndexes = [_resultTableView getClickedRowOrSelectedRows];
    NSArray *FSItems = [_resultTableViewController getFSItemsByIndexSet:selectedIndexes];
    for (FSItem *thisItem in FSItems) {
        [thisItem removeTagByPattern:DeleteTag];
    }
    [self runAnalyzer];
    [_resultTableViewController setTableContents:_analyzer.resultArray]; // dont just reload, otherwise sorting resets
}


// Tree Wide Ops

- (IBAction)autoTagForRemoval:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"This will tag for REMOVAL all empty folders with archive tag. Proceed?"];
    [alert addButtonWithTitle:@"Auto Tag For Removal"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
        if (result == NSAlertFirstButtonReturn) {
            //NSArray *shownRows = [_resultTableViewController tableContents];
            for (FSItem *thisItem in _scanRoot.directoryContents) {
                if (thisItem == nil)
                    continue;
                if ([[thisItem isDirectory] boolValue] == NO)
                    continue;
                if (([thisItem.tags shortValue] & ArchiveTag) != 0 && [[thisItem fileSize] longLongValue] == 0) {
                    [thisItem setTagByPattern:DeleteTag];
                    [thisItem removeTagByPattern:ArchiveTag];
                }
            }
            if ([self readTagSelectors] == 0) {
                _tagArchiveButton.state = YES;
                _tagRemovalButton.state = YES;
                _tagCandidateButton.state = NO;
                _tagCheckButton.state = NO;
                [self tagButtonChanged:nil];
            } else {
                [self runAnalyzer];
                [_resultTableViewController setTableContents:_analyzer.resultArray]; // dont just reload, otherwise sorting resets
            }
        }
    }];
}



#pragma mark - Dealloc

- (void) dealloc {
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
