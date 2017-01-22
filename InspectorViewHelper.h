//
//  InscpetorViewHelper.h
//  Folder Content Analyzer
//
//  Created by Kati Haapamäki on 19.9.2015.
//  Copyright (c) 2015 Kati Haapamäki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FSItem.h"

@interface InspectorViewHelper : NSViewController <NSTableViewDataSource, NSTableViewDelegate> {
    FSItem *_inspectedItem;
}

-(void)inspectDirectoryItem:(FSItem*)fsItem;

@property (weak) IBOutlet NSView *inspectorPanel;
@property (weak) IBOutlet NSTableView *inspectorTableView;


@end
