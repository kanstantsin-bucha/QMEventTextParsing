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

@property (strong, nonatomic, readonly, nullable) NSString * location;
@property (strong, nonatomic, readonly, nullable) NSString * precisionLocation;
@property (strong, nonatomic, readonly, nullable) QMLocationInfo * info;
@property (strong, nonatomic, readonly, nullable) NSArray<NSString *> * targetPrepositions;

+ (instancetype _Nullable) matcherUsing: (NSArray<NSString *> * _Nonnull) targetPrepositions;

@end
