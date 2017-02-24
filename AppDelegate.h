//
//  AppDelegate.h
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 17.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#define GUI 1

#import <Cocoa/Cocoa.h>
#import "FSItem.h"
#import "UtilityFunctions.h"
#import "Analyzer.h"
#import "ScanProgressController.h"
#import "ResultTableViewController.h"
#import "FilterController.h"
#import "InspectorViewHelper.h"
#import "Scanner.h"
#import "ResultTableView.h"
#import "Definitions.h"
#import "NSDate+DateExtra.h"
#import "SearchField.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {

    NSURL *_scanRootURL;
    FSItem *_scanRoot;
    FSItem *_displayRoot;
    long _maxDepth;
    int _ageDays;
    int _ageMonths;
    int _ageYears;
    long long _minSize;
    long _minDepth;
    NSString *_searchText;
    Analyzer *_analyzer;
    NSWindow *scanSheet;
    NSOperationQueue *_opQueue;
    Scanner *_scanner;
    BOOL _bypassFilters;
}

// IB Outlets for controllers and View Objects
@property (weak) IBOutlet ScanProgressController *scanProgressController;
@property (weak) IBOutlet ResultTableViewController *resultTableViewController;
@property (weak) IBOutlet InspectorViewHelper *inspector;
@property (weak) IBOutlet FilterController *filterController;
@property (weak) IBOutlet NSWindow *scanProgressSheet;
@property (weak) IBOutlet NSView *mainWindowView;
@property (weak) IBOutlet NSPanel *inpectorPanel;
@property (weak) IBOutlet ResultTableView *resultTableView;
//@property (weak) IBOutlet NSWindow *listWindow;
//@property IBOutlet NSTextView *listView; // Deprecated
@property (weak) IBOutlet NSPathControl *pathControl;

// IB Outlets
@property (weak) IBOutlet NSTextField *statusTextField;
@property (weak) IBOutlet NSButton *invertDateFiltersButton;
@property (weak) IBOutlet NSButton *invertSizeFilterButton;

@property (weak) IBOutlet NSButton *optionHideDirectoriesWithoutDates;
@property (weak) IBOutlet NSButton *optionLonkeroMode;
@property (weak) IBOutlet NSButton *optionLonkeroFoldersOnly;
@property (weak) IBOutlet NSButton *optionLonkeroRespectMaxLimit;
@property (weak) IBOutlet NSButton *optionLonkeroSearchMasters;
@property (weak) IBOutlet NSButton *optionShowSubdirectories; //
@property (weak) IBOutlet NSButton *tagArchiveButton;
@property (weak) IBOutlet NSButton *tagRemovalButton;
@property (weak) IBOutlet NSButton *tagCandidateButton;
@property (weak) IBOutlet NSButton *tagCheckButton;
@property (weak) IBOutlet NSButton *bypassFiltersButton;

@property (weak) IBOutlet NSTextField *scanningTextField;
@property (weak) IBOutlet NSButton *scanExitButton;
@property (weak) IBOutlet SearchField *searchField;

// IB Outlets for Menu
@property (weak) IBOutlet NSMenuItem *showMainWindowMenuItem;
@property (weak) IBOutlet NSMenuItem *showInspectorMenuItem;
@property (weak) IBOutlet NSMenuItem *enterDebuggerMenuItem;


// IB User Actions
- (IBAction)scanTree:(id)sender;
- (IBAction)resultTableViewAction:(id)sender; // row clicked
- (IBAction)scanExitButtonPressed:(id)sender;
- (IBAction)showInFinder:(id)sender;
- (IBAction)pathControlClicked:(id)sender;
- (IBAction)parentFolderClicked:(id)sender;
- (IBAction)bypassFiltersClicked:(id)sender;

// Option change actions (reanalyze)
- (IBAction)optionHideDirectoriesWithoutDatesChanged:(id)sender;
- (IBAction)optionLonkeroModeChanged:(id)sender;
- (IBAction)optionOnlyLonkeroFoldersChanged:(id)sender;
- (IBAction)optionSearchMastersChanged:(id)sender;
- (IBAction)optionLonkeroRespectMaxLimitChanged:(id)sender;
- (IBAction)optionShowSubdirectoriesChanged:(id)sender;
- (IBAction)invertDateFiltersButtonChanged:(id)sender;
- (IBAction)invertSizeFilterButtonChanged:(id)sender;
- (IBAction)tagButtonChanged:(id)sender;

// IB Menu Actions
- (IBAction)showMainMenu:(id)sender;
- (IBAction)enterDebugger:(id)sender;
- (IBAction)showInspector:(id)sender;

- (IBAction)tagForArchiving:(id)sender;
- (IBAction)untagForArchiving:(id)sender;
- (IBAction)tagForRemoval:(id)sender;
- (IBAction)untagForRemoval:(id)sender;
- (IBAction)tagAsCandidate:(id)sender;
- (IBAction)untagAsCandidate:(id)sender;
- (IBAction)tagForChecking:(id)sender;
- (IBAction)untagForChecking:(id)sender;

- (IBAction)autoTagForRemoval:(id)sender;

// Notification Center
-(void)updateResultTableView:(NSNotification*)aNotification;

@end

