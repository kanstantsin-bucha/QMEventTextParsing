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

@property (strong, nonatomic, readonly, nonnull) id<QMTextRecognitionConfigInterface> config;

+ (instancetype _Nullable) taggerUsingConfiguration: (id<QMTextRecognitionConfigInterface> _Nonnull) config;

- (void) enumerateChunksInString: (NSString * _Nonnull) string
                      usingBlock: (void (^ _Nonnull)(QMSemanticChunk * chunk, BOOL * stop)) block;


@end
