//
//  QMSemanticMatcher.h
//  QromaScan
//
//  Created by bucha on 8/27/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CDBKit/CDBKit.h>
#import "QMSemanticChunk.h"
#import "QMSemantic.h"

@interface QMSemanticMatcher : NSObject

@property (strong, nonatomic, readonly, nullable) NSArray<QMSemanticChunk *> * chunks;

@property (strong, nonatomic, nullable) QMSemanticChunk * sequenceDelimiter;
@property (assign, nonatomic) QMSemanticeMatch match;

@property (assign, nonatomic, readonly) BOOL finished;

@property (weak, nonatomic, nullable) NSMutableArray<QMSemanticMatcher *> * targetBucket;

- (void) appendChunk: (QMSemanticChunk * _Nonnull) chunk;
- (void) matchAgainstBestMatch: (QMSemanticeMatch) match;
- (void) finish;

- (void) putAliveInBucket;

@end

