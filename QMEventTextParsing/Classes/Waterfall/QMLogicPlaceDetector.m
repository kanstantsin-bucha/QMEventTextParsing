//
//  QMLogicPlaceDetector.m
//  QromaScan
//
//  Created by bucha on 10/8/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMLogicPlaceDetector.h"
#import "QMLinguisticTagger.h"
#import "QMDetector+Private.h"
#import <QMGeocoder/QMGeocoder.h>
#import <CDBKit/CDBKit.h>
#import "QMLocationInfo.h"


@interface QMLogicPlaceDetector ()

@property (strong, nonatomic) id<QMPeopleEntitledInterface> entitled;
@property (strong, nonatomic) id<QMTextRecognitionConfigInterface> config;

@property (strong, nonatomic) NSMutableArray<QMSemanticChunk *> * detectedPlacesBucket;
@property (strong, nonatomic) NSMutableArray<QMSemanticChunk *> * detectedOrganizationsBucket;

@property (strong, nonatomic, readwrite) QMLocationInfo * detectedLocation;

@property (assign, nonatomic, readwrite) QMGeocoderServiceProvider geocoderServiceProvider;
@property (strong, nonatomic) QMLinguisticTagger * tagger;

@end


@implementation QMLogicPlaceDetector

    //MARK: - property -

- (QMLinguisticTagger *) tagger {
    if (_tagger != nil) {
        return _tagger;
    }
    
    _tagger = [QMLinguisticTagger taggerUsingConfiguration: self.config];
    return _tagger;
}

- (NSArray<NSString *> *) detectedPlaces {
    NSArray * result = [self.detectedPlacesBucket map:^id(QMSemanticChunk * chunk) {
        NSString * result = chunk.token.text;
        return result;
    }];
    return result;
}

- (NSArray<NSString *> *) detectedOrganizations {
    NSArray * result = [self.detectedOrganizationsBucket map:^id(QMSemanticChunk * chunk) {
        NSString * result = chunk.token.text;
        return result;
    }];
    return result;
}

- (NSString *) detectedPlaceGeocoderDescription {
    
    NSString * result = @"";
    
    for (NSString * organization in self.detectedOrganizations) {
        result = [result stringByAppendingFormat: @" %@", organization];
    }
    
    for (NSString * place in self.detectedPlaces) {
        result = [result stringByAppendingFormat: @" %@", place];
    }
    
    result = [result stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    return result;
}

- (BOOL)failed {
    BOOL result = self.detectedLocation == nil;
    return result;
}

- (NSString *)detectedValueDescription {
    NSString * result = [NSString stringWithFormat: @"place: %@", self.detectedLocation];
    return result;
}

    //MARK: - life cycle -

+ (instancetype) detectorUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config
                             peopleEntitled: (id<QMPeopleEntitledInterface>) entitled {
    if (entitled == nil
        || config.language == nil) {
        return nil;
    }
    
    QMLogicPlaceDetector * result = [[self class] new];
    
    result.entitled = entitled;
    result.config = config;
    
    return result;
}

    //MARK: - logic -

- (void)detectDataUsingString: (NSString *)string
                   completion: (CDBObjectErrorCompletion)completion {
    if (completion == nil) {
        return;
    }
    
    self.detected = [NSMutableArray array];
    self.possible = [NSMutableArray array];
    self.detectedPlacesBucket = [NSMutableArray array];
    self.detectedOrganizationsBucket = [NSMutableArray array];
    
    weakCDB(wself);
    [self.tagger enumerateChunksInString: string
                              usingBlock: ^ (QMSemanticChunk *chunk, BOOL * stop) {
      
        switch (chunk.type) {
            case QMSemanticTypeOrganizationName: {
                [wself.possible addObject: chunk];
                [wself.detected addObject: chunk];
                [self.detectedOrganizationsBucket addObject: chunk];
            } break;
              
            case QMSemanticTypePlaceName: {
                [wself.possible addObject: chunk];
                [wself.detected addObject: chunk];
                [self.detectedPlacesBucket addObject: chunk];
            } break;
              
            default : {
            } break;
        }
    }];
    
    if (wself.detected.count == 0) {
        NSError * error = [wself notFoundErrorUsingString: string];
        completion(string, error);
        return;
    }
    
    NSString * locationDescription = self.detectedPlaceGeocoderDescription;
    
    [[QMGeocoder shared] geocodeAddress: locationDescription
                                  using: self.geocoderServiceProvider
                             completion: ^(QMLocationInfo * info, NSError * error) {
                        
    
        if (info == nil) {
            NSError * error = [self notGeocodedErrorUsingString: locationDescription];
            completion(string, error);
            return;
        }
            
        wself.detectedLocation = info;
             
        NSString * passedBy = [self stringByReducing: string
                                         usingChunks: self.detected];
                        
        passedBy = [self stringByTrimmingMultipleSpacesIn: passedBy];
                        
        completion(passedBy, nil);
    }];
}

    //MARK: - logic -

- (NSError *)notGeocodedErrorUsingString: (NSString *) string {
    NSString * desc = [NSString stringWithFormat: @"<%@> Place/Organization found '%@' but geocoding failed",
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
