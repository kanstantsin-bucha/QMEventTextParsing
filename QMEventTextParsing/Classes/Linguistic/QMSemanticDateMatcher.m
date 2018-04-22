//
//  QMSemanticDateMatcher.m
//  QromaScan
//
//  Created by bucha on 9/1/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMSemanticDateMatcher.h"
#import "QMSemanticMatcher+Private.h"
#import "QMDateParser.h"


@interface QMSemanticDateMatcher ()

@property (strong, nonatomic, readwrite) NSDictionary<NSString *, NSNumber *> * noun2MonthSubstitution;

@property (assign, nonatomic, readwrite) NSInteger day;
@property (assign, nonatomic, readwrite) NSInteger month;
@property (assign, nonatomic, readwrite) NSInteger year;

@property (strong, nonatomic) NSString * partialNumber;

@property (assign, nonatomic) BOOL hasForbiddenType;
@property (assign, nonatomic) BOOL hasDefinedArticle;
@property (assign, nonatomic) BOOL hasNoun;
@property (assign, nonatomic) BOOL hasMatch;

@property (strong, nonatomic) QMDateParser * dateParser;
@property (strong, nonatomic) NSCalendar * calendar;

@end


@implementation QMSemanticDateMatcher

//MARK: - property -

- (BOOL)hasResults {
    BOOL result = self.day != NSNotFound
                  || self.month != NSNotFound
                  || self.year != NSNotFound
                  || self.partialNumber != nil;
//                  || self.hasDefinedArticle;
    return result;
}

- (BOOL)hasDominant {
    BOOL result = self.month != NSNotFound;
    return result;
}

- (BOOL)hasComplete {
    BOOL result = self.month != NSNotFound
                  && self.year != NSNotFound
                  && self.day != NSNotFound;
    return result;
}

- (BOOL)shouldProcess {
    BOOL result = self.partialNumber != nil
                  || self.hasDefinedArticle;
    return result;
}

- (BOOL)shouldFail {
    if (self.hasDominant) {
        return NO;
    }
    
    BOOL result = self.hasForbiddenType
                  || (self.hasResults || self.shouldProcess) == NO
                  || (self.hasNoun && self.hasMatch == NO);
    return result;
}

- (NSDate *)date {
    NSDate * result = [self.dateParser dateFromDay: self.day
                                             month: self.month
                                              year: self.year
                                             using: self.calendar];
    return result;
}

//MARK: - life cycle -

+ (instancetype) matcherUsing: (NSDictionary<NSString *, NSNumber *> *) noun2MonthSubstitution
                     calendar: (NSCalendar *) calendar
                       locale: (NSLocale *) locale {
    
    if (calendar == nil) {
        
        return nil;
    }
    
    QMSemanticDateMatcher * result = [[self class] new];
    
    result.noun2MonthSubstitution = noun2MonthSubstitution;
    
    result.year = NSNotFound;
    result.month = NSNotFound;
    result.day = NSNotFound;
    
    result.calendar = calendar;
    result.dateParser = [QMDateParser parserUsing: locale];
    
    return result;
}

//MARK: - logic -

- (BOOL) shouldUpdateMatchFor: (QMSemanticChunk *) chunk {
    BOOL result = chunk.type != QMSemanticTypePreposition;
    return result;
}

- (BOOL) processChunk: (QMSemanticChunk *) chunk {

    if (chunk.type != QMSemanticTypeNumber
        && self.partialNumber) {
        [self processNumberString: self.partialNumber
                     couldCompose: NO];
        self.partialNumber = nil;
    }
    
    switch (chunk.type) {
        case QMSemanticTypeNoun: {
            self.hasNoun = YES;
            [self processNounToken: chunk.token];
        } break;
        
        case QMSemanticTypeNumber: {
            [self processNumberString: chunk.token.lowercase
                         couldCompose: YES];
        } break;
        
        case QMSemanticTypePreposition: {
        } break;
        
        case QMSemanticTypeDefinedArticle: {
            self.hasDefinedArticle = YES;
        } break;

        default: {
            self.hasForbiddenType = YES;
        }
        break;
    }
    
    return YES;
}

- (void) processFinish {
    if (self.partialNumber != nil) {
        [self processNumberString: self.partialNumber
                     couldCompose: NO];
        self.partialNumber = nil;
    }
}

- (void) processNounToken: (QMLinguisticToken *) token {
    NSNumber * possibleMonth = self.noun2MonthSubstitution[token.lowercase];
    if (possibleMonth != nil) {
        self.month = possibleMonth.integerValue;
        self.hasMatch = YES;
        NSLog(@"date sequence got month %@", @(self.month));
    }
}

- (void) processNumberString: (NSString *) numberString
                couldCompose: (BOOL) couldCompose {
    
    if (couldCompose
        && self.partialNumber != nil) {
        NSString * composedString = [self.partialNumber stringByAppendingString: numberString];
        NSLog(@"date sequence got composed %@", composedString);
        self.partialNumber = nil;
        
        [self processNumberString: composedString
                     couldCompose: NO];
    }
    
    switch (numberString.length) {
        case 1:
        case 2: {
            if (self.partialNumber == nil) {
                self.partialNumber = numberString;
                NSLog(@"date sequence got partial %@", numberString);
                return;
            }
            
            NSInteger day = [self.dateParser dayUsingNumberSequence: numberString];
            if (day != NSNotFound) {
                self.day = day;
                NSLog(@"date sequence got day %@", @(self.day));
            }
        } break;
        
        case 3: {
        
            NSInteger day = [self.dateParser dayUsingNumberSequence: numberString];
            if (self.day == NSNotFound
                && day != NSNotFound) {
                self.day = day;
                NSLog(@"date sequence got day %@", @(self.day));
            }
        } break;
            
        case 4: {
            
            NSInteger day = [self.dateParser dayUsingNumberSequence: numberString];
            if (self.day == NSNotFound
                && day != NSNotFound) {
                self.day = day;
                NSLog(@"date sequence got day %@", @(self.day));
                
                break;
            }
            
            NSInteger year = [self.dateParser yearUsingNumberSequence: numberString];
            if (year != NSNotFound) {
                self.year = year;
                NSLog(@"date sequence got year %@", @(self.year));
            }
        } break;

        case 6: {
            if (self.day != NSNotFound) {
                
                break;
            }
            
            NSString * dayString = [numberString substringToIndex: 2];
            NSString * yearString = [numberString substringFromIndex: 2];
            
            NSInteger day = [self.dateParser dayUsingNumberSequence: dayString];
            if (day != NSNotFound) {
                self.day = day;
                NSLog(@"date sequence got day %@", @(self.day));
            }
    
            NSInteger year = [self.dateParser yearUsingNumberSequence: yearString];
            if (year != NSNotFound) {
                self.year = year;
                NSLog(@"date sequence got year %@", @(self.year));
            }
        } break;

        default:
        break;
    }
}

//MARK: composing dates

- (NSString *) description {
    
    NSString * result = [super description];
    result = [result stringByAppendingFormat: @" day = %@, month = %@, year = %@",
                                              @(self.day), @(self.month), @(self.year)];
    return result;
}

@end

