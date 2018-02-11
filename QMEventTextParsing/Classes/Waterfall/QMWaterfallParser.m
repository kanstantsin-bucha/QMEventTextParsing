//
//  QMWaterfallParser.m
//  QromaScan
//
//  Created by bucha on 10/5/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMWaterfallParser.h"
#import <QMGeocoder/QMGeocoder.h>
#import "QMTextRecognitionConfig.h"
#import "QMParserResult+Private.h"

#import "QMDateDataDetector.h"
#import "QMPlaceDataDetector.h"
#import "QMPeopleDataDetector.h"
#import "QMLogicPlaceDetector.h"
#import "QMLogicDateDetector.h"


@interface QMWaterfallParser ()

@property (strong, nonatomic, readwrite) id<QMTextRecognitionConfigInterface> config;
@property (strong, nonatomic, readwrite) id<QMPeopleEntitledInterface> peopleEntitled;

//@property (strong, nonatomic) NSCalendar * calendar;
//@property (strong, nonatomic) NSLinguisticTagger * tagger;
//@property (strong, nonatomic) NSString * language;

@property (strong, nonatomic) QMParserResult * result;
@property (copy, nonatomic) CDBObjectErrorCompletion completion;

@property (assign, nonatomic) QMGeocoderServiceProvider geocoderServiceProvider;

@property (strong, nonatomic) QMDateDataDetector * dateDetector;
@property (strong, nonatomic) QMPlaceDataDetector * placeDetector;
@property (strong, nonatomic) QMPeopleDataDetector * peopleDetector;
@property (strong, nonatomic) QMLogicPlaceDetector * logicPlaceDetector;
@property (strong, nonatomic) QMLogicDateDetector * logicDateDetector;

@end


@implementation QMWaterfallParser


//MARK: - property -

- (QMGeocoderServiceProvider) geocoderServiceProvider {
    
    switch (self.config.geocoderServiceProvider) {
            
        case QMGeocodingProviderTypeGoogle: {
            return QMGeocoderServiceGoogle;
        } break;
            
        case QMGeocodingProviderTypeApple:
        default: {
            return QMGeocoderServiceApple;
        } break;
    }
}

//MARK: - life cycle -

+ (instancetype) parserUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config
                           peopleEntitled: (id<QMPeopleEntitledInterface>) entitled {
    if (config.language == nil) {
        return nil;
    }
    
    QMWaterfallParser * result = [QMWaterfallParser new];
    
    result.peopleEntitled = entitled;
    result.config = config;
    
    return result;
}

#pragma mark  - public -

- (void) parseText: (NSString *) text
    withCompletion: (CDBObjectErrorCompletion) completion {
    
    if (completion == nil) {
        return;
    }
    
    self.completion = completion;
    self.result = [QMParserResult new];
    self.result.speech = text;
    
    self.dateDetector = [QMDateDataDetector detectorUsingLocale: self.config.locale];
    self.placeDetector = [QMPlaceDataDetector detectorUsingProvider: self.geocoderServiceProvider];
    self.peopleDetector = [QMPeopleDataDetector detectorUsingConfiguration: self.config
                                                        peopleEntitled: self.peopleEntitled];
    self.logicPlaceDetector = [QMLogicPlaceDetector detectorUsingConfiguration: self.config
                                                                peopleEntitled: self.peopleEntitled];
    self.logicDateDetector = [QMLogicDateDetector detectorUsingConfiguration: self.config
                                                              peopleEntitled: self.peopleEntitled];
    
    NSMutableArray<QMDetector *> * detectors = [NSMutableArray array];
    for (NSNumber * number in self.config.waterfallParserOrderList) {
        QMWaterfallDetectorType type = (QMWaterfallDetectorType)number.integerValue;
        switch (type) {
            case QMWaterfallDetectorTypeDateData: {
                [detectors addObject: self.dateDetector];
            }   break;
            case QMWaterfallDetectorTypePlaceData: {
                [detectors addObject: self.placeDetector];
            }   break;
                
            case QMWaterfallDetectorTypePeopleData: {
                [detectors addObject: self.peopleDetector];
            }   break;
                
            case QMWaterfallDetectorTypeLogicDate: {
                [detectors addObject: self.logicDateDetector];
            }   break;
            
            case QMWaterfallDetectorTypeLogicPlace: {
                [detectors addObject: self.logicPlaceDetector];
            }   break;
                
            case QMWaterfallDetectorTypeUndefined:
            default: {
            }    break;
        }
    }
    
    [self iterateDetectors: detectors
                     using: text];
}

- (void) iterateDetectors: (NSMutableArray<QMDetector *> *)detectors
                    using: (NSString *) speech {
    QMDetector * detector = detectors.firstObject;
    if (detector == nil) {
        [self gatherDetectorsResultsUsing: speech];
        return;
    }
    
    [detectors removeObjectAtIndex: 0];
    
    weakCDB(wself);
    [detector detectDataUsingString: speech
                         completion: ^(NSString *  _Nullable passedBy, NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"<%@> failed: %@", NSStringFromClass([detector class]), error.localizedDescription);
        } else {
          NSLog(@"<%@> found '%@',\r reducedString: '%@'", NSStringFromClass([detector class]), detector.detectedValueDescription, passedBy);
        }
                             
        [wself iterateDetectors: detectors
                          using: passedBy];
    }];
}

- (void) gatherDetectorsResultsUsing: (NSString *) speech {

    self.result.date =  self.dateDetector.detectedDate != nil ? self.dateDetector.detectedDate
                                                              : self.logicDateDetector.detectedDate;
    self.result.location =  self.placeDetector.detectedLocation != nil ? self.placeDetector.detectedLocation
                                                                       : self.logicPlaceDetector.detectedLocation;
    self.result.persons = self.peopleDetector.detectedPeople;
    
    if (self.logicPlaceDetector.failed == NO) {
        self.result.geocodedLocation = self.logicPlaceDetector.detectedPlaceGeocoderDescription;
    }
    
    NSLog(@"<%@> has gathered:\r date= %@\r place= %@\r people= %@\r from speech= %@",
          NSStringFromClass([self class]), self.result.date, self.result.location, self.result.persons, self.result.speech);
    
    self.completion(self.result, nil);
    
    self.result = nil;
    self.completion = nil;
    
    self.dateDetector = nil;
    self.placeDetector = nil;
    self.peopleDetector = nil;
    self.logicPlaceDetector = nil;
    self.logicDateDetector = nil;
}

//- (void) deepMindProcessSpeech: (NSString *) speech
//                  gatheredDate: (NSDate *) date
//                      location: (QMLocationInfo *) info {
//
//    NSMutableArray * placeNames = [NSMutableArray array];
//    NSMutableArray * organizationNames = [NSMutableArray array];
//    NSMutableArray * nouns = [NSMutableArray array];
//    NSMutableArray * pronouns = [NSMutableArray array];
//    NSMutableArray * numbers = [NSMutableArray array];
//
//    __block NSString * adjective = nil;
//
//    __block NSUInteger year = NSNotFound;
//    __block NSUInteger month = NSNotFound;
//    __block NSUInteger day = NSNotFound;
//
//    NSMutableArray * persons = [NSMutableArray array];
//    NSDictionary * relationships = self.peopleEntitled.relationships;
//
//    self.tagger.string = speech;
//    NSRange range = NSMakeRange(0, speech.length);
//
//    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitPunctuation
//    | NSLinguisticTaggerOmitWhitespace
//    | NSLinguisticTaggerJoinNames;
//
//    weakCDB(wself);
//    [self.tagger enumerateTagsInRange: range
//                               scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass
//                              options: options
//                           usingBlock: ^(NSLinguisticTag  _Nullable tag, NSRange tokenRange, NSRange sentenceRange, BOOL * _Nonnull stop) {
//                               NSString * detectedSequence = [speech substringWithRange: tokenRange];
//
//                               if ([tag isEqualToString: NSLinguisticTagAdjective]) {
//                                   adjective = detectedSequence;
//                               }
//
//                               if ([tag isEqualToString: NSLinguisticTagNoun]) {
//                                   BOOL shouldAdd = YES;
//                                   if (date == nil
//                                       && month == NSNotFound) {
//                                       NSInteger possibleMonth = [wself.monthStrings indexOfObject: detectedSequence.uppercaseString];
//                                       if (possibleMonth != NSNotFound) {
//                                           month = possibleMonth + 1;
//                                           shouldAdd = NO;
//                                       }
//                                   }
//                                   if (shouldAdd
//                                       && relationships != nil) {
//                                       NSArray * substitutionalPersons = relationships[detectedSequence.uppercaseString];
//                                       if (substitutionalPersons.count > 0) {
//                                           [persons addObjectsFromArray: substitutionalPersons];
//                                           shouldAdd = NO;
//                                       }
//                                   }
//
//                                   if (shouldAdd) {
//                                       NSString * resultingNoun = detectedSequence;
//                                       if (adjective != nil) {
//                                           resultingNoun = [adjective stringByAppendingFormat: @" %@", detectedSequence];
//                                       }
//                                       [nouns addObject: resultingNoun];
//                                   }
//
//                                   adjective = nil;
//                               }
//
//                               if ([tag isEqualToString: NSLinguisticTagPronoun]) {
//                                   BOOL shouldAdd = YES;
//                                   if (relationships != nil) {
//                                       NSArray * substitutionalPersons = relationships[detectedSequence.uppercaseString];
//                                       if (substitutionalPersons.count > 0) {
//                                           [persons addObjectsFromArray: substitutionalPersons];
//                                           shouldAdd = NO;
//                                       }
//                                   }
//                                   if (shouldAdd) {
//                                       [pronouns addObject: detectedSequence];
//                                   }
//                               }
//
//                               if ([tag isEqualToString: NSLinguisticTagPersonalName]) {
//                                   [persons addObject: detectedSequence];
//                               }
//
//                               if ([tag isEqualToString: NSLinguisticTagOrganizationName]) {
//                                   [organizationNames addObject: detectedSequence];
//                               }
//
//                               if ([tag isEqualToString: NSLinguisticTagPlaceName]) {
//                                   [placeNames addObject: detectedSequence];
//                               }
//
//                               if ([tag isEqualToString: NSLinguisticTagNumber]) {
//                                   if (date == nil &&
//                                       year == NSNotFound) {
//                                       year = [self yearUsingNumberSequence: detectedSequence];
//                                   }
//
//                                   if (date == nil &&
//                                       day == NSNotFound) {
//                                       day = [wself dayUsingNumberSequence: detectedSequence];
//                                   }
//
//                                   [numbers addObject: detectedSequence];
//                               }
//                           }];
//
//    NSLog(@"Deep Mind found people: %@, places: %@ org...s: %@ numbers: %@", persons, placeNames, organizationNames, numbers);
//    NSLog(@"Deep Mind have skipped nouns: %@ pronouns: %@", nouns, pronouns);
//
//    if (date == nil) {
//        NSDate * foundOne = [self dateUsingGatheredDay: day
//                                                 month: month
//                                                  year: year];
//        if (foundOne != nil) {
//            date = foundOne;
//            NSLog(@"Deep Mind processing reveal date: %@", date);
//        }
//    }
//
//    if (placeNames.count == 0) {
//        [self handleGatheredDate: date
//                        location: info
//                         persons: persons];
//        return;
//    }
//
//    //TODO: improve location based on organization or place names
//
//    NSString * placeDescription = @"";
//
//    for (NSString * place in placeNames) {
//        placeDescription = [placeDescription stringByAppendingFormat:@" %@,", place];
//    }
//
//    if (info != nil) {
//        if (info.city.length > 0) {
//            placeDescription = [placeDescription stringByAppendingFormat:@" %@,", info.city];
//        }
//
//        if (info.state.length > 0) {
//            placeDescription = [placeDescription stringByAppendingFormat:@" %@,", info.state];
//        }
//
//        if (info.country.length > 0) {
//            placeDescription = [placeDescription stringByAppendingFormat:@" %@", info.country];
//        }
//    } else {
//        //TODO: check if we should add nouns to geocoding
//        // Try to be more specific in location using other nouns if it possible
//
//        // possible we should skip members of family even if they don't mention in relationships file
//        // for examle mother, father etc..
//        NSArray * relatives = [self relativeNouns];
//        for (NSString * noun in nouns) {
//            if ([relatives indexOfObject: noun.lowercaseString] != NSNotFound) {
//                continue;
//            }
//
//            placeDescription = [placeDescription stringByAppendingFormat:@" %@,", noun];
//        }
//    }
//
//    NSLog(@"Searching place with description: %@", placeDescription);
//
//    [QMGeocoder geocodeAddress: placeDescription
//                    completion: ^(QMLocationInfo * placeInfo, NSError * error) {
//                        if (info == nil) {
//                            NSLog(@"Deep Mind processing reveal place: %@", placeInfo);
//                            [wself handleGatheredDate: date
//                                             location: placeInfo
//                                              persons: persons];
//                            return;
//                        }
//
//                        QMLocationInfo * resultingInfo = info;
//                        if ([placeInfo isSpecificPlaceOfLocation: info]) {
//                            resultingInfo = placeInfo;
//                            NSLog(@"Deep Mind processing reveal specific place: %@", resultingInfo);
//                        }
//
//                        [wself handleGatheredDate: date
//                                         location: resultingInfo
//                                          persons: persons];
//                    }];
//}
//
//- (void) handmadeProcessSpeech: (NSString *) speech
//                  gatheredDate: (NSDate *) date
//                      location: (QMLocationInfo *) info {
//
//    NSInteger year = NSNotFound;
//    NSInteger day = NSNotFound;
//    NSInteger month = NSNotFound;
//
//    NSMutableArray * persons = [NSMutableArray array];
//    NSDictionary * relationships = self.peopleEntitled.relationships;
//
//    NSMutableCharacterSet * set = [NSMutableCharacterSet punctuationCharacterSet];
//    [set formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
//
//    NSArray * words = [speech componentsSeparatedByCharactersInSet: set];
//    NSMutableArray * skippedWords = [NSMutableArray array];
//
//    // find nouns, pronouns for persons by full iteration through words of a phrase
//    // find numbers to interpret dates
//
//    for (NSString * word in words) {
//        NSInteger number = word.integerValue;
//        BOOL isNumber = number != 0;
//        if (isNumber) {
//            if (date != nil) {
//                [skippedWords addObject: word];
//                continue;
//            }
//
//            BOOL revealed = NO;
//
//            if (year == NSNotFound) {
//                year = [self yearUsingNumberSequence: word];
//                if (year != NSNotFound) {
//                    revealed = YES;
//                }
//            }
//
//            if (day == NSNotFound) {
//                day = [self dayUsingNumberSequence: word];
//                if (day != NSNotFound) {
//                    revealed = YES;
//                }
//            }
//
//            if (revealed == NO) {
//                [skippedWords addObject: word];
//            }
//
//        } else {
//            BOOL revealed = NO;
//
//            NSArray * substitutionalPersons = relationships[word.uppercaseString];
//            if (substitutionalPersons.count > 0) {
//                [persons addObjectsFromArray: substitutionalPersons];
//                revealed = YES;
//            }
//
//            if (date == nil
//                && revealed == NO) {
//                NSInteger possibleMonth = [self.monthStrings indexOfObject: word.uppercaseString];
//                if (possibleMonth != NSNotFound) {
//                    month = possibleMonth + 1;
//                    revealed = YES;
//                }
//            }
//
//            if (revealed == NO) {
//                [skippedWords addObject: word];
//            }
//        }
//    }
//
//    if (date == nil) {
//        NSDate * foundOne = [self dateUsingGatheredDay: day
//                                                 month: month
//                                                  year: year];
//        if (foundOne != nil) {
//            date = foundOne;
//            NSLog(@"Handmade processing reveal date: %@", date);
//        }
//    }
//
//    if (info != nil) {
//        [self handleGatheredDate: date
//                        location: info
//                         persons: persons];
//        return;
//    }
//
//    // Try to geocode the rest
//
//    NSString * placeDescription = @"";
//    NSArray * relatives = [self relativeNouns];
//    NSArray * prepositions = [self prepositions];
//    NSArray * conjunctions = [self conjunctions];
//    NSArray * pronouns = [self pronouns];
//    NSArray * verbs = [self verbs];
//
//    for (NSString * word in skippedWords) {
//        NSInteger number = word.integerValue;
//        BOOL isNumber = number != 0;
//
//        if (isNumber) {
//            placeDescription = [placeDescription stringByAppendingFormat:@" %@", word];
//            continue;
//        }
//
//        NSString * sequence = word.lowercaseString;
//
//        if ([pronouns indexOfObject: sequence] != NSNotFound) {
//            continue;
//        }
//
//        if ([verbs indexOfObject: sequence] != NSNotFound) {
//            continue;
//        }
//
//        if ([conjunctions indexOfObject: sequence] != NSNotFound) {
//            continue;
//        }
//
//        if ([prepositions indexOfObject: sequence] != NSNotFound) {
//            continue;
//        }
//
//        if ([relatives indexOfObject: sequence] != NSNotFound) {
//            continue;
//        }
//
//        placeDescription = [placeDescription stringByAppendingFormat:@" %@", word];
//    }
//
//    if (placeDescription.length < 5) {
//        [self handleGatheredDate: date
//                        location: info
//                         persons: persons];
//        return;
//    }
//
//    NSLog(@"Searching place with description: %@", placeDescription);
//
//    [QMGeocoder geocodeAddress: placeDescription
//                    completion: ^(QMLocationInfo * possibleInfo, NSError * error) {
//                        [self handleGatheredDate: date
//                                        location: possibleInfo
//                                         persons: persons];
//                    }];
//}
//
//- (void) handleGatheredDate: (NSDate *) date
//                   location: (QMLocationInfo *) info
//                    persons: (NSArray<NSString *> *)persons {
//    if ([self.delegate respondsToSelector:@selector(recognizerFinishedWithDate:locationInfo:presons:)] == NO) {
//        return;
//    }
//
//    [self.delegate recognizerFinishedWithDate: date
//                                 locationInfo: info
//                                      presons: persons];
//}

// MARK: data logic

//- (NSDate *) dateUsingGatheredDay: (NSInteger) day
//                            month: (NSInteger) month
//                             year: (NSInteger) year {
//    BOOL valid = NO;
//    NSDateComponents * components = [NSDateComponents new];
//    if (year != NSNotFound) {
//        [components setYear: year];
//        valid = YES;
//    }
//    if (month != NSNotFound) {
//        [components setMonth: month];
//        valid = YES;
//    }
//    if (day != NSNotFound) {
//        [components setDay: day];
//    }
//
//    if (month != NSNotFound
//        && year == NSNotFound) {
//        [components setYear:[self currentYear]];
//    }
//
//    if (valid == NO) {
//        return nil;
//    }
//    NSDate * result = [self dateUsing: components];
//    return result;
//}
//
//// MARK: old processing
//
//- (void) detectAllFromText: (NSString*) aText {
//    //#warning
//    //    aText = @"september 7 1978 54-04 MYRTLE AVE New York";
//
//    // try ai parse.
//    NSArray * words = [aText componentsSeparatedByString:@" "];
//
//    NSInteger i = 3;
//
//    while (i <= words.count) {
//
//
//
//        NSDate * date = [self parseDateUsingLocalFormat: self.language datePhase:[[words subarrayWithRange:NSMakeRange(0, i)] componentsJoinedByString:@" "]];
//        NSLog(@"date: %@", date);
//
//
//
//        if (date) {
//            if (words.count >= i) {
//
//                NSString * address;
//                if (words.count == i) {
//                    address = nil;
//                }else{
//                    address = [[words subarrayWithRange:NSMakeRange(i, words.count-i)] componentsJoinedByString:@" "];
//                }
//                [self handleDetectedDate:date
//                              andAddress:address];
//
//                return;
//            }
//
//        }else{
//            i++;
//        }
//
//    }
//
//    [self notifyDelegateAboutErrorUsingText: LS(@"QM_onlineParse_DateAndPlace_Error")
//                                       code: 10002];
//}
//


//MARK: - logic -

@end
