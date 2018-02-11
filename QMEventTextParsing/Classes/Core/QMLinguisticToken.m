//
//  QMLinguisticToken.m
//  QromaCore
//
//  Created by bucha on 10/21/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMLinguisticToken.h"


@interface QMLinguisticToken ()

@property (copy, nonatomic, readwrite) NSString * text;
@property (copy, nonatomic, readwrite) NSString * lowercase;

@end


@implementation QMLinguisticToken

    //MARK: - life cycle -

+ (instancetype) tokenUsingText: (NSString *)text {
    if (text.length == 0) {
        return nil;
    }
    
    QMLinguisticToken * result = [[self class] new];
    result.text = text;
    result.lowercase = text.lowercaseString;
    
    return result;
}

    //MARK: - interface -

- (BOOL)hasFirstLetterUppercase {
    NSCharacterSet * upper = [NSCharacterSet uppercaseLetterCharacterSet];
    NSRange upperRange = [self.text rangeOfCharacterFromSet: upper];
    
    if (upperRange.location != 0) {
        return YES;
    }
    
    NSCharacterSet * capital = [NSCharacterSet capitalizedLetterCharacterSet];
    NSRange capitalRange = [self.text rangeOfCharacterFromSet: capital];
    
    if (capitalRange.location != 0) {
        return YES;
    }
    
    return NO;
}

@end
