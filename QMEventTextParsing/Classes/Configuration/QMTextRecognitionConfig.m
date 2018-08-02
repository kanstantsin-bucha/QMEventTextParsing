//
//  QMASRProvider.m
//  QromaScan
//
//  Created by bucha on 9/29/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMTextRecognitionConfig+Private.h"
#import <TBParse/TBParseConversion.h>


@implementation QMTextRecognitionConfig

//MARK: - property -

- (NSDictionary<NSString *,NSNumber *> *)months {
    if (_months != nil) {
        return _months;
    }
    
    _months = [self monthSubstitutionsUsingLocale: self.locale];
    return _months;
}

//MARK: - life cycle -

+ (instancetype) localConfigurationUsingLanguage: (NSString *) language {
    
    NSString * langKey = [[self class] languageKeyUsingLanguage: language];
    
    QMTextRecognitionConfig * result = [self configurationtUsingDict: [self defaultDictionary]
                                                         andLanguage: langKey];
    result.languageTitle = @"default settings";
    
    return result;
}

+ (instancetype) configurationtUsingDict: (QMConfigDict *) configurationDictionary
                             andLanguage: (NSString *) language {
    
    if (configurationDictionary.allKeys.count == 0) {
        return nil;
    }
    
    QMTextRecognitionConfig * result = [QMTextRecognitionConfig new];
    
    result.language = language;
    result.calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    result.locale = [[NSLocale alloc] initWithLocaleIdentifier: language];
    

    // QMWaterfallDetectorType
    NSString * waterfallOrderList = [TBParseConversion objectOfClass: [NSString class]
                                                      fromDictionary: configurationDictionary
                                                            usingKey: QMTextRecognitionConfig_WaterfallParserOrderListKey];
    result.waterfallParserOrderList = [TBParseConversion numbersUsingStringsList: waterfallOrderList];
    
    NSNumber * geocoderServiceProvider = [TBParseConversion objectOfClass: [NSNumber class]
                                                           fromDictionary: configurationDictionary
                                                                 usingKey: QMTextRecognitionConfig_GeocoderServiceProviderKey];
    result.geocoderServiceProvider = geocoderServiceProvider.integerValue;
    
    NSNumber * speechParserServiceProvider = [TBParseConversion objectOfClass: [NSNumber class]
                                                               fromDictionary: configurationDictionary
                                                                     usingKey: QMTextRecognitionConfig_EventParserServiceProviderKey];
    result.eventParserServiceProvider = speechParserServiceProvider.integerValue;
    
    // QMLinguisticDetectorType
    
    QMConfigDict * languageSpecific = (QMConfigDict *)configurationDictionary[QMTextRecognitionConfig_LanguageSpecificConfigKey];
    
    QMConfigDict * languageCongig = (QMConfigDict *)languageSpecific[language];
    
    if (languageCongig == nil) {
        languageCongig = (QMConfigDict *)languageSpecific[QMTextRecognitionConfig_DefaultLanguageConfigKey];
    }
    
    NSString * seasons = [TBParseConversion objectOfClass: [NSString class]
                                           fromDictionary: languageCongig
                                                 usingKey: QMTextRecognitionConfig_SeasonsKey];
    result.seasons = [TBParseConversion pairsUsingStrings: seasons];
    
    NSString * punctuation = [TBParseConversion objectOfClass: [NSString class]
                                               fromDictionary: languageCongig
                                                     usingKey: QMTextRecognitionConfig_PunctuationMarksKey];
    
    result.punctuationMarks = [TBParseConversion wordsUsingStringsList: punctuation];
    
    NSString * unifyingPrepositions = [TBParseConversion objectOfClass: [NSString class]
                                                        fromDictionary: languageCongig
                                                              usingKey: QMTextRecognitionConfig_UnifyingPrepositionsKey];
    
    result.unifyingPrepositions = [TBParseConversion wordsUsingStringsList: unifyingPrepositions];
    
    NSString * locationPrepositions = [TBParseConversion objectOfClass: [NSString class]
                                                        fromDictionary: languageCongig
                                                              usingKey: QMTextRecognitionConfig_LocationPrepositionsKey];
    
    result.locationPrepositions = [TBParseConversion wordsUsingStringsList: locationPrepositions];
    
    NSString * definedArticles = [TBParseConversion objectOfClass: [NSString class]
                                                   fromDictionary: languageCongig
                                                         usingKey: QMTextRecognitionConfig_DefiniteArticlesKey];
    
    result.definiteArticles = [TBParseConversion wordsUsingStringsList: definedArticles];
    
    return result;
}

//MARK: - interface -

- (void) updateGeocoderServiceProvider: (QMGeocodingProviderType) geocoderServiceProvider {
    
    self.geocoderServiceProvider = geocoderServiceProvider;
}
- (void) updateEventParserServiceProvider: (QMParserProviderType) eventParserServiceProvider {
    
    self.eventParserServiceProvider = eventParserServiceProvider;
}


+ (NSString *) languageKeyUsingLanguage: (NSString *) language {
    if (language.length < 2) {
        return nil;
    }
    
    NSRange range = [language rangeOfString: @"_"
                                    options: NSCaseInsensitiveSearch
                                           | NSDiacriticInsensitiveSearch
                                           | NSWidthInsensitiveSearch];
    NSInteger index = range.location;
    if (index == NSNotFound) {
        index = language.length - 1;
    }
    
    NSString * result = [language substringToIndex: index];
    return result;
}


//MARK: - logic -

- (NSDictionary<NSString *, NSNumber *> *) monthSubstitutionsUsingLocale: (NSLocale *) locale {
    
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = locale;
    
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    [dateFormatter.monthSymbols enumerateObjectsUsingBlock:^(NSString * _Nonnull monthString, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber * month = @(idx + 1);
        result[monthString.lowercaseString] = month;
    }];
    
    return [result copy];
}

+ (QMConfigDict *) defaultDictionary {
    return @{
             QMTextRecognitionConfig_EventParserServiceProviderKey: @(1),
             QMTextRecognitionConfig_GeocoderServiceProviderKey: @(1),
             QMTextRecognitionConfig_WaterfallParserOrderListKey: @"1;2;3;4;5",
             QMTextRecognitionConfig_LanguageSpecificConfigKey: @{
                 QMTextRecognitionConfig_DefaultLanguageConfigKey : @{
                         QMTextRecognitionConfig_LanguageKey: QMTextRecognitionConfig_DefaultLanguageConfigKey,
                         QMTextRecognitionConfig_SeasonsKey: @"summer:7;outumn:10;fall:10;winter:1;spring:4",
                         QMTextRecognitionConfig_PunctuationMarksKey: @",;.",
                         QMTextRecognitionConfig_UnifyingPrepositionsKey: @"of",
                         QMTextRecognitionConfig_LocationPrepositionsKey: @"in;at;to",
                         QMTextRecognitionConfig_DefiniteArticlesKey: @"the" },
                 
                 @"en": @{
                         QMTextRecognitionConfig_LanguageKey: @"en",
                         QMTextRecognitionConfig_SeasonsKey: @"summer:7;outumn:10;fall:10;winter:1;spring:4",
                         QMTextRecognitionConfig_PunctuationMarksKey: @",;.",
                         QMTextRecognitionConfig_UnifyingPrepositionsKey: @"of",
                         QMTextRecognitionConfig_LocationPrepositionsKey: @"in;at;to",
                         QMTextRecognitionConfig_DefiniteArticlesKey: @"the"
                         },
                 
                 @"es": @{
                         QMTextRecognitionConfig_LanguageKey: @"es",
                         QMTextRecognitionConfig_SeasonsKey: @"verano:7;columna:10;otoño:10;invierno:1;primavera:4",
                         QMTextRecognitionConfig_PunctuationMarksKey: @",;.",
                         QMTextRecognitionConfig_UnifyingPrepositionsKey: @"de",
                         QMTextRecognitionConfig_LocationPrepositionsKey: @"en;a",
                         QMTextRecognitionConfig_DefiniteArticlesKey: @"el;la;las;los",
                         },
                 
                 @"ru": @{
                         QMTextRecognitionConfig_LanguageKey: @"ru",
                         QMTextRecognitionConfig_SeasonsKey: @"летом:7;осенью:10;зимой:1;весной:4",
                         QMTextRecognitionConfig_PunctuationMarksKey: @",;.",
                         QMTextRecognitionConfig_UnifyingPrepositionsKey: @"",
                         QMTextRecognitionConfig_LocationPrepositionsKey: @"в;на",
                         QMTextRecognitionConfig_DefiniteArticlesKey: @"",
                         },
                 }
        };
}

- (NSString *)description {
    NSString * result = [NSString stringWithFormat:@"%@\
                         \r language= %@ \
                         \r languageTitle= %@ \
                         \r geocoderServiceProvider= %@ \
                         \r speechParserServiceProvider= %@ \
                         \r waterfallParserOrderList= %@ \
                         \r seasons= %@ \
                         \r unifyingPrepositions= %@ \
                         \r locationPrepositions= %@ \
                         \r definiteArticle= %@ \
                         \r punctuation= %@ \
                         ",
                         NSStringFromClass([self class]),
                         self.language,
                         self.languageTitle,
                         @(self.geocoderServiceProvider),
                         @(self.eventParserServiceProvider),
                         self.waterfallParserOrderList,
                         self.seasons,
                         self.unifyingPrepositions,
                         self.locationPrepositions,
                         self.definiteArticles,
                         self.punctuationMarks
                         ];
    return result;
}

@end
