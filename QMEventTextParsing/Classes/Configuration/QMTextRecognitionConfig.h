//
//  QMASRProvider.h
//  QromaScan
//
//  Created by bucha on 9/29/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    QMGeocodingProviderTypeUndefined = 0,
    QMGeocodingProviderTypeApple,
    QMGeocodingProviderTypeGoogle
} QMGeocodingProviderType;


#define StringFromQMGeocodingProviderType(enum) (([@[\
@"QMGeocodingProviderTypeUndefined",\
@"QMGeocodingProviderTypeApple",\
@"QMGeocodingProviderTypeGoogle",\
] objectAtIndex:(enum)]))

typedef enum : NSInteger {
    QMParserProviderTypeUndefined = 0,
    QMParserProviderTypeWaterfall,
    QMParserProviderTypeLinguistic,
    
} QMParserProviderType;


#define StringFromQMParserProviderType(enum) (([@[\
@"QMParserProviderTypeUndefined",\
@"QMParserProviderTypeWaterfall",\
@"QMParserProviderTypeLinguistic",\
] objectAtIndex:(enum)]))


@protocol QMTextRecognitionConfigInterface

@property (copy, nonatomic, readonly) NSString * language;
@property (copy, nonatomic, readonly) NSString * languageTitle;
@property (assign, nonatomic, readonly) QMParserProviderType eventParserServiceProvider;
@property (assign, nonatomic, readonly) QMGeocodingProviderType geocoderServiceProvider;

@property (strong, nonatomic, readonly) NSArray<NSNumber *> * waterfallParserOrderList;

@property (strong, nonatomic, readonly) NSLocale * locale;
@property (strong, nonatomic, readonly) NSCalendar * calendar;
@property (strong, nonatomic, readonly) NSDictionary<NSString *, NSNumber *> * seasons;
@property (strong, nonatomic, readonly) NSDictionary<NSString *, NSNumber *> * months;

@property (strong, nonatomic, readonly) NSArray<NSString *> * punctuationMarks;
@property (strong, nonatomic, readonly) NSArray<NSString *> * unifyingPrepositions;
@property (strong, nonatomic, readonly) NSArray<NSString *> * locationPrepositions;
@property (strong, nonatomic, readonly) NSArray<NSString *> * definiteArticles;

@end


@interface QMTextRecognitionConfig : NSObject
< QMTextRecognitionConfigInterface >

+ (instancetype) localConfigurationUsingLanguage: (NSString *) language;

- (void) updateGeocoderServiceProvider: (QMGeocodingProviderType) geocoderServiceProvider;
- (void) updateEventParserServiceProvider: (QMParserProviderType) eventParserServiceProvider;

+ (NSString *) languageKeyUsingLanguage: (NSString *) language;

@end
