//
//  Scanner.m
//  Archaelogist
//
//  Created by Kati Haapamäki on 30.9.2015.
//  Copyright © 2015 Kati Haapamäki. All rights reserved.
//

#import "Scanner.h"
#import "Definitions.h"

@implementation Scanner

-(void)main {
    // does scanning here
    _scanTree = [[FSItem alloc] initWithURL:_scanRoot depth:-1 foldersOnly:YES];
 
    // was cancelled?
    if (_scanTree.isCancelled == NO && [self isCancelled] == NO) {
        _tree = _scanTree;
    } else {
        _scanTree = nil;
        _isCancelledByUser = YES;
    }
    
    // send notification
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ScanFinished"
     object:self];
}

-(instancetype) initWithURL:(NSURL*)anURL {
    if (self = [super init]) {
        _scanRoot = anURL;
        _tree = nil;
    }
    return self;
}
@end
