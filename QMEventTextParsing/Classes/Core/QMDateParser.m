//
//  QMDateParser.m
//  QromaScan
//
//  Created by bucha on 10/10/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMDateParser.h"


@interface QMDateParser ()

@property (strong, nonatomic) NSNumberFormatter * numberFormatter;
@property (strong, nonatomic) NSLocale * locale;

@end;


@implementation QMDateParser

    //MARK: -life cycle-

+ (instancetype) parserUsing: (NSLocale *) locale {
    
    if (locale == nil) {
        
        return nil;
    }
    
    QMDateParser * result = [[self alloc] init];
    result.locale = locale;
    
    return result;
}
    //MARK: -property-

- (NSNumberFormatter *) numberFormatter {
    
    if (_numberFormatter != nil) {
        
        return _numberFormatter;
    }
    
    _numberFormatter = [NSNumberFormatter new];
    
    NSOperatingSystemVersion version = {10,11,0};
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: version]) {
        
        _numberFormatter.numberStyle = NSNumberFormatterOrdinalStyle;
    }
    
    _numberFormatter.locale = self.locale;
    return _numberFormatter;
}

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
    
    NSInteger result = NSNotFound;
    
    if (sequence.length <= 2) {
        
        result = sequence.integerValue;
    }
    
    if (result == NSNotFound) {
        
        NSNumber * complexNumber = [self.numberFormatter numberFromString: sequence];
        
        result = complexNumber != nil ? complexNumber.integerValue
                                      : NSNotFound;
    }
    
    if (result == NSNotFound
        || result < 1
        || result > 31) {
        
        return NSNotFound;
    }
    
    return result;
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
