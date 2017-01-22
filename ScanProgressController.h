//
//  ScanProgressWindowController.h
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 17.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScanProgressController : NSWindowController

@property (weak) IBOutlet NSWindow *scanProgressWindow;

@property (weak) IBOutlet NSButton *cancelButton;

- (IBAction)cancelAction:(id)sender;

@end
