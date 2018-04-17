//
//  QMDateDataDetector.h
//  QromaScan
//
//  Created by bucha on 10/7/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMDetector.h"

@interface QMDateDataDetector : QMDetector

@property (strong, nonatomic, readonly, nullable) NSDate * detectedDate;

+ (instancetype _Nullable) detectorUsingLocale: (NSLocale * _Nonnull) locale;

@end
