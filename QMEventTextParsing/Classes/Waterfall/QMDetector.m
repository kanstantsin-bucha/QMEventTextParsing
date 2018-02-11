//
//  QMDetector.m
//  QromaScan
//
//  Created by bucha on 10/7/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMDetector+Private.h"
#import <CDBKit/CDBKit.h>

@implementation QMDetector

    //MARk: - property

- (NSArray<QMSemanticChunk *> *)detectedChunks {
    return [self.detected copy];
}

- (NSArray<QMSemanticChunk *> *)possibleChunks {
    return [self.possible copy];
}

- (NSString *)detectedValueDescription {
    NSString * result = @"Should be Overided in child implementation";
    return result;
}

    //MARK: - interface -

- (void)detectDataUsingString:(NSString *)string completion:(CDBObjectErrorCompletion)completion {
    
    if (completion) {
        completion (nil, [NSError errorWithDomain: NSStringFromClass([self class])
                                             code: 1
                                         userInfo: @{ NSLocalizedDescriptionKey : @"Should be overrided in child implementation"}]);
    }
    
}

- (NSString *)stringByTrimmingMultipleSpacesIn: (NSString *) string {
    NSString * result = string;
    while ([result rangeOfString:@"  "].location != NSNotFound) {
        result = [result stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    return result;
}

- (NSString *) stringByReducing: (NSString *) string
                    usingChunks: (NSArray<QMSemanticChunk *> *) chunks {
    
    NSArray * ranges = [chunks map: ^id(QMSemanticChunk * chunk) {
        NSValue * result = [NSValue valueWithRange: chunk.range];
        return result;
    }];
    
    NSString * result = [self stringByReducing: string
                                   usingRanges: ranges];
    
    return result;
}

    //MARK: - logic-

- (NSString *) stringByReducing: (NSString *) string
                    usingRanges: (NSArray<NSValue *> *) ranges {
    
    NSPredicate * predicate = [NSPredicate predicateWithBlock:^BOOL(NSValue *  _Nullable value, NSDictionary<NSString *,id> * _Nullable bindings) {
        BOOL result = value.rangeValue.location != NSNotFound;
        return result;
    }];
    
    NSArray<NSValue *> * valuableRanges = [ranges filteredArrayUsingPredicate: predicate];
    
    NSArray<NSValue *> * ascendingRanges = [valuableRanges sortedArrayUsingComparator: ^ NSComparisonResult(NSValue *value1, NSValue *value2) {
        NSComparisonResult result = NSOrderedSame;
        if (value1.rangeValue.location < value2.rangeValue.location) {
            result = NSOrderedAscending;
        } else if (value1.rangeValue.location > value2.rangeValue.location) {
            result = NSOrderedDescending;
        }
        return result;
    }];
    
    NSInteger cutoffOffset = 0;
    NSString * result = string;
    
    for (NSValue * value in ascendingRanges) {
        NSRange range = value.rangeValue;
        if (range.location == NSNotFound) {
            continue;
        }
        
        NSRange workingRange = NSMakeRange(range.location - cutoffOffset, range.length);
        result = [self stringByReducing: result
                             usingRange: workingRange];
        
        cutoffOffset += workingRange.length;
    }
    
    return result;
}

- (NSString *)stringByReducing: (NSString *) string
                    usingRange: (NSRange) range {
    if (range.location == NSNotFound) {
        return string;
    }
    
    NSString * result = [string stringByReplacingCharactersInRange: range
                                                        withString: @""];
    return result;
}

@end
