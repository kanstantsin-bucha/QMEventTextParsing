//
//  QMASRProvider+Private.h
//  QromaScan
//
//  Created by bucha on 9/29/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMTextRecognitionConfig.h"


typedef  NSDictionary<NSString *, NSObject *> QMConfigDict;

#define QMParse_QMASRProvider_ClassName @"ASRProvider"

#define QMTextRecognitionConfig_LanguageKey @"language"
//#define QMTextRecognitionConfig_LanguageTitleKey @"languageTitle"

#define QMTextRecognitionConfig_ASRKey @"ASR"
#define QMTextRecognitionConfig_EventParserServiceProviderKey @"eventParserServiceProvider"
#define QMTextRecognitionConfig_GeocoderServiceProviderKey @"geocoderServiceProvider"
#define QMTextRecognitionConfig_WaterfallParserOrderListKey @"waterfallParserOrderList"

#define QMTextRecognitionConfig_LanguageSpecificConfigKey @"languageSpecific"

#define QMTextRecognitionConfig_DefaultLanguageConfigKey @"default"

#define QMTextRecognitionConfig_SeasonsKey @"seasons"
#define QMTextRecognitionConfig_PunctuationMarksKey @"punctuationMarks"
#define QMTextRecognitionConfig_UnifyingPrepositionsKey @"unifyingPrepositions"
#define QMTextRecognitionConfig_LocationPrepositionsKey @"locationPrepositions"
#define QMTextRecognitionConfig_DefiniteArticlesKey @"definiteArticles"


@interface QMTextRecognitionConfig ()

@property (copy, nonatomic, readwrite) NSString * language;
@property (copy, nonatomic, readwrite) NSString * languageTitle;
@property (assign, nonatomic, readwrite) QMParserProviderType eventParserServiceProvider;
@property (assign, nonatomic, readwrite) QMGeocodingProviderType geocoderServiceProvider;
@property (strong, nonatomic, readwrite) NSArray<NSNumber *> * waterfallParserOrderList;

@property (strong, nonatomic, readwrite) NSLocale * locale;
@property (strong, nonatomic, readwrite) NSCalendar * calendar;
@property (strong, nonatomic, readwrite) NSDictionary<NSString *, NSNumber *> * seasons;
@property (strong, nonatomic, readwrite) NSDictionary<NSString *, NSNumber *> * months;

@property (strong, nonatomic, readwrite) NSArray<NSString *> * punctuationMarks;
@property (strong, nonatomic, readwrite) NSArray<NSString *> * unifyingPrepositions;
@property (strong, nonatomic, readwrite) NSArray<NSString *> * locationPrepositions;
@property (strong, nonatomic, readwrite) NSArray<NSString *> * definiteArticles;

@end
