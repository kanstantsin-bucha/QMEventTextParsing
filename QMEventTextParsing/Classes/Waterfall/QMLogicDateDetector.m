//
//  QMLogicDateDetector.m
//  QromaScan
//
//  Created by bucha on 10/8/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMLogicDateDetector.h"
#import "QMLinguisticTagger.h"
#import "QMDetector+Private.h"
#import "QMDateParser.h"


@interface QMLogicDateDetector ()

@property (strong, nonatomic) id<QMPeopleEntitledInterface> entitled;
@property (strong, nonatomic) id<QMTextRecognitionConfigInterface> config;

@property (strong, nonatomic) NSMutableArray<NSString *> * detectedPlacesBucket;
@property (strong, nonatomic) NSMutableArray<NSString *> * detectedOrganizationsBucket;

@property (strong, nonatomic) QMLinguisticTagger * tagger;

@property (strong, nonatomic, readwrite) NSDate * detectedDate;
@property (strong, nonatomic) QMDateParser * dateParser;

@end

@interface QMDateElement : NSObject

@property (strong, nonatomic) QMSemanticChunk * chunk;
@property (assign, nonatomic) NSInteger value;

+ (instancetype)elementUsing: (QMSemanticChunk *) chunk
                       value: (NSInteger) value;

@end

@implementation QMDateElement

+ (instancetype)elementUsing: (QMSemanticChunk *) chunk
                       value: (NSInteger) value {
    if (chunk == nil
        || value == NSNotFound) {
        return nil;
    }
    
    QMDateElement * result = [QMDateElement new];
    result.value = value;
    result.chunk = chunk;
    
    return result;
}

- (NSString *)description {
    NSString * result = [NSString stringWithFormat: @"chunk: %@\r value: %@", self.chunk, @(self.value)];
    return result;
}

@end

@implementation QMLogicDateDetector

    //MARK: - property -

- (QMLinguisticTagger *) tagger {
    if (_tagger != nil) {
        return _tagger;
    }
    
    _tagger = [QMLinguisticTagger taggerUsingConfiguration: self.config];
    return _tagger;
}

- (BOOL)failed {
    BOOL result = self.detectedDate == nil;
    return result;
}

- (NSString *)detectedValueDescription {
    NSString * result = [NSString stringWithFormat: @"date: %@", self.detectedDate];
    return result;
}

    //MARK: - life cycle -

+ (instancetype) detectorUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config
                             peopleEntitled: (id<QMPeopleEntitledInterface>) entitled {
    
    QMDateParser * dateParser = [QMDateParser parserUsing: config.locale];
    
    if (entitled == nil
        || config.language == nil
        || config.calendar == nil
        || dateParser == nil) {
        
        return nil;
    }
    
    QMLogicDateDetector * result = [[self class] new];
    
    result.entitled = entitled;
    result.config = config;
    result.dateParser = dateParser;
    
    return result;
}

    //MARK: - logic -

- (void)detectDataUsingString: (NSString *) string
                   completion: (CDBObjectErrorCompletion)completion {
    if (completion == nil) {
        return;
    }
    
    self.detected = [NSMutableArray array];
    self.possible = [NSMutableArray array];
    self.detectedPlacesBucket = [NSMutableArray array];
    self.detectedOrganizationsBucket = [NSMutableArray array];
    
    NSMutableArray * chunks = [NSMutableArray array];
    
    weakCDB(wself);
    
    [self.tagger enumerateChunksInString: string
                              usingBlock: ^ (QMSemanticChunk *chunk, BOOL * stop) {
        [chunks addObject: chunk];
    }];
    
    QMDateElement * detectedYear = nil;
    QMDateElement * detectedMonth = nil;
    QMDateElement * detectedDay = nil;
    
    detectedMonth = [self dateElementInChunks: chunks
                           usingSubstitutions: self.config.months];
    
    if (detectedMonth != nil) {
        NSInteger backwardPosition = detectedMonth.chunk.position - 1;
        detectedDay = [self dayDateElementAtPosition: backwardPosition
                                               using: chunks];
        if (detectedDay == nil) {
            NSInteger forwardPosition = detectedMonth.chunk.position + 1;
            detectedDay = [self dayDateElementAtPosition: forwardPosition
                                                   using: chunks];
        }
    }
    
    if (detectedMonth == nil) {
        detectedMonth = [self dateElementInChunks: chunks
                               usingSubstitutions: self.config.seasons];
    }
    
    NSInteger yearSearchPosition = NSNotFound;
    if (detectedMonth != nil) {
        yearSearchPosition = detectedMonth.chunk.position + 1;
    } else  {
        yearSearchPosition = 0;
    }
    
    detectedYear = [self yearDateElementBeginWithPosition: yearSearchPosition
                                                    using: chunks];
   
    if (detectedDay != nil) {
        [self.detected addObject: detectedDay.chunk];
    }
    if (detectedMonth != nil) {
        [self.detected addObject: detectedMonth.chunk];
    }
    if (detectedYear != nil) {
        [self.detected addObject: detectedYear.chunk];
    }
    
    [self.possible addObjectsFromArray: self.detected];
    
    self.detectedDate = [self.dateParser dateFromDay: detectedDay == nil ? NSNotFound : detectedDay.value
                                               month: detectedMonth == nil ? NSNotFound : detectedMonth.value
                                                year: detectedYear == nil ? NSNotFound : detectedYear.value
                                               using: self.config.calendar];
    
    
    if (self.failed == NO) {
        
        NSString * passedBy = [self stringByReducing: string
                                         usingChunks: self.detected];
        
        passedBy = [self stringByTrimmingMultipleSpacesIn: passedBy];
        completion(passedBy, nil);
        return;
    }
    
    if (self.possible.count > 0) {
        NSString * possible = [NSString stringWithFormat:@"day: '%@'\r month: '%@'\r year: '%@'\r",
                               detectedDay, detectedMonth, detectedYear];
        NSError * error = [wself notValidatedErrorUsingString: possible];
        completion(string, error);
        return;
    }
    
    NSError * error = [wself notFoundErrorUsingString: string];
    completion(string, error);
}

- (QMDateElement *) yearDateElementBeginWithPosition: (NSInteger) position
                                               using: (NSArray<QMSemanticChunk *> *) chunks {
    
    if (position < 0
        || position >= chunks.count) {
        return nil;
    }
    
    QMDateElement * result = nil;
    
    while (position < chunks.count
           && result == nil) {
        QMSemanticChunk * chunk = chunks[position];
        NSInteger value = [self.dateParser yearUsingNumberSequence: chunk.token.lowercase];
        
        position += 1;
        
        if (value == NSNotFound) {
            continue;
        }
        
        result = [QMDateElement elementUsing: chunk
                                       value: value];
    }
    
    return result;
}

- (QMDateElement *) dayDateElementAtPosition: (NSInteger)position
                                       using: (NSArray<QMSemanticChunk *> *) chunks {
    if (position < 0
        || position >= chunks.count) {
        return nil;
    }
    
    QMSemanticChunk * chunk = chunks[position];
    NSInteger value = [self.dateParser dayUsingNumberSequence: chunk.token.lowercase];
    
    if (value == NSNotFound) {
        return nil;
    }
    
    QMDateElement * result = [QMDateElement elementUsing: chunk
                                                   value: value];
    return result;
    
}

- (QMDateElement *) dateElementInChunks: (NSArray<QMSemanticChunk *> *) chunks
                     usingSubstitutions: (NSDictionary<NSString *, NSNumber *> *) substitutions {
    for (QMSemanticChunk * chunk in chunks) {
        NSInteger number = [self numberForToken: chunk.token.lowercase
                             usingSubstitutions: substitutions];
        
//        NSLog(@"token : %@, number: %@", chunk.token.lowercase, @(number));
        
        if (number == NSNotFound) {
            continue;
        }
        
        QMDateElement * result = [QMDateElement elementUsing: chunk
                                                       value: number];
        return result;
    }
    return  nil;
}

- (NSInteger) numberForToken: (NSString *) token
         usingSubstitutions: (NSDictionary<NSString *, NSNumber *> *) substitutions {
    
    if (token == nil) {
        return NSNotFound;
    }
    
    NSNumber * number = substitutions[token];
    if (number == nil) {
        return NSNotFound;
    }
    
    return number.integerValue;
}

    //MARK: - logic -

- (NSError *)notValidatedErrorUsingString: (NSString *) string {
    NSString * desc = [NSString stringWithFormat: @"<%@> Date elements found '%@' but validation failed",
                       NSStringFromClass([self class]), string];
    
    NSError * result = [NSError errorWithDomain: NSStringFromClass([self class])
                                           code: 1
                                       userInfo: @{NSLocalizedDescriptionKey : desc}];
    return result;
}

- (NSError *)notFoundErrorUsingString: (NSString *) string {
    NSString * desc = [NSString stringWithFormat: @"<%@> Place/Organization not found in '%@'",
                       NSStringFromClass([self class]), string];
    
    NSError * result = [NSError errorWithDomain: NSStringFromClass([self class])
                                           code: 0
                                       userInfo: @{NSLocalizedDescriptionKey : desc}];
    return result;
}


@end
