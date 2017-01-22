//
//  Scanner.h
//  Archaelogist
//
//  Created by Kati Haapamäki on 30.9.2015.
//  Copyright © 2015 Kati Haapamäki. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "FSItem.h"

@interface Scanner : NSOperation {
    FSItem *_scanTree;
    NSURL *_scanRoot;
    id _sender;    
}

@property (atomic) FSItem *tree;
@property (atomic) BOOL isCancelledByUser;

-(instancetype) initWithURL:(NSURL*)anURL;

@end
