//
//  QMSemanticChunk.m
//  QromaScan
//
//  Created by bucha on 8/31/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMSemanticChunk.h"


@interface QMSemanticChunk ()

@property (strong, nonatomic, readwrite) QMLinguisticToken * token;
@property (assign, nonatomic, readwrite) NSRange range;
@property (assign, nonatomic, readwrite) NSInteger position;

@end

@implementation QMSemanticChunk

//MARK: - life cycle -

+ (instancetype) chunkUsingText: (NSString *) text
                   semanticType: (QMSemanticType) type
                          range: (NSRange) range
                       position: (NSInteger) position {
    
    QMLinguisticToken * token = [QMLinguisticToken tokenUsingText: text];
    
    if (token == nil) {
        
        return nil;
    }
    
    QMSemanticChunk * result = [QMSemanticChunk new];
    result.type = type;
    result.range = range;
    result.position = position;
    
   
    result.token = token;

    return result;
}

//MARK: - interface -

- (BOOL) isEqualToChunk: (QMSemanticChunk *) chunk {
    if (chunk == nil) {
        return NO;
    }
    
    BOOL haveEqualTypes = self.type == chunk.type;
    if (haveEqualTypes == NO) {
        return NO;
    }

    BOOL haveEqualTokens = (self.token != nil && chunk.token != nil) && [self.token.text isEqualToString: chunk.token.text];
    if (haveEqualTokens == NO) {
        return NO;
    }
    
    return YES;
}

- (BOOL) isEqual: (id) object {
    if (self == object) {
        return YES;
    }

    if ([object isKindOfClass: [QMSemanticChunk class]] == NO) {
        return NO;
    }

    BOOL result =  [self isEqualToChunk: (QMSemanticChunk *) object];
    return result;
}

- (NSUInteger)hash {
    NSUInteger result = [self.token hash] ^ self.type;
    return result;
}

- (NSString *) description {
    NSString * result = [NSString stringWithFormat: @" %@, %@ <%@>",
                         self.token.text, StringFromLinguisticTokenType(self.type), NSStringFromClass([self class])];
    return result;
}

@end
