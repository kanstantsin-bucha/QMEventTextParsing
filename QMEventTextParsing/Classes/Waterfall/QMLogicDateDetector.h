//
//  QMLogicDateDetector.h
//  QromaScan
//
//  Created by bucha on 10/8/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMDetector.h"
#import "QMPeopleEntitled.h"
#import "QMTextRecognitionConfig.h"


@interface QMLogicDateDetector : QMDetector

@property (strong, nonatomic, readonly) NSDate * detectedDate;

+ (instancetype) detectorUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config
                             peopleEntitled: (id<QMPeopleEntitledInterface>) entitled;

@end
