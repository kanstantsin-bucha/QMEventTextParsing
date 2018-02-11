//
//  QMLinguisticParserResult.m
//  QromaScan
//
//  Created by bucha on 8/27/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMParserResult+Private.h"

@implementation QMParserResult

- (NSString *)description {
    NSString * result = [NSString stringWithFormat:@"Result for '%@',\
                         \r date: %@\
                         \r location: %@\
                         \r people: %@",
                         self.speech, self.date, self.location, self.persons];
    return result;
}

@end
