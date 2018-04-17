//
//  QMConfigParser.h
//  QromaScan
//
//  Created by truebucha on 8/1/16.
//  Copyright © 2016 Qroma. All rights reserved.
//

#import <Foundation/Foundation.h>

#define QM_Parse_Strings_ComponentsSeparators_Characters @";"
#define QM_Parse_Strings_PairDivider_Characters @":"

@interface QMConfigParser : NSObject

+ (NSArray<NSNumber *> * _Nullable) numbersUsingStringsList: (NSString * _Nonnull) list;
+ (NSArray<NSString *> * _Nullable) wordsUsingStringsList: (NSString * _Nonnull) list;
+ (NSDictionary<NSString *, NSNumber *> * _Nullable) pairsUsingStrings: (NSString * _Nonnull) strings;

+ (id)objectOfClass:(Class _Nonnull)class
     fromDictionary:(NSDictionary * _Nonnull)dict
           usingKey:(NSString * _Nonnull)key;

@end
