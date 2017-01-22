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

@interface AppDelegate : NSObject <NSApplicationDelegate> {

    NSURL *_scanRootURL;
    FSItem *_scanRoot;
    long _maxDepth;
    int _ageDays;
    int _ageMonths;
    int _ageYears;
    long long _minSize;
    long _minDepth;
    Analyzer *_analyzer;
    NSWindow *scanSheet;
    NSOperationQueue *_opQueue;
    Scanner *_scanner;
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
@property (weak) IBOutlet NSWindow *listWindow;
@property IBOutlet NSTextView *listView;

// IB Outlets
@property (weak) IBOutlet NSTextField *statusTextField;
@property (weak) IBOutlet NSButton *invertDateFiltersButton;
@property (weak) IBOutlet NSButton *invertSizeFilterButton;

@property (weak) IBOutlet NSButton *optionShowDirectoriesWithoutDates;
@property (weak) IBOutlet NSButton *optionDatelessDirectoriesAreOld;
@property (weak) IBOutlet NSButton *optionLonkeroMode;
@property (weak) IBOutlet NSButton *optionLonkeroFoldersOnly;
@property (weak) IBOutlet NSButton *optionLonkeroRespectMaxLimit;
@property (weak) IBOutlet NSButton *optionLonkeroSearchMasters;
@property (weak) IBOutlet NSButton *optionLonkeroStopAtParent;
@property (weak) IBOutlet NSButton *tagArchiveButton;
@property (weak) IBOutlet NSButton *tagRemovalButton;
@property (weak) IBOutlet NSButton *tagCandidateButton;
@property (weak) IBOutlet NSButton *tagCheckButton;

@property (weak) IBOutlet NSTextField *scanningTextField;
@property (weak) IBOutlet NSButton *scanExitButton;


// IB Outlets for Menu
@property (weak) IBOutlet NSMenuItem *showMainWindowMenuItem;
@property (weak) IBOutlet NSMenuItem *showInspectorMenuItem;
@property (weak) IBOutlet NSMenuItem *enterDebuggerMenuItem; // debug only


// IB User Actions
- (IBAction)scanTree:(id)sender;
- (IBAction)resultTableViewAction:(id)sender; // row clicked
- (IBAction)scanExitButtonPressed:(id)sender;
- (IBAction)showInFinder:(id)sender;

// Option change actions (reanalyze)
- (IBAction)optionShowDirectoriesWithoutDatesChanged:(id)sender;
- (IBAction)optionLonkeroModeChanged:(id)sender;
- (IBAction)optionOnlyLonkeroFoldersChanged:(id)sender;
- (IBAction)optionSearchMastersChanged:(id)sender;
- (IBAction)optionLonkeroRespectMaxLimitChanged:(id)sender;
- (IBAction)optionStopAtParentChanged:(id)sender;
- (IBAction)optionDatelessDirectoriesAreOldChanged:(id)sender;
- (IBAction)invertDateFiltersButtonChanged:(id)sender;
- (IBAction)invertSizeFilterButtonChanged:(id)sender;
- (IBAction)tagButtonChanged:(id)sender;



// IB Menu Actions
- (IBAction)showMainMenu:(id)sender;
- (IBAction)enterDebugger:(id)sender;
- (IBAction)showInspector:(id)sender;

- (IBAction)markForArchiving:(id)sender;
- (IBAction)unmarkForArchiving:(id)sender;
- (IBAction)markForRemoval:(id)sender;
- (IBAction)unmarkForRemoval:(id)sender;

- (IBAction)autoMarkForRemoval:(id)sender;

- (IBAction)getArchiveList:(id)sender;
- (IBAction)getRemovalList:(id)sender;

// Notification Center
-(void)updateResultTableView:(NSNotification*)aNotification;

@end

