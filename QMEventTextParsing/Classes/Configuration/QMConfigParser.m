//
//  QMConfigParser.m
//  QromaScan
//
//  Created by truebucha on 8/1/16.
//  Copyright © 2016 Qroma. All rights reserved.
//

#import "QMConfigParser.h"

@implementation QMConfigParser

// MARK: extract object

+ (NSArray<NSNumber *> *) numbersUsingStringsList: (NSString *) list {
    NSArray<NSString *> * wordsList = [self wordsUsingStringsList: list];
    NSMutableArray * result = [NSMutableArray array];
    for (NSString * word in wordsList) {
        NSInteger number = word.integerValue;
        if (number == 0) {
            continue;
        }
        
        [result addObject: @(number)];
    }
    
    if (result.count == 0) {
        return nil;
    }
    
    return result;
}

+ (NSArray<NSString *> *) wordsUsingStringsList: (NSString *) list {
    NSCharacterSet * dividers = [NSCharacterSet characterSetWithCharactersInString: QM_Parse_Strings_ComponentsSeparators_Characters];
    NSArray<NSString *> * result = [list componentsSeparatedByCharactersInSet: dividers];
    return result;
}

+ (NSDictionary<NSString *, NSNumber *> *) pairsUsingStrings: (NSString *) strings {
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString: QM_Parse_Strings_ComponentsSeparators_Characters];
    NSArray<NSString *> * pairs = [strings componentsSeparatedByCharactersInSet: set];
    
    NSCharacterSet * divider = [NSCharacterSet characterSetWithCharactersInString: QM_Parse_Strings_PairDivider_Characters];
    NSMutableDictionary<NSString *, NSObject *> * result = [NSMutableDictionary dictionary];
    
    for (NSString * pair in pairs) {
        NSArray<NSString *> * elements = [pair componentsSeparatedByCharactersInSet: divider];
        if (elements.count != 2) {
            continue;
        }
        NSString * key = elements.firstObject;
        NSInteger number = elements.lastObject.integerValue;
        NSNumber * value = number != 0 ? @(number)
                                       : nil;
        if ([elements.lastObject isEqualToString: @"0"]) {
            value = @(0);
        }
        
        if (key == nil
            || value == nil) {
            NSLog(@"Failed to get object pair for string %@", pair);
            continue;
        }
        
        result[key] = value;
    }
    
    return [result copy];
}

+ (id)objectOfClass:(Class)class
     fromDictionary:(NSDictionary *)dict
           usingKey:(NSString *)key {
    NSObject * value = dict[key];
    NSObject * result = [value isKindOfClass:class] ? value
                                                    : nil;
    
    if (result == nil) {
        NSLog(@"Failed to get object for key %@\
              \r\n should be %@, got %@\
              \r\n using parse dictionary %@",
              key, NSStringFromClass(class), NSStringFromClass([value class]), dict);
    }
    
    return result;
}


@end
