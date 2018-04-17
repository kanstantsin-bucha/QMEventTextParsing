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

@property (copy, nonatomic, readonly, nullable) NSString * speech;

/*!
 @brief preprocessed result
*/

@property (copy, nonatomic, readonly, nullable) NSString * preprocessedSpeech;
@property (strong, nonatomic, readonly, nullable) NSDate * preprocessedDate;
@property (copy, nonatomic, readonly, nullable) NSString * preprocessedDateString;
@property (strong, nonatomic, readonly, nullable) QMLocationInfo * preprocessedLocation;
@property (copy, nonatomic, readonly, nullable) NSString * preprocessedLocationString;

/*!
 @brief deep mind result
*/

@property (assign, nonatomic, readonly) NSInteger predefinedLocation;
@property (copy, nonatomic, readonly, nullable) NSString * predefinedLocationString;
@property (copy, nonatomic, readonly, nullable) NSString * geocodedLocation;

@property (strong, nonatomic, readonly, nullable) NSDate * deepMindDate;
@property (strong, nonatomic, readonly, nullable) QMLocationInfo * deepMindLocation;
@property (strong, nonatomic, readonly, nullable) NSArray<NSString *> * deepMindPersons;

/*!
 @brief final result
*/

@property (strong, nonatomic, readonly, nullable) NSDate * date;
@property (strong, nonatomic, readonly, nullable) QMLocationInfo * location;
@property (strong, nonatomic, readonly, nullable) NSArray<NSString *> * persons;

@end
