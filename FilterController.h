//
//  FilterController.h
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 18.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UtilityFunctions.h"
#import "SearchField.h"
#import "ResultTableView.h"

@interface FilterController : NSObject {
    
}

@property (readonly) long long minSize;

@property (weak) IBOutlet NSTextField *levelTextField;
@property (weak) IBOutlet NSSlider *levelSlider;
@property (weak) IBOutlet NSTextField *minLevelTextField;
@property (weak) IBOutlet NSSlider *minLevelSlider;
@property (weak) IBOutlet NSTextField *maxLevelTextField;
@property (weak) IBOutlet NSSlider *maxLevelSlider;

@property (weak) IBOutlet NSTextField *yearsTextField;
@property (weak) IBOutlet NSSlider *yearsSlider;
@property (weak) IBOutlet NSTextField *monthsTextField;
@property (weak) IBOutlet NSSlider *monthsSlider;
@property (weak) IBOutlet NSTextField *daysTextField;
@property (weak) IBOutlet NSSlider *daysSlider;
@property (weak) IBOutlet NSTextField *sizeTextField;
@property (weak) IBOutlet NSSlider *sizeSlider;
@property (weak) IBOutlet NSButton *invertDateButton;
@property (weak) IBOutlet NSButton *invertSizeButton;
@property (weak) IBOutlet NSTextField *subdirLevelTitle;
@property (weak) IBOutlet NSTextField *ageTitle;
@property (weak) IBOutlet NSTextField *sizeTitle;
@property (weak) IBOutlet NSTextField *optionsTitle;
@property (weak) IBOutlet NSTextField *maxLevelTitle;
@property (weak) IBOutlet NSTextField *minLevelTitle;
@property (weak) IBOutlet NSTextField *yearsTitle;
@property (weak) IBOutlet NSTextField *monthsTitle;
@property (weak) IBOutlet NSTextField *daysTitle;
@property (weak) IBOutlet NSTextField *sizeSliderTitle;
@property (weak) IBOutlet NSButton *options1;
@property (weak) IBOutlet NSButton *options2;
@property (weak) IBOutlet NSButton *options4;
@property (weak) IBOutlet NSButton *options5;
@property (weak) IBOutlet NSButton *options6;
@property (weak) IBOutlet NSButton *options7;
@property (weak) IBOutlet SearchField *searchField;
@property (weak) IBOutlet ResultTableView *resultTableView;

- (IBAction)levelTextFieldChanged:(id)sender;
- (IBAction)levelSliderChanged:(id)sender;
- (IBAction)minLevelTextFieldChanged:(id)sender;
- (IBAction)minLevelSliderChanged:(id)sender;
- (IBAction)yearsTextFieldChanged:(id)sender;
- (IBAction)yearsSliderChanged:(id)sender;
- (IBAction)monthsTextFieldChanged:(id)sender;
- (IBAction)monthsSliderChanged:(id)sender;
- (IBAction)daysTextFieldChanged:(id)sender;
- (IBAction)daysSliderChanged:(id)sender;
- (IBAction)sizeTextFieldChanged:(id)sender;
- (IBAction)sizeSliderChanged:(id)sender;
- (IBAction)searchFieldChanged:(id)sender;

- (void)setFiltersAndOptionsEnabled:(BOOL)isEnabled;
//- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor;

@end
