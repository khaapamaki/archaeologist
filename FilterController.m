//
//  FilterController.m
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 18.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import "FilterController.h"

@implementation FilterController

- (IBAction)levelTextFieldChanged:(id)sender {
    if (_levelTextField.intValue > 20) {
        _levelTextField.intValue = 20;
    }
    if (_levelTextField.intValue < 0) {
        _levelTextField.intValue = 0;
    }
    _levelSlider.intValue = _levelTextField.intValue;
    if (_minLevelTextField.intValue > _levelTextField.intValue) {
        _minLevelTextField.intValue = _levelTextField.intValue;
        _minLevelSlider.intValue = _levelTextField.intValue;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ResultTableViewShouldUpdate"
     object:self];
}

- (IBAction)levelSliderChanged:(id)sender {

    _levelTextField.intValue = _levelSlider.intValue;
    _levelSlider.intValue = _levelTextField.intValue;
    if (_minLevelTextField.intValue > _levelTextField.intValue) {
        _minLevelTextField.intValue = _levelTextField.intValue;
        _minLevelSlider.intValue = _levelTextField.intValue;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ResultTableViewShouldUpdate"
     object:self];
}

- (IBAction)minLevelTextFieldChanged:(id)sender {
    if (_minLevelTextField.intValue > 20) {
        _minLevelTextField.intValue = 20;
    }
    if (_minLevelTextField.intValue < 0) {
        _minLevelTextField.intValue = 0;
    }
    _levelSlider.intValue = _levelTextField.intValue;
    if (_levelTextField.intValue < _minLevelTextField.intValue) {
        _levelTextField.intValue = _minLevelTextField.intValue;
        _levelSlider.intValue = _minLevelTextField.intValue;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ResultTableViewShouldUpdate"
     object:self];
}

- (IBAction)minLevelSliderChanged:(id)sender {
    
    _minLevelTextField.intValue = _minLevelSlider.intValue;
    if (_levelTextField.intValue < _minLevelTextField.intValue) {
        _levelTextField.intValue = _minLevelTextField.intValue;
        _levelSlider.intValue = _minLevelTextField.intValue;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ResultTableViewShouldUpdate"
     object:self];
}

- (IBAction)yearsTextFieldChanged:(id)sender {
    if (_yearsTextField.intValue > 20) {
        _yearsTextField.intValue = 20;
    }
    if (_yearsTextField.intValue < 0) {
        _yearsTextField.intValue = 0;
    }
    _yearsSlider.intValue = _yearsTextField.intValue;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ResultTableViewShouldUpdate"
     object:self];
}

- (IBAction)yearsSliderChanged:(id)sender {
    _yearsTextField.intValue = _yearsSlider.intValue;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ResultTableViewShouldUpdate"
     object:self];
}

- (IBAction)monthsTextFieldChanged:(id)sender {
    if (_monthsTextField.intValue > 23) {
        _monthsTextField.intValue = 23;
    }
    if (_monthsTextField.intValue < 0) {
        _monthsTextField.intValue = 0;
    }
    _monthsSlider.intValue = _monthsTextField.intValue;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ResultTableViewShouldUpdate"
     object:self];
    
}

- (IBAction)monthsSliderChanged:(id)sender {
    _monthsTextField.intValue = _monthsSlider.intValue;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ResultTableViewShouldUpdate"
     object:self];
}

- (IBAction)daysTextFieldChanged:(id)sender {
    if (_daysTextField.intValue > 84) {
        _daysTextField.intValue = 84;
    }
    if (_daysTextField.intValue < 0) {
        _daysTextField.intValue = 0;
    }
    _daysSlider.intValue = _daysTextField.intValue;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ResultTableViewShouldUpdate"
     object:self];
}

- (IBAction)daysSliderChanged:(id)sender {
    _daysTextField.intValue = _daysSlider.intValue;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ResultTableViewShouldUpdate"
     object:self];
}

- (IBAction)sizeTextFieldChanged:(id)sender {
    
    _minSize = getFileSizeWithString(_sizeTextField.stringValue);
    _sizeSlider.intValue = (int) pow((double)_minSize, 1.0/4.0);
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ResultTableViewShouldUpdate"
     object:self];
}

- (IBAction)sizeSliderChanged:(id)sender {
    _minSize = (long long) pow((double) _sizeSlider.intValue, 4.0);
    _sizeTextField.stringValue = convertToFileSizeString(_minSize);
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ResultTableViewShouldUpdate"
     object:self];
}

- (void)setFiltersAndOptionsEnabled:(BOOL)isEnabled {
    [_levelTextField setEnabled:isEnabled];
    [_levelSlider setEnabled:isEnabled];
    [_minLevelTextField setEnabled:isEnabled];
    [_minLevelSlider setEnabled:isEnabled];
    [_maxLevelSlider setEnabled:isEnabled];
    [_maxLevelTextField setEnabled:isEnabled];
    [_yearsTextField setEnabled:isEnabled];
    [_monthsTextField setEnabled:isEnabled];
    [_daysTextField setEnabled:isEnabled];
    [_yearsSlider setEnabled:isEnabled];
    [_monthsSlider setEnabled:isEnabled];
    [_daysSlider setEnabled:isEnabled];
    [_sizeSlider setEnabled:isEnabled];
    [_sizeTextField setEnabled:isEnabled];
    [_invertDateButton setEnabled:isEnabled];
    [_invertSizeButton setEnabled:isEnabled];
    [_options1 setEnabled:isEnabled];
    [_options2 setEnabled:isEnabled];
    [_options3 setEnabled:(isEnabled && [_options2 state])];
    [_options4 setEnabled:isEnabled];
    [_options5 setEnabled:(isEnabled && [_options4 state])];
    [_options6 setEnabled:(isEnabled && [_options4 state])];
    [_options7 setEnabled:(isEnabled && [_options4 state])];
}

@end
