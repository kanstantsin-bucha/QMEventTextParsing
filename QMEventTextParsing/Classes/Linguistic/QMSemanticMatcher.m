//
//  QMSemanticMatcher.m
//  QromaScan
//
//  Created by bucha on 8/27/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMSemanticMatcher+Private.h"


@interface QMSemanticMatcher ()

@property (strong, nonatomic, readwrite) NSMutableArray<QMSemanticChunk *> * chunksBucket;

@property (assign, nonatomic, readwrite) BOOL finished;

@end


@implementation QMSemanticMatcher

//MARK: - proprty -

- (NSArray<QMSemanticChunk *> *)chunks {
    return [self.chunksBucket copy];
}

//MARK: - life cycle -

- (instancetype)init {
    self = [super init];
    if (self) {
        _chunksBucket = [NSMutableArray array];
        _match = QMSemanticeMatchProcessing;
    }
    return self;
}

//MARK: - interface -

- (void) appendChunk: (QMSemanticChunk *) chunk {
    if (self.match == QMSemanticeMatchFailed
        || self.match == QMSemanticeMatchComplete) {
        return;
    }

    if (chunk == nil) {
        return;
    }
    
    BOOL shouldUpdateMatch = [self shouldUpdateMatchFor: chunk];
    
    BOOL shouldAdd = [self processChunk: chunk];
    
    if (shouldAdd) {
        [self.chunksBucket addObject: chunk];
    }
    
    if (shouldUpdateMatch) {
        [self determinateMatch];
    }
}

- (void)matchAgainstBestMatch:(QMSemanticeMatch)match {
    if (self.match == QMSemanticeMatchFailed) {
        return;
    }
    
    if (match > self.match) {
        self.match = QMSemanticeMatchFailed;
        NSLog(@"failed by best match: <%@>", NSStringFromClass([self class]));
    }
}

- (void) finish {
    [self processFinish];
    
    self.finished = YES;
    
    [self determinateMatch];
}

- (void) putAliveInBucket {
    if (self.match == QMSemanticeMatchUndefined
        || self.match == QMSemanticeMatchFailed
        || self.match == QMSemanticeMatchProcessing) {
        return;
    }
    
    [self.targetBucket addObject: self];
}

//- (void)removeElement:(QMSemanticChunk *)element {
//    if (element == nil) {
//        return;
//    }
//    [self.elementsHolder removeObject: element];
//}

//MARK: - logic -

- (void)determinateMatch {
    if (self.match == QMSemanticeMatchFailed) {
        return;
    }
    
    if (self.shouldFail) {
        self.match = QMSemanticeMatchFailed;
    } else {
        self.match = QMSemanticeMatchSoSo;
        
        if (self.hasResults) {
            self.match = QMSemanticeMatchResults;
        }
        
        if (self.hasDominant) {
            self.match = QMSemanticeMatchDominant;
        }
        
        if (self.hasComplete) {
            self.match = QMSemanticeMatchComplete;
        }
    }
    
    NSLog(@"%@ in <%@>", StringFromQMSemanticeMatch(self.match), NSStringFromClass([self class]));
}

- (BOOL) shouldUpdateMatchFor: (QMSemanticChunk *) chunk {
    return YES;
}

- (void) processDelimiter: (QMSemanticChunk *) delimiter {
    // Override in child implementation
}

- (BOOL) processChunk: (QMSemanticChunk *) chunk {
    return YES;
    // Override in child implementation
}

- (void) processFinish {
    // Override in child implementation
}

- (BOOL) isDelimiter: (QMSemanticChunk *) element {
    return NO;
}

- (NSString *) description {
    NSString * result = [NSString stringWithFormat: @" %@\r\n\
                                                       match= %@ \r\n\
                                                       shouldProcess = %@,\r\n\
                                                       shouldFail = %@,\r\n\
                                                       elements = %@ \r\n\
                                                      ",
                                                       NSStringFromClass([self class]), StringFromQMSemanticeMatch(self.match), NSStringFromBool(self.shouldProcess),
                                                       NSStringFromBool(self.shouldFail), self.chunks];
    return result;
}

@end

