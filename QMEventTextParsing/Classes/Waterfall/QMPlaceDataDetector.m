//
//  QMPlaceDataDetector.m
//  QromaScan
//
//  Created by bucha on 10/7/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMPlaceDataDetector.h"
#import "QMDetector+Private.h"
#import <QMGeocoder/QMGeocoder.h>


@interface QMPlaceDataDetector ()

@property (strong, nonatomic) NSDataDetector * placeDetector;
@property (strong, nonatomic) NSLocale * locale;
@property (assign, nonatomic, readwrite) QMGeocoderServiceProvider geocoderServiceProvider;
@property (strong, nonatomic, readwrite) QMLocationInfo * detectedLocation;

@end


@implementation QMPlaceDataDetector


    //MARK: - properties -

- (BOOL)failed {
    BOOL result = self.detectedLocation == nil;
    return result;
}

- (NSDataDetector *) placeDetector {
    if (_placeDetector != nil) {
        return _placeDetector;
    }
    NSError * error = nil;
    _placeDetector = [[NSDataDetector alloc] initWithTypes: NSTextCheckingTypeAddress 
                                                     error: &error];
    if (error != nil) {
        NSLog(@"Failed to initiate QMPlaceDataDetector: %@", error);
    }
    
    return _placeDetector;
}

- (NSString *)detectedValueDescription {
    NSString * result = [NSString stringWithFormat: @"place: %@", self.detectedLocation];
    return result;
}

    //MARK: - life cycle -

+ (instancetype) detectorUsingProvider: (QMGeocoderServiceProvider) geocoderServiceProvider {
    QMPlaceDataDetector * result = [[self class] new];
    result.geocoderServiceProvider = geocoderServiceProvider;
    
    return result;
}

    //MARK: - interface -

- (void) detectDataUsingString: (NSString *) string
                    completion: (CDBObjectErrorCompletion) completion {
    
    if (completion == nil) {
        return;
    }
    
    self.detectedLocation = nil;
    self.detected = [NSMutableArray array];
    self.possible = [NSMutableArray array];
    
    NSRange range = NSMakeRange(0, string.length);
    
    weakCDB(wself);

    // first match parsing
    [self.placeDetector enumerateMatchesInString: string
                                         options: 0
                                           range: range
                                      usingBlock: ^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                                          
        QMSemanticChunk * chunk = [QMSemanticChunk chunkUsingText: [string substringWithRange: result.range]
                                                     semanticType: QMSemanticTypeDetectedDate
                                                            range: result.range
                                                         position: NSNotFound];
        if (chunk == nil) {
            NSLog(@"<%@> get match in %@ but failed to create a chunk",
                       NSStringFromClass([self class]), NSStringFromRange(result.range));
            return;
        }
                                          
        *stop = YES;

        [wself.possible addObject: chunk];
    }];
    
    
    NSError * error = nil;
    
    if (wself.possible.count == 0) {
        error = [wself notFoundErrorUsingString: string];
        completion(string, error);
        return;
    }
    
    QMSemanticChunk * possibleChunk = self.possible.lastObject;
    NSString * locationDescription = possibleChunk.token.text;
    
    [[QMGeocoder shared] geocodeAddress: locationDescription
                                  using: self.geocoderServiceProvider
                             completion: ^(NSArray<QMLocationInfo *> * results, NSError * error) {
        
        NSString * passedBy = string;
        
        QMLocationInfo * info = results.firstObject;
                                 
        if (info != nil) {
            wself.detectedLocation = info;
            [wself.detected addObject: possibleChunk];
            
            passedBy = [self stringByReducing: string
                                  usingChunks: self.detected];
            
            passedBy = [self stringByTrimmingMultipleSpacesIn: passedBy];
            
        } else {
            error = [self notGeocodedErrorUsingString: locationDescription];
            
        }
        completion(passedBy, error);
    }];
}

    //MARK: - logic -

- (NSError *)notGeocodedErrorUsingString: (NSString *) string {
    NSString * desc = [NSString stringWithFormat: @"<%@> Place found '%@' but failed in geocoding it location",
                       NSStringFromClass([self class]), string];
    
    NSError * result = [NSError errorWithDomain: NSStringFromClass([self class])
                                           code: 1
                                       userInfo: @{NSLocalizedDescriptionKey : desc}];
    return result;
}

- (NSError *)notFoundErrorUsingString: (NSString *) string {
    NSString * desc = [NSString stringWithFormat: @"<%@> Place not found in '%@'",
                       NSStringFromClass([self class]), string];
    
    NSError * result = [NSError errorWithDomain: NSStringFromClass([self class])
                                           code: 0
                                       userInfo: @{NSLocalizedDescriptionKey : desc}];
    return result;
}


@end
