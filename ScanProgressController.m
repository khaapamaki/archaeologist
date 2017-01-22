//
//  ScanProgressWindowController.m
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 17.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import "ScanProgressController.h"


@implementation ScanProgressController

- (void)windowDidLoad {
    [super windowDidLoad];
    NSLog(@"scan progress did load");
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)test {

}

- (IBAction)cancelAction:(id)sender {
      [[[self window] sheetParent] endSheet:[self window] returnCode:NSModalResponseCancel];
}
@end
