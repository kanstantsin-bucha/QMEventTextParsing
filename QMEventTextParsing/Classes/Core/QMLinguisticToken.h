//
//  QMLinguisticToken.h
//  QromaCore
//
//  Created by bucha on 10/21/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QMLinguisticToken : NSObject

@property (copy, nonatomic, readonly, nullable) NSString * text;
@property (copy, nonatomic, readonly, nullable) NSString * lowercase;

+ (instancetype _Nullable) tokenUsingText: (NSString * _Nonnull) text;

- (BOOL) hasFirstLetterUppercase;

@end
