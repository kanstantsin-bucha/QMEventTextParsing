//
//  QMSemanticLocationMatcher.h
//  QromaScan
//
//  Created by bucha on 9/3/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMSemanticMatcher.h"

@class
QMLocationInfo;

@interface QMSemanticLocationMatcher : QMSemanticMatcher

@property (strong, nonatomic, readonly) NSString * location;
@property (strong, nonatomic, readonly) NSString * precisionLocation;
@property (strong, nonatomic, readonly) QMLocationInfo * info;
@property (strong, nonatomic, readonly) NSArray<NSString *> * targetPrepositions;

+ (instancetype) matcherUsing: (NSArray<NSString *> *) targetPrepositions;

@end
