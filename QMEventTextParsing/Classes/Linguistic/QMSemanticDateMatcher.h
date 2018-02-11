//
//  QMSemanticDateMatcher.h
//  QromaScan
//
//  Created by bucha on 9/1/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMSemanticMatcher.h"


@interface QMSemanticDateMatcher : QMSemanticMatcher

@property (strong, nonatomic, readonly) NSDictionary<NSString *, NSNumber *> * noun2MonthSubstitution;

@property (assign, nonatomic, readonly) NSInteger day;
@property (assign, nonatomic, readonly) NSInteger month;
@property (assign, nonatomic, readonly) NSInteger year;

@property (assign, nonatomic, readonly) NSDate * date;

+ (instancetype) matcherUsing: (NSDictionary<NSString *, NSNumber *> *) noun2MonthSubstitution
                     calendar: (NSCalendar *) calendar;

@end
