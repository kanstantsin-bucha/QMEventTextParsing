//
//  QMViewController.m
//  QMEventTextParsing
//
//  Created by truebucha on 02/11/2018.
//  Copyright (c) 2018 truebucha. All rights reserved.
//

#import "QMViewController.h"
#import "QMEventExample.h"

@interface QMViewController ()

@end

@implementation QMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
    [QMEventExample show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
