//
//  QMLinguisticUnit.m
//  QromaScan
//
//  Created by bucha on 8/31/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMLinguisticUnit.h"
#import "QMTExtRecognitionConfig.h"

@interface QMLinguisticUnit ()


@property (strong, nonatomic, readwrite)  NSMutableArray<QMSemanticDateMatcher *> * dateMatchesBucket;
@property (strong, nonatomic, readwrite)  NSMutableArray<QMSemanticPersonMatcher *> * personMatchesBucket;
@property (strong, nonatomic, readwrite)  NSMutableArray<QMSemanticLocationMatcher *> * locationMatchesBucket;

@property (strong, nonatomic)  QMSemanticDateMatcher * tmpDateMatch;
@property (strong, nonatomic)  QMSemanticPersonMatcher * tmpPersonMatch;
@property (strong, nonatomic)  QMSemanticLocationMatcher * tmpLocationMatch;

@property (strong, nonatomic) NSArray<QMSemanticMatcher *> * matchersBucket;

@property (strong, nonatomic) NSCalendar * calendar;

@property (strong, nonatomic, readwrite) id<QMTextRecognitionConfigInterface> config;
@property (strong, nonatomic, readwrite) id<QMPeopleEntitledInterface> peopleEntitled;

@end

@implementation QMLinguisticUnit

//MARK: - property -

- (NSArray<QMSemanticDateMatcher *> *)dateMatches {
    return [self.dateMatchesBucket copy];
}

- (NSArray<QMSemanticPersonMatcher *> *)personMatches {
    return [self.personMatchesBucket copy];
}

- (NSArray<QMSemanticLocationMatcher *> *)locationMatches {
    return [self.locationMatchesBucket copy];
}

- (NSCalendar *)calendar {
    if (_calendar != nil) {
        return _calendar;
    }
    _calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    return _calendar;
}

- (NSString *)locationDescription {
    NSString * result = @"";
    
    for (QMSemanticLocationMatcher * sequence in self.locationMatches) {
        result = [result stringByAppendingFormat:@"%@ ", sequence.location];
    }
    
    result = [self trimWhitespacesIn: result];
    
    return result.length > 0 ? result
                             : nil;
}

- (NSString *)precisionLocationDescription {
    NSString * result = @"";
    
    for (QMSemanticLocationMatcher * sequence in self.locationMatches) {
        NSString * location = sequence.precisionLocation;
        if (location.length == 0) {
            continue;
        }
        result = [result stringByAppendingFormat:@"%@ ", location];
    }
    
    result = [self trimWhitespacesIn: result];
    
    return result.length > 0 ? result
                             : nil;
}

//MARK: - life cycle -

+ (instancetype) unitUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config
                         peopleEntitled: (id<QMPeopleEntitledInterface>) entitled {
    if (config == nil) {
        
        return nil;
    }
    
    QMLinguisticUnit * result = [[self class] new];
    result.config = config;
    result.peopleEntitled = entitled;
    
    return result;
}

//MARK: - interface -

- (void) start {
    NSLog(@"start");
    
    self.dateMatchesBucket = [NSMutableArray array];
    self.personMatchesBucket = [NSMutableArray array];
    self.locationMatchesBucket = [NSMutableArray array];
    
    self.matchersBucket = [self startMatchinggSequenceBeginWithDelimiter: nil];
}

- (void) appendChunk: (QMSemanticChunk *) chunk {

    NSLog(@"=> %@", chunk);
    
    BOOL gotTrueLocation = chunk.type == QMSemanticTypePlaceName
                           || chunk.type == QMSemanticTypeOrganizationName;
    
    BOOL hasFailedLocaitonMatch = self.tmpLocationMatch.match == QMSemanticeMatchFailed;
    
    BOOL hasValuablePreposition = chunk.type == QMSemanticTypePreposition;
    
    BOOL shouldWrapUpCurrentBucket = hasValuablePreposition
                                     || (gotTrueLocation && hasFailedLocaitonMatch);
    
    if (shouldWrapUpCurrentBucket) {
        [self wrapUpCurrentBucketUsingFirstChunk: chunk];
    }
    
    [self appendChunk: chunk
                using: self.matchersBucket];

    if ([self hasCompliteMatchIn: self.matchersBucket]) {
        [self wrapUpCurrentBucketUsingFirstChunk: chunk];
        [self appendChunk: chunk
                    using: self.matchersBucket];
    }
    
    QMSemanticeMatch bestMatch = [self gatherBestMatchUsing: self.matchersBucket];
    [self matchAginstBestMatch: bestMatch
                         using: self.matchersBucket];
    
}

- (void) wrapUpCurrentBucketUsingFirstChunk: (QMSemanticChunk *) chunk {
    [self finishMatchers: self.matchersBucket];
    QMSemanticChunk * delimiter = chunk.type == QMSemanticTypePreposition ? chunk
                                                                          : nil;
    self.matchersBucket = [self startMatchinggSequenceBeginWithDelimiter: delimiter];
}

- (NSArray<QMSemanticMatcher *> *) startMatchinggSequenceBeginWithDelimiter: (QMSemanticChunk *) delimiter {
    NSLog(@"start matchers");

    NSMutableDictionary<NSString *, NSNumber *> * substitutions = [self.config.months mutableCopy];
    if (self.config.seasons.allKeys.count > 0) {
        [substitutions addEntriesFromDictionary:self.config.seasons];
    }
    self.tmpDateMatch = [QMSemanticDateMatcher matcherUsing: [substitutions copy]
                                                   calendar: self.calendar
                                                     locale: self.config.locale];
    self.tmpDateMatch.sequenceDelimiter = delimiter;
    self.tmpDateMatch.targetBucket = (NSMutableArray<QMSemanticMatcher *> *) self.dateMatchesBucket;

    self.tmpPersonMatch = [QMSemanticPersonMatcher matcherUsing: self.peopleEntitled
                                          forbiddenPrepositions: self.config.locationPrepositions];
    self.tmpPersonMatch.sequenceDelimiter = delimiter;
    self.tmpPersonMatch.targetBucket = (NSMutableArray<QMSemanticMatcher *> *) self.personMatchesBucket;

    self.tmpLocationMatch = [QMSemanticLocationMatcher matcherUsing: self.config.locationPrepositions];
    self.tmpLocationMatch.sequenceDelimiter = delimiter;
    self.tmpLocationMatch.targetBucket = (NSMutableArray<QMSemanticMatcher *> *) self.locationMatchesBucket;
    
    NSArray<QMSemanticMatcher *> * result = @[
                                              self.tmpDateMatch,
                                              self.tmpPersonMatch,
                                              self.tmpLocationMatch
                                             ];
    return result;
}

- (void) finishMatchers: (NSArray<QMSemanticMatcher *> *) matchers {
    NSLog(@"finish matchers");
    for (QMSemanticMatcher * matcher in matchers) {
        [matcher finish];
    }
    
    [self gatherMatches: matchers];
}

- (void) finish {
   NSLog(@"finish");
   [self finishMatchers: self.matchersBucket];
   
   NSLog(@"Matchers : \r\n dates = %@ \r\n persons = %@\r\n locations = %@\r\n",
         self.dateMatchesBucket, self.personMatchesBucket, self.locationMatchesBucket);
}

- (void) gatherMatches: (NSArray<QMSemanticMatcher *> *) matchers {
    NSLog(@"gather alive matches");
    for (QMSemanticMatcher * matcher in matchers) {
        [matcher putAliveInBucket];
    }
}

- (void) matchAginstBestMatch: (QMSemanticeMatch) best
                        using: (NSArray<QMSemanticMatcher *> *) matchers {
    for (QMSemanticMatcher * matcher in matchers) {
        [matcher matchAgainstBestMatch: best];
    }
}

- (void) appendChunk: (QMSemanticChunk *) chunk
               using: (NSArray<QMSemanticMatcher *> *) matchers {
    for (QMSemanticMatcher * matcher in matchers) {
        [matcher appendChunk: chunk];
    }
}

- (BOOL) hasCompliteMatchIn: (NSArray<QMSemanticMatcher *> *) matchers {
    for (QMSemanticMatcher * matcher in matchers) {
        if (matcher.match == QMSemanticeMatchComplete) {
            return YES;
        }
    }
            
    return NO;
}

- (QMSemanticeMatch) gatherBestMatchUsing: (NSArray<QMSemanticMatcher *> *) matchers {
    QMSemanticeMatch result = QMSemanticeMatchUndefined;
    for (QMSemanticMatcher * matcher in matchers) {
        if (matcher.match > result) {
            result = matcher.match;
        }
    }
    
    NSLog(@"gather best match: %@", StringFromQMSemanticeMatch(result));
    return result;
}

- (NSString *) trimWhitespacesIn: (NSString *) string {
    NSString * result = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    return result;
}

@end
