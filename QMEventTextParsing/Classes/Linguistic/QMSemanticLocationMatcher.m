//
//  QMSemanticLocationMatcher.m
//  QromaScan
//
//  Created by bucha on 9/3/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMSemanticLocationMatcher.h"
#import "QMSemanticMatcher+Private.h"


@interface QMSemanticLocationMatcher ()

@property (strong, nonatomic, readwrite) NSArray<NSString *> * targetPrepositions;
@property (copy, nonatomic, readwrite) NSString * possibleLocation;

@property (assign, nonatomic) BOOL hasPlaceName;
@property (assign, nonatomic) BOOL hasPersonName;
@property (assign, nonatomic) BOOL hasNumber;
@property (assign, nonatomic) BOOL hasNoun;
@property (assign, nonatomic) BOOL hasPronoun;
@property (assign, nonatomic) BOOL hasUppercase;
@property (assign, nonatomic) BOOL hasDefinedArticle;
@property (assign, nonatomic) BOOL hasNotTargetPreposition;
@property (assign, nonatomic) BOOL beginWithTargetPreposition;
@property (assign, nonatomic) BOOL hasForbiddenType;
@property (assign, nonatomic) BOOL hasUnifyingPreposition;
@property (assign, nonatomic) BOOL hasOrganizationName;

@end


@implementation QMSemanticLocationMatcher

//MARK: - property -

- (BOOL)hasResults {
    BOOL result =  self.hasForbiddenType == NO
                   && self.hasUppercase;
    return result;
}

- (BOOL)hasDominant {
    BOOL result = self.hasOrganizationName
                  || self.hasPlaceName
                  || self.hasUnifyingPreposition; // possible not needed
    return result;
}

//- (BOOL)hasComplete {
//    BOOL result = ;
//    return result;
//}

- (BOOL)shouldProcess {
    BOOL result = self.hasPersonName == NO
                  && self.hasPronoun == NO
                  && (self.beginWithTargetPreposition || self.hasNumber);
    return result;
}

- (BOOL)shouldFail {
    if (self.hasDominant) {
        return NO;
    }
    
    BOOL result = self.shouldProcess == NO
                  || (self.finished && (self.hasNoun == NO && self.hasPlaceName == NO));
    return result;
}

- (BOOL)beginWithTargetPreposition {
    BOOL result = [self.targetPrepositions indexOfObject: self.sequenceDelimiter.token.lowercase] != NSNotFound;
    return result;
}

- (NSString *)location {
    NSString * result = @"";
    for (QMSemanticChunk * chunk in self.chunks) {
        if (chunk.type == QMSemanticTypeDefinedArticle) {
            continue;
        }
        
        if (chunk.type == QMSemanticTypePreposition) {
            continue;
        }
        result = [result stringByAppendingFormat:@"%@ ", chunk.token.text];
    }
    
    result = [result stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    return result;
}


- (NSString *)precisionLocation {
    NSString * result = @"";
    for (QMSemanticChunk * chunk in self.chunks) {
        if (self.hasOrganizationName  && chunk.type != QMSemanticTypeOrganizationName) {
            continue;
        }
        
        if (self.hasPlaceName  && chunk.type != QMSemanticTypePlaceName) {
            continue;
        }

        result = [result stringByAppendingFormat:@"%@ ", chunk.token.text];
    }
    
    result = [result stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    return result;
}

//MARK: - life cycle -

+ (instancetype) matcherUsing: (NSArray<NSString *> *) targetPrepositions {
    QMSemanticLocationMatcher * result = [[self class] new];
    
    result.targetPrepositions = targetPrepositions;
    
    return result;
}

//MARK: - logic -

- (BOOL) shouldUpdateMatchFor: (QMSemanticChunk *) chunk {
    BOOL result = chunk.type != QMSemanticTypePreposition;
    return result;
}

- (BOOL) processChunk: (QMSemanticChunk *) chunk {
    
    if (self.hasDominant) {
        BOOL couldProcess = chunk.type == QMSemanticTypeNoun
                            || chunk.type == QMSemanticTypeAdjective
                            || (self.hasOrganizationName && chunk.type == QMSemanticTypeOrganizationName)
                            || (self.hasPlaceName && chunk.type == QMSemanticTypePlaceName);
        if (couldProcess == NO) {
            self.hasComplete = YES;
            return NO;
        }
    }
    
    switch (chunk.type) {
        case QMSemanticTypeNoun: {

            self.hasNoun = YES;
            self.hasUppercase = [chunk.token hasFirstLetterUppercase];
            
        } break;
        
        case QMSemanticTypePlaceName: {
            self.hasPlaceName = YES;
        } break;
            
            
        case QMSemanticTypeOrganizationName: {
            self.hasOrganizationName = YES;
        } break;
        
        case QMSemanticTypePersonalName: {
            if (self.beginWithTargetPreposition == NO) {
                self.hasPersonName = YES;
            } else {
                self.hasNoun = YES;
            }
        } break;
        
        case QMSemanticTypeNumber: {
            self.hasNumber = YES;
        } break;
        
        case QMSemanticTypePreposition: {
            self.hasNotTargetPreposition = YES;
        } break;
        
        case QMSemanticTypeDefinedArticle: {
            self.hasDefinedArticle = YES;
        } break;
        
        case QMSemanticTypeUnifyingPreposition: {
            self.hasUnifyingPreposition = YES;
        }

        default: {
            self.hasForbiddenType = YES;
        }
        break;
    }
    
    return YES;
}

- (void) processFinish {

}

- (NSString *) description {
    
    NSString * result = [super description];
    result = [result stringByAppendingFormat: @" location = %@", self.location];
    return result;
}

@end
