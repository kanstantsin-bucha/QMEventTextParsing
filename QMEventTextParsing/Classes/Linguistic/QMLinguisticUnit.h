//
//  QMLinguisticUnit.h
//  QromaScan
//
//  Created by bucha on 8/31/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QMSemanticMatcher.h"
#import "QMSemanticDateMatcher.h"
#import "QMSemanticPersonMatcher.h"
#import "QMSemanticLocationMatcher.h"
#import "QMTextRecognitionConfig.h"
#import "QMPeopleEntitled.h"


@interface QMLinguisticUnit : NSObject

@property (strong, nonatomic) QMSemanticMatcher * sequence;

@property (strong, nonatomic, readonly, nullable)  NSArray<QMSemanticDateMatcher *> * dateMatches;
@property (strong, nonatomic, readonly, nullable)  NSArray<QMSemanticPersonMatcher *> * personMatches;
@property (strong, nonatomic, readonly, nullable)  NSArray<QMSemanticLocationMatcher *> * locationMatches;

@property (strong, nonatomic, readonly, nullable) NSString * locationDescription;
@property (strong, nonatomic, readonly, nullable) NSString * precisionLocationDescription;

@property (strong, nonatomic, readonly, nonnull) id<QMTextRecognitionConfigInterface> config;
@property (strong, nonatomic, readonly, nullable) id<QMPeopleEntitledInterface> peopleEntitled;

+ (instancetype _Nullable) unitUsingConfiguration: (id<QMTextRecognitionConfigInterface> _Nonnull) config
                                   peopleEntitled: (id<QMPeopleEntitledInterface> _Nonnull) entitled;

- (void) start;
- (void) appendChunk: (QMSemanticChunk * _Nonnull) chunk;
- (void) finish;

@end
