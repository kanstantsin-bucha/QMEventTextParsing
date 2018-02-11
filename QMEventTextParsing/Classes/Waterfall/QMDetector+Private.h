//
//  QMDetector+Private.h
//  QromaScan
//
//  Created by bucha on 10/8/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMDetector.h"


@interface QMDetector ()

@property (strong, nonatomic) NSMutableArray<QMSemanticChunk *> * detected;
@property (strong, nonatomic) NSMutableArray<QMSemanticChunk *> * possible;
@property (assign, nonatomic, readwrite) BOOL failed;

- (NSString *) stringByTrimmingMultipleSpacesIn: (NSString *) string;
//- (NSString *) stringByReducing: (NSString *) string
//                    usingRanges: (NSArray<NSValue *> *) ranges;
- (NSString *) stringByReducing: (NSString *) string
                    usingChunks: (NSArray<QMSemanticChunk *> *) chunks;

@end
