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

@property (copy, nonatomic, readonly, nullable) NSArray<NSString *> * persons;

+ (instancetype _Nullable) matcherUsing: (id<QMPeopleEntitledInterface> _Nonnull) peopleEntitled
                  forbiddenPrepositions: (NSArray<NSString *> * _Nonnull) forbiddenPrepositions;

@end
