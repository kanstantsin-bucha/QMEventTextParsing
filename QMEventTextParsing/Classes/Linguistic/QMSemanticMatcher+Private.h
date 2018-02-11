//
//  QMSemanticMatcher+Private.h
//  QromaScan
//
//  Created by bucha on 9/1/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMSemanticMatcher.h"

#ifndef QMSemanticMatcher_Private_h
#define QMSemanticMatcher_Private_h

@interface QMSemanticMatcher ()

@property (assign, nonatomic) BOOL hasResults;
@property (assign, nonatomic) BOOL hasDominant;
@property (assign, nonatomic) BOOL hasComplete;

@property (assign, nonatomic) BOOL shouldProcess;
@property (assign, nonatomic) BOOL shouldFail;


- (BOOL) shouldUpdateMatchFor: (QMSemanticChunk *) chunk;

- (void) processDelimiter: (QMSemanticChunk *) delimiter;
- (BOOL) processChunk: (QMSemanticChunk *) chunk;
- (void) processFinish;

- (void) determinateMatch;

@end

#endif /* QMSemanticMatcher_Private_h */
