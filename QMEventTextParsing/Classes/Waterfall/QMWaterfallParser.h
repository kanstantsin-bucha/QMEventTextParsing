//
//  QMWaterfallParser.h
//  QromaScan
//
//  Created by bucha on 10/5/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMEventParser.h"


typedef enum : NSInteger {
    QMWaterfallDetectorTypeUndefined = 0,
    QMWaterfallDetectorTypeDateData = 1,
    QMWaterfallDetectorTypePlaceData = 2,
    QMWaterfallDetectorTypePeopleData = 3,
    QMWaterfallDetectorTypeLogicDate = 4,
    QMWaterfallDetectorTypeLogicPlace = 5
} QMWaterfallDetectorType;


@interface QMWaterfallParser : NSObject
<
QMEventParserInterface
>

@end
