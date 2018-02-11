//
//  QMDateParser.h
//  QromaScan
//
//  Created by bucha on 10/10/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMDateParser : NSObject

- (NSInteger) yearUsingNumberSequence: (NSString *) sequence;
- (NSInteger) dayUsingNumberSequence: (NSString *) sequence;

- (NSDate *) dateFromDay: (NSInteger) day
                   month: (NSInteger) month
                    year: (NSInteger) year
                   using: (NSCalendar *) calendar;

- (NSDate *) parseDatePhase: (NSString *) datePhase
                usingLocale: (NSLocale *) locale;

@end
