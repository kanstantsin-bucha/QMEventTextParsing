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

@property (strong, nonatomic, readonly) NSArray<NSString *> * detectedPlaces;
@property (strong, nonatomic, readonly) NSArray<NSString *> * detectedOrganizations;
@property (strong, nonatomic, readonly) NSString * detectedPlaceGeocoderDescription;

@property (strong, nonatomic, readonly) QMLocationInfo * detectedLocation;

+ (instancetype) detectorUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config
                             peopleEntitled: (id<QMPeopleEntitledInterface>) entitled;

@end
