//
//  ViewController.m
//  QMEventTextParser-Mac-Example
//
//  Created by Kanstantsin Bucha on 2/11/18.
//  Copyright © 2018 truebucha. All rights reserved.
//

#import "ViewController.h"
#import <QMEventTextParsing/QMEventTextParsing.h>


@interface ViewController ()

@property (strong, nonatomic) id<QMEventParserInterface> parser;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
    
    self.parser = [QMEventParser parserUsingConfiguration: config
                                           peopleEntitled: entitled];
    
    NSLog(@"parser %@", self.parser);
    
//    NSString * text =  @"I and my brother in New York in March 17 1978";
//    NSString * text =  @"I and Mark in New York in March 17 1978";
    NSString * text =  @"Mike and Bill in New York in March 17 1978";
//    NSString * text =  @"I and my brother in New York in March 17 1978";
    
    [self.parser parseText: text
            withCompletion: ^(QMParserResult * _Nullable result, NSError * _Nullable error) {
        NSLog(@"result %@", result);
    }];
}

@end
