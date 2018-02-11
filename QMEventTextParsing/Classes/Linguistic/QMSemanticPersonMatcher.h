//
//  QMSemanticPersonMatcher.h
//  QromaScan
//
//  Created by bucha on 9/2/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMSemanticMatcher.h"
#import "QMPeopleEntitled.h"

@interface QMSemanticPersonMatcher : QMSemanticMatcher

@property (copy, nonatomic, readonly) NSArray<NSString *> * persons;

+ (instancetype) matcherUsing: (id<QMPeopleEntitledInterface>) peopleEntitled
        forbiddenPrepositions: (NSArray<NSString *> *) forbiddenPrepositions;

@end
