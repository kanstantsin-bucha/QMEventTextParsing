//
//  QMPeopleDataDetector.h
//  QromaScan
//
//  Created by bucha on 10/8/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMDetector.h"
#import "QMPeopleEntitled.h"
#import "QMTextRecognitionConfig.h"


@interface QMPeopleDataDetector : QMDetector

@property (strong, nonatomic, readonly) NSArray<NSString *> * detectedPeople;

+ (instancetype) detectorUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config
                             peopleEntitled: (id<QMPeopleEntitledInterface>) entitled;

@end
