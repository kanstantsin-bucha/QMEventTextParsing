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

@property (strong, nonatomic, readonly)  NSArray<QMSemanticDateMatcher *> * dateMatches;
@property (strong, nonatomic, readonly)  NSArray<QMSemanticPersonMatcher *> * personMatches;
@property (strong, nonatomic, readonly)  NSArray<QMSemanticLocationMatcher *> * locationMatches;

@property (strong, nonatomic, readonly) NSString * locationDescription;
@property (strong, nonatomic, readonly) NSString * precisionLocationDescription;

@property (strong, nonatomic, readonly) id<QMTextRecognitionConfigInterface> config;
@property (strong, nonatomic, readonly) id<QMPeopleEntitledInterface> peopleEntitled;

+ (instancetype) unitUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config
                         peopleEntitled: (id<QMPeopleEntitledInterface>) entitled;

- (void) start;
- (void) appendChunk: (QMSemanticChunk *) chunk;
- (void) finish;

@end
