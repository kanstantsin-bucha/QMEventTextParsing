//
//  QMDateParser.m
//  QromaScan
//
//  Created by bucha on 10/10/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMDateParser.h"


@interface QMDateParser ()

@end;


@implementation QMDateParser

    //MARK: -life cycle-

    //MARK: -interface-

- (NSInteger) yearUsingNumberSequence: (NSString *) sequence {
    if (sequence.length != 4) {
        return NSNotFound;
    }
    
    NSInteger possibleYear = sequence.integerValue;
    if (possibleYear >= 1600
        && possibleYear <= 2018) {
        return possibleYear;
    }
    
    return NSNotFound;
}

- (NSInteger) dayUsingNumberSequence: (NSString *) sequence {
    if (sequence.length != 2) {
        return NSNotFound;
    }
    
    NSInteger possibleDay = sequence.integerValue;
    if (possibleDay > 0
        && possibleDay <= 31) {
        return possibleDay;
    }
    
    return NSNotFound;
}

- (NSDate *) dateFromDay: (NSInteger) day
                   month: (NSInteger) month
                    year: (NSInteger) year
                   using: (NSCalendar *)calendar {
    BOOL valid = NO;
    NSDateComponents * components = [NSDateComponents new];
    if (year != NSNotFound) {
        [components setYear: year];
        valid = YES;
    }
    if (month != NSNotFound) {
        [components setMonth: month];
        valid = YES;
    }
    if (day != NSNotFound) {
        [components setDay: day];
    }
    
    if (month != NSNotFound
        && year == NSNotFound) {
        [components setYear:[self currentYearUsingCalendar: calendar]];
    }
    
    BOOL validDate = [components isValidDateInCalendar: calendar];
    if (valid == NO
        || validDate == NO) {
        return nil;
    }
    
    NSDate * result = [calendar dateFromComponents: components];
    return result;
}

- (NSDate *)parseDatePhase: (NSString *)datePhase
               usingLocale: (NSLocale *) locale {
    
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.locale = locale;
    
    NSString * dateComponents = @"yMMMMd";  //@"yMMMMd";
    
    NSString * dateFormatString = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:locale];
    
    // During to restrictions in MacOS
    // locale.languageCode is available only from 10.12
    // we use [locale objectForKey: NSLocaleLanguageCode] instead
    
    NSLog(@"local %@ date format is %@", [locale objectForKey: NSLocaleLanguageCode], dateFormatString);
    [dateFormat setDateFormat:dateFormatString]; //@"dd MMMM yyyy"
    
    NSDate * result = [dateFormat dateFromString:datePhase];
    return result;
}

    //MARK: -logic-



- (NSInteger) currentYearUsingCalendar: (NSCalendar *) calendar {
    NSInteger result = [calendar component:NSCalendarUnitYear fromDate:NSDate.date];
    return result;
}

@end
