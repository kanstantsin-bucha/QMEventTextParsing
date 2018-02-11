//
//  QMLinguisticParser.m
//  QromaScan
//
//  Created by bucha on 8/27/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMLinguisticParser.h"
#import <QMGeocoder/QMGeocoder.h>
#import <CDBKit/CDBKit.h>
#import "QMTExtRecognitionConfig.h"
#import "QMLocationInfo.h"
#import "QMLinguisticUnit.h"
#import "QMParserResult+Private.h"
#import "QMLinguisticTagger.h"
#import "QMDateDataDetector.h"
#import "QMPlaceDataDetector.h"


@interface QMLinguisticParser ()

@property (strong, nonatomic, readwrite) id<QMTextRecognitionConfigInterface> config;
@property (strong, nonatomic, readwrite) id<QMPeopleEntitledInterface> peopleEntitled;

@property (strong, nonatomic) NSDataDetector * dataDetector;
@property (strong, nonatomic) QMLinguisticTagger * tagger;

@property (strong, nonatomic) QMParserResult * result;
@property (copy, nonatomic) CDBObjectErrorCompletion completion;

@property (strong, nonatomic) QMLinguisticUnit * unit;

@property (assign, nonatomic) QMGeocoderServiceProvider geocoderServiceProvider;

@property (strong, nonatomic) QMDateDataDetector * dateDetector;
@property (strong, nonatomic) QMPlaceDataDetector * placeDetector;

@end

@implementation QMLinguisticParser

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

- (NSDataDetector *)dataDetector {
    if (_dataDetector != nil) {
        return _dataDetector;
    }
    NSError * error = nil;
    _dataDetector = [[NSDataDetector alloc] initWithTypes: NSTextCheckingTypeDate
                                                           | NSTextCheckingTypeAddress
                                                    error: &error];
    if (error != nil) {
        NSLog(@"Failed to initiate online speech data detector: %@", error);
    }
    
    return _dataDetector;
}

- (QMLinguisticTagger *)tagger {
    if (_tagger != nil) {
        return _tagger;
    }
    
    _tagger = [QMLinguisticTagger taggerUsingConfiguration: self.config];
    return _tagger;
}

- (QMLinguisticUnit *)unit {
    if (_unit != nil) {
        return _unit;
    }
    
    _unit = [QMLinguisticUnit unitUsingConfiguration: self.config
                                      peopleEntitled: self.peopleEntitled];
    return _unit;
}

// MARK: - life cycle -

+ (instancetype) parserUsingConfiguration: (id<QMTextRecognitionConfigInterface>)config
                           peopleEntitled: (id<QMPeopleEntitledInterface>) entitled {
    if (config.language == nil) {
        return nil;
    }
    
    QMLinguisticParser * result = [QMLinguisticParser new];
    
    result.config = config;
    
    result.peopleEntitled = entitled;

    return result;
}

// MARK: - interface -

- (void) parseText: (NSString *) text
    withCompletion: (CDBObjectErrorCompletion) completion {
    
    if (self.completion != nil) {
        NSError * error = [NSError errorWithDomain: NSStringFromClass([self class])
                                              code: 1
                                          userInfo: @{NSLocalizedDescriptionKey : @"the parse is busy with another request"}];
        completion(nil, error);
    }
    
    self.completion = completion;
    self.result = [QMParserResult new];
    
    self.result.speech = text;
    
    [self preprocessSpeech: text];
}

//MARK: - logic -

- (void) preprocessSpeech: (NSString *) speech {
    
    self.dateDetector = [QMDateDataDetector detectorUsingLocale: self.config.locale];
    self.placeDetector = [QMPlaceDataDetector detectorUsingProvider: self.geocoderServiceProvider];
    
    weakCDB(wself);
    [self.dateDetector detectDataUsingString: speech
                                  completion:^(NSString *  _Nullable passedBy, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Date detector failed: %@", error.localizedDescription);
        } else {
            NSLog(@"Found Date %@, reducedString: %@", wself.dateDetector.detectedDate, passedBy);
        }
                                      
        [wself.placeDetector detectDataUsingString: passedBy
                                        completion:^(NSString *  _Nullable passedBy, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Place detector failed: %@", error.localizedDescription);
            } else {
                NSLog(@"Found Place %@, reducedString: %@", wself.placeDetector.detectedLocation, passedBy);
            }
                              
            wself.result.preprocessedDate = self.dateDetector.detectedDate;
            wself.result.preprocessedLocation = self.placeDetector.detectedLocation;
            wself.result.preprocessedSpeech = passedBy;
                                            
            [wself deep2MindProcessSpeech: wself.result.preprocessedSpeech
                             gatheredDate: wself.result.preprocessedDate
                                 location: wself.result.preprocessedLocation];
        }];
    }];
}

- (void) deep2MindProcessSpeech: (NSString *) speech
                   gatheredDate: (NSDate *) date
                       location: (QMLocationInfo *) info {
    
    [self.unit start];
    
    weakCDB(wself);
    [self.tagger enumerateChunksInString: speech
                              usingBlock:^(QMSemanticChunk * chunk, BOOL *stop) {
        [wself.unit appendChunk: chunk];
    }];
    
    [self.unit finish];

    QMParserResult * result = self.result;

    // date processing
    
    if (date == nil) {
        NSDate * foundOne = self.unit.dateMatches.firstObject.date;
        if (foundOne != nil) {
            date = foundOne;
            NSLog(@"Deep Mind reveal date: %@", date);
            result.deepMindDate = date;
        }
    }
    
    self.result.date = date;
    
    // persons processing
    
    NSMutableArray * persons = [NSMutableArray array];
    for (QMSemanticPersonMatcher * sequence in self.unit.personMatches) {
        NSArray * currentPersons = sequence.persons;
        if (currentPersons.count > 0) {
            [persons addObjectsFromArray: currentPersons];
        }
    }
    
    if (persons.count > 0) {
         NSLog(@"Deep Mind reveal persons: %@", persons);
         result.deepMindPersons = persons;
    }
    
    result.persons = persons;
    
    // location processing
    
    NSString * description = self.unit.locationDescription;
    
    if (info != nil
        && description.length == 0) {
        result.date = date;
        result.location = info;
        
        [self handleGatheredResult: result];
        return;
    }
    
    NSLog(@"Deep Mind will try this place description: %@", description);
    [[QMGeocoder shared] geocodeAddress: description
                                  using: self.geocoderServiceProvider
                             completion: ^(QMLocationInfo * placeInfo, NSError * error) {
        if (info == nil) {
            NSString * precisionDesciption = wself.unit.precisionLocationDescription;
            if (placeInfo != nil
                || precisionDesciption == nil) {
                NSLog(@"Deep Mind geocode: '%@' and reveal \r place: %@",
                      description, placeInfo);
                
                result.location = placeInfo;
                result.geocodedLocation = description;
                
                [wself handleGatheredResult: result];
            } else {
               // try to pass only precision location
                [[QMGeocoder shared] geocodeAddress: precisionDesciption
                                              using: wself.geocoderServiceProvider
                                         completion: ^(QMLocationInfo * precisionPlaceInfo, NSError * error) {
                    NSLog(@"Deep Mind geocode precision: '%@' and reveal \r place: %@",
                            precisionDesciption, precisionPlaceInfo);
                    
                    result.location = precisionPlaceInfo;
                    result.geocodedLocation = precisionDesciption;
                    
                    [wself handleGatheredResult: result];
                }];
            }
            return;
        }
        
        if ([placeInfo isSpecificPlaceOfLocation: info]) {
            // we got location that is specific place of preprocessed location
            NSLog(@"Deep Mind geocode: '%@' and reveal \r specific place: %@",
                    description, placeInfo);
            result.location = placeInfo;
            result.geocodedLocation = description;
            
            [wself handleGatheredResult: result];
            return;
        }
        
        // placeInfo location is not connected to the city or state of preprocessed location
        // we append city or state to description to search more specific place
        
        NSString * correctedDescription = description;
        
        BOOL shouldAppend = YES;
        if (info.city.length > 0) {
            correctedDescription = [correctedDescription stringByAppendingFormat:@" %@", info.city];
            shouldAppend = NO;
        }

        if (shouldAppend
            && info.state.length > 0) {
            correctedDescription = [correctedDescription stringByAppendingFormat:@" %@", info.state];
            shouldAppend = NO;
        }

        if (shouldAppend
            && info.country.length > 0) {
            correctedDescription = [correctedDescription stringByAppendingFormat:@" %@", info.country];
        }

        [[QMGeocoder shared] geocodeAddress: correctedDescription
                                      using: wself.geocoderServiceProvider
                                 completion: ^(QMLocationInfo * correctedPlaceInfo, NSError * error) {

            if ([correctedPlaceInfo isSpecificPlaceOfLocation: info]) {
                 // we finally got location that is specific place of preprocessed location
                NSLog(@"Deep Mind geocode: '%@' and reveal \r specific corrected place: %@",
                      correctedDescription, correctedPlaceInfo);
                result.location = correctedPlaceInfo;
                result.geocodedLocation = correctedDescription;
            } else {
                // geocoding of description has no result so we use preprocessed location
                NSLog(@"Deep Mind failed geocode: '%@' and \r used preprocessed place: %@",
                      correctedPlaceInfo, info);
                result.location = info;
                result.geocodedLocation = nil;
            }

            [wself handleGatheredResult: result];
        }];
    }];
}

- (void) handleGatheredResult: (QMParserResult *) result {
    if (self.completion == nil) {
        NSLog(@" %@ encountered nil completion for processed speech", NSStringFromClass([self class]));
        return;
    }

    CDBObjectErrorCompletion completion = self.completion;
    self.completion = nil;
    self.result = nil;
    
    completion(result, nil);
}

//MARK: data logic



@end
