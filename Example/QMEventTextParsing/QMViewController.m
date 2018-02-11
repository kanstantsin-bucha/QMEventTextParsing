//
//  QMViewController.m
//  QMEventTextParsing
//
//  Created by truebucha on 02/11/2018.
//  Copyright (c) 2018 truebucha. All rights reserved.
//

#import "QMViewController.h"
#import <QMEventTextParsing/QMEventTextParsing.h>


@interface QMViewController ()

@property (strong, nonatomic) id<QMEventParserInterface> parser;

@end

@implementation QMViewController

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
    
    [self.parser parseText: @"I and my brother in New York in March 17 1978"
            withCompletion: ^(QMParserResult * _Nullable result, NSError * _Nullable error) {
        NSLog(@"result %@", result);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
