//
//  QMSemanticChunk.h
//  QromaScan
//
//  Created by bucha on 8/31/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMSemantic.h"
#import "QMLinguisticToken.h"


@interface QMSemanticChunk : NSObject

@property (strong, nonatomic, readonly) QMLinguisticToken * token;
@property (assign, nonatomic, readonly) NSRange range;
@property (assign, nonatomic, readonly) NSInteger position;

@property (assign, nonatomic) QMSemanticType type;

+ (instancetype) chunkUsingText: (NSString *) text
                   semanticType: (QMSemanticType) type
                          range: (NSRange) range
                       position: (NSInteger) position;

@end



