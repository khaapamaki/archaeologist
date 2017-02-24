//
//  SearchField.m
//  Archaelogist
//
//  Created by Kati Haapamäki on 24.2.2017.
//  Copyright © 2017 Kati Haapamäki. All rights reserved.
//

#import "SearchField.h"

@implementation SearchField 

static id eventMonitor = nil;

- (BOOL)becomeFirstResponder {
    BOOL okToChange = [super becomeFirstResponder];
    if (okToChange) {
        [self setKeyboardFocusRingNeedsDisplayInRect: [self bounds]];
        
        if (!eventMonitor) {
            eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event) {
                
                NSString *characters = [event characters];
                unichar character = [characters characterAtIndex:0];
                //NSString *characterString=[NSString stringWithFormat:@"%c",character];
                
                if(character == NSCarriageReturnCharacter || character == NSTabCharacter) {
                    [self.window makeFirstResponder:nil];
                    event = nil;
                }
                return event;
            } ];
            
        }
    }
    //NSLog(@"become first responder");
    return okToChange;
}

//- (BOOL)becomeFirstResponder {
//    BOOL okToChange = [super becomeFirstResponder];
//    if (okToChange) {
//        [self setKeyboardFocusRingNeedsDisplayInRect: [self bounds]];
//        
//        if (!eventMonitor) {
//            eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event) {
//                
//                NSString *characters = [event characters];
//                unichar character = [characters characterAtIndex:0];
//                NSString *characterString=[NSString stringWithFormat:@"%c",character];
//                
//                NSArray *validNonAlphaNumericArray = @[@" ",@"(",@")",@"[",@"]",@":",@";",@"\'",@"\"",@".",@"<",@">",@",",@"{",@"}",@"|",@"=",@"+",@"-",@"_",@"?",@"#",
//                                                       @(NSDownArrowFunctionKey),@(NSUpArrowFunctionKey),@(NSLeftArrowFunctionKey),@(NSRightArrowFunctionKey)];
//                
//                if([[NSCharacterSet alphanumericCharacterSet] characterIsMember:character] || character == NSCarriageReturnCharacter || character == NSTabCharacter || character == NSDeleteCharacter || [validNonAlphaNumericArray containsObject:characterString ] ) { //[NSCharacterSet alphanumericCharacterSet]
//                }  else {
//                    NSBeep();
//                    event=nil;
//                }
//                return event;
//            } ];
//            
//        }
//    }
//    NSLog(@"become first responder");
//    return okToChange;
//}

-(BOOL)acceptsFirstResponder{
    return YES;
}
-(BOOL)resignFirstResponder{
    return YES;
}

@end
