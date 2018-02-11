//
//  QMLinguisticToken.h
//  QromaCore
//
//  Created by bucha on 10/21/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QMLinguisticToken : NSObject

@property (copy, nonatomic, readonly) NSString * text;
@property (copy, nonatomic, readonly) NSString * lowercase;

+ (instancetype) tokenUsingText: (NSString *) text;

- (BOOL) hasFirstLetterUppercase;

@end
