//
//  NSString+Extras.h
//  Lonkero
//
//  Created by Kati Haapamäki on 18.11.2013.
//  Copyright (c) 2013 Kati Haapamäki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extras)

-(NSString *)stringByRemovingDoubleSpaces;
-(NSString *)stringByRemovingDoubleSpacesAndPunctuation;
-(NSString *)stringByTrimmingSpaces;
-(NSString *)stringByReplacingIllegalCharactersWith:(NSString *)replacementString;
-(NSString *)stringByPerformingFullCleanUp;

-(BOOL)isValidFileName;
+(BOOL)isNotEmptyString:(NSString*)str;
+(BOOL)isEmptyString:(NSString*)str;

-(NSString*) stringByInsertingHyphensEvery:(short)number;
+(NSString*) convertWildCardToRegExp:(NSString *)WildCardString;
+(NSString*) generateRandomStringOfLength:(short)len;
-(NSArray*)  arrayFromSemicolonSeparatedList;
-(NSArray*)  arrayFromCommaSeparatedList;
-(NSString*) characterStringAtIndex:(NSInteger)index;

@end
