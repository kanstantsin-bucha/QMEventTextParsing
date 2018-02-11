//
//  QMParserResult+Private.h
//  QromaScan
//
//  Created by bucha on 9/5/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMParserResult.h"


@interface QMParserResult ()

@property (copy, nonatomic, readwrite) NSString * speech;

@property (copy, nonatomic, readwrite) NSString * preprocessedSpeech;
@property (strong, nonatomic, readwrite) NSDate * preprocessedDate;
@property (copy, nonatomic, readwrite) NSString * preprocessedDateString;
@property (strong, nonatomic, readwrite) QMLocationInfo * preprocessedLocation;
@property (copy, nonatomic, readwrite) NSString * preprocessedLocationString;

@property (assign, nonatomic, readwrite) NSInteger predefinedLocation;
@property (copy, nonatomic, readwrite) NSString * predefinedLocationString;
@property (copy, nonatomic, readwrite) NSString * geocodedLocation;
@property (strong, nonatomic, readwrite) NSDate * deepMindDate;
@property (strong, nonatomic, readwrite) QMLocationInfo * deepMindLocation;
@property (strong, nonatomic, readwrite) NSArray<NSString *> * deepMindPersons;

@property (strong, nonatomic, readwrite) NSDate * date;
@property (strong, nonatomic, readwrite) QMLocationInfo * location;
@property (strong, nonatomic, readwrite) NSArray<NSString *> * persons;

@end

