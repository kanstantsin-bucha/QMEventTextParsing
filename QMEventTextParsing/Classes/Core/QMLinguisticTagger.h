//
//  QMLinguisticTagger.h
//  QromaScan
//
//  Created by bucha on 10/5/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMSemanticChunk.h"
#import "QMTextRecognitionConfig.h"


@interface QMLinguisticTagger : NSObject

@property (strong, nonatomic, readonly) id<QMTextRecognitionConfigInterface> config;

+ (instancetype) taggerUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config;

- (void) enumerateChunksInString: (NSString *) string
                      usingBlock: (void (^)(QMSemanticChunk * chunk, BOOL *stop)) block;


@end
