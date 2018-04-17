//
//  QMLogicPlaceDetector.h
//  QromaScan
//
//  Created by bucha on 10/8/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMDetector.h"
#import "QMPeopleEntitled.h"
#import "QMTextRecognitionConfig.h"


@class
QMLocationInfo;


@interface QMLogicPlaceDetector : QMDetector

@property (strong, nonatomic, readonly, nullable) NSArray<NSString *> * detectedPlaces;
@property (strong, nonatomic, readonly, nullable) NSArray<NSString *> * detectedOrganizations;
@property (strong, nonatomic, readonly, nullable) NSString * detectedPlaceGeocoderDescription;

@property (strong, nonatomic, readonly, nullable) QMLocationInfo * detectedLocation;

+ (instancetype _Nullable) detectorUsingConfiguration: (id<QMTextRecognitionConfigInterface> _Nonnull) config
                                       peopleEntitled: (id<QMPeopleEntitledInterface> _Nonnull) entitled;

@end
