//
//  SearchTexBoxView.m
//  Archaelogist
//
//  Created by Kati Haapamäki on 24.2.2017.
//  Copyright © 2017 Kati Haapamäki. All rights reserved.
//

#import "SearchFieldController.h"
#import "Definitions.h"

@implementation SearchFieldController


-(BOOL)acceptsFirstResponder{
    return YES;
}
-(BOOL)resignFirstResponder{
    return YES;
}
-(BOOL)becomeFirstResponder{
    return YES;
}

//- (void)keyDown:(NSEvent *)event
//{
//    // Mask out everything but the key flags
////    NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
//    
//    unsigned short key = [event keyCode];
////    NSString *chars = [event characters];
//    if (key == kVK_Return || key == kVK_ANSI_KeypadEnter) {
//        [self.window makeFirstResponder:nil];
//    } else {
//        
//        
//        
//    }
//  
//}

@end
