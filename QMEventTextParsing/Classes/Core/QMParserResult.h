//
//  QMParserResult.h
//  QromaScan
//
//  Created by bucha on 8/27/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMLocationInfo;

@interface QMParserResult : NSObject

@property (copy, nonatomic, readonly) NSString * speech;

/*!
 @brief preprocessed result
*/

@property (copy, nonatomic, readonly) NSString * preprocessedSpeech;
@property (strong, nonatomic, readonly) NSDate * preprocessedDate;
@property (copy, nonatomic, readonly) NSString * preprocessedDateString;
@property (strong, nonatomic, readonly) QMLocationInfo * preprocessedLocation;
@property (copy, nonatomic, readonly) NSString * preprocessedLocationString;

/*!
 @brief deep mind result
*/

@property (assign, nonatomic, readonly) NSInteger predefinedLocation;
@property (copy, nonatomic, readonly) NSString * predefinedLocationString;
@property (copy, nonatomic, readonly) NSString * geocodedLocation;

@property (strong, nonatomic, readonly) NSDate * deepMindDate;
@property (strong, nonatomic, readonly) QMLocationInfo * deepMindLocation;
@property (strong, nonatomic, readonly) NSArray<NSString *> * deepMindPersons;

/*!
 @brief final result
*/

@property (strong, nonatomic, readonly) NSDate * date;
@property (strong, nonatomic, readonly) QMLocationInfo * location;
@property (strong, nonatomic, readonly) NSArray<NSString *> * persons;

@end
