//
//  QMEventExample.m
//  QMEventTextParsing
//
//  Created by Kanstantsin Bucha on 4/22/18.
//  Copyright © 2018 truebucha. All rights reserved.
//

#import "QMEventExample.h"
#import <QMEventTextParsing/QMEventTextParsing.h>
#import <QMEventTextParsing/QMLogicDateDetector.h>


@implementation QMEventExample

static id<QMEventParserInterface> _parser = nil;

+ (void) show {
    
    
    QMTextRecognitionConfig * config = [QMTextRecognitionConfig localConfigurationUsingLanguage: @"en_us"];
    NSLog(@"config %@", config);
    
    NSArray<QMRelationship *> * relationshipsList = [QMPeopleEntitled buildRelationshipsListUsing: @[
                                                                                                     @"I,me=Debra Olles",
                                                                                                     @"mother=Mama",
                                                                                                     @"father=Papa",
                                                                                                     @"brother=Tom Cruse",
                                                                                                     @"brother=Samuel Jackson"
                                                                                                     ]];
    
    QMRelationships * relationships = [QMPeopleEntitled composeRelationshipsFrom: relationshipsList];
    
    QMPeopleEntitled * entitled = [QMPeopleEntitled entitledUsingPeople: @[@"Mike", @"Bill", @"Artur"]
                                                          relationships: relationships];
    
    _parser = [QMEventParser parserUsingConfiguration: config
                                           peopleEntitled: entitled];
    
    NSLog(@"parser %@", _parser);
    
    //    NSString * text =  @"I and my brother in New York in March 17 1978";
    //    NSString * text =  @"I and Mark in New York in March 17 1978";
    NSString * text =  @"Mike and Bill in New York in March 17 1978";
    //    NSString * text =  @"I and my brother in New York in March 17 1978";
    
//    [_parser parseText: text
//            withCompletion: ^(QMParserResult * _Nullable result, NSError * _Nullable error) {
//                
//        NSLog(@"result %@", result);
//    }];
    
    QMLogicDateDetector * dateDetector = [QMLogicDateDetector detectorUsingConfiguration: config
                                                                          peopleEntitled: entitled];
    
    NSString * date =  @"March 17th 1978";
    
    [dateDetector detectDataUsingString: date
                             completion:^(id  _Nullable object, NSError * _Nullable error) {}];
    
    NSLog(@"date: %@", dateDetector.detectedDate);
}

@end
