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

+ (NSArray<NSNumber *> *) numbersUsingStringsList: (NSString *) list;
+ (NSArray<NSString *> *) wordsUsingStringsList: (NSString *) list;
+ (NSDictionary<NSString *, NSNumber *> *) pairsUsingStrings: (NSString *) strings;

+ (id)objectOfClass:(Class)class
     fromDictionary:(NSDictionary *)dict
           usingKey:(NSString *)key;

@end
