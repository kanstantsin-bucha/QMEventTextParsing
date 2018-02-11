//
//  QMPlaceDataDetector.h
//  QromaScan
//
//  Created by bucha on 10/7/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMDetector.h"
#import <QMGeocoder/QMGeocoder.h>


@interface QMPlaceDataDetector : QMDetector

@property (assign, nonatomic, readonly) QMGeocoderServiceProvider geocoderServiceProvider;
@property (strong, nonatomic, readonly) QMLocationInfo * detectedLocation;

+ (instancetype) detectorUsingProvider: (QMGeocoderServiceProvider) geocoderServiceProvider;

@end
