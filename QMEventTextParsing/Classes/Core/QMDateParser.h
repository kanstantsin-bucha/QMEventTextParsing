//
//  QMDateParser.h
//  QromaScan
//
//  Created by bucha on 10/10/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMDateParser : NSObject

+ (instancetype _Nullable) parserUsing: (NSLocale * _Nonnull) locale;

+ (instancetype) new NS_UNAVAILABLE;

- (NSInteger) yearUsingNumberSequence: (NSString * _Nonnull) sequence;
- (NSInteger) dayUsingNumberSequence: (NSString * _Nonnull) sequence;

- (NSDate * _Nullable) dateFromDay: (NSInteger) day
                             month: (NSInteger) month
                              year: (NSInteger) year
                             using: (NSCalendar * _Nonnull) calendar;

- (NSDate * _Nullable) parseDatePhase: (NSString * _Nonnull) datePhase
                          usingLocale: (NSLocale * _Nonnull) locale;

@end
