//
//  QMDateDataDetector.h
//  QromaScan
//
//  Created by bucha on 10/7/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMDetector.h"

@interface QMDateDataDetector : QMDetector

@property (strong, nonatomic, readonly) NSDate * detectedDate;

+ (instancetype) detectorUsingLocale: (NSLocale *) locale;

@end
