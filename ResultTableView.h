//
//  ResultTableView.h
//  Archaelogist
//
//  Created by Kati Haapamäki on 18.1.2017.
//  Copyright © 2017 Kati Haapamäki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FSItem.h"
#import "Definitions.h"

@interface ResultTableView : NSTableView {
    BOOL _bypassKeyDown;
}

@property (nonatomic) NSMutableArray *tableContents;

- (IBAction)copyToClipboard:(id)sender;
- (NSIndexSet*)getClickedRowOrSelectedRows;
//- (NSArray*)visibleRows;

@end
