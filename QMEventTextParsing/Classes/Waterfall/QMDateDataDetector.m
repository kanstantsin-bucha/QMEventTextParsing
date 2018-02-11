//
//  QMDateDataDetector.m
//  QromaScan
//
//  Created by bucha on 10/7/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMDateDataDetector.h"
#import "QMDetector+Private.h"
#import <CDBKit/CDBKit.h>


@interface QMDateDataDetector ()

@property (strong, nonatomic) NSDataDetector * dataDetector;
@property (strong, nonatomic) NSDateFormatter * dateFormatter;
@property (strong, nonatomic) NSLocale * locale;
@property (strong, nonatomic, readwrite) NSDate * detectedDate;

@end


@implementation QMDateDataDetector


    //MARK: - properties -

- (BOOL)failed {
    BOOL result = self.detectedDate == nil;
    return result;
}

- (NSDataDetector *) dataDetector {
    if (_dataDetector != nil) {
        return _dataDetector;
    }
    NSError * error = nil;
    _dataDetector = [[NSDataDetector alloc] initWithTypes: NSTextCheckingTypeDate
                                                    error: &error];
    if (error != nil) {
        NSLog(@"Failed to initiate QMDateDataDetector: %@", error);
    }
    
    return _dataDetector;
}

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter != nil) {
        return _dateFormatter;
    }
    
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = self.locale;
    
    NSString * dateComponents = @"yMMMMd";  //@"yMMMMd";
    
    NSString * dateFormatString = [NSDateFormatter dateFormatFromTemplate: dateComponents
                                                                  options: 0
                                                                   locale: self.locale];
    
    [dateFormatter setDateFormat: dateFormatString];
    
    NSLog(@"<%@> using date format %@ for locale %@",
              NSStringFromClass([self class]), dateFormatString, self.locale);
    
    _dateFormatter = dateFormatter;
    return _dateFormatter;
}

- (NSString *)detectedValueDescription {
    NSString * result = [NSString stringWithFormat: @"date: %@", self.detectedDate];
    return result;
}

    //MARK: - life cycle -

+ (instancetype) detectorUsingLocale: (NSLocale *) locale {
    
    if (locale == nil) {
        return  nil;
    }
    
    QMDateDataDetector * result = [[self class] new];
    result.locale = locale;
    
    return result;
}

    //MARK: - interface -

- (void) detectDataUsingString: (NSString *) string
                    completion: (CDBObjectErrorCompletion) completion {
    
    if (completion == nil) {
        return;
    }
    
    self.detectedDate = nil;
    self.detected = [NSMutableArray array];
    self.possible = [NSMutableArray array];
    
    NSRange range = NSMakeRange(0, string.length);
    
    weakCDB(wself);
    [self.dataDetector enumerateMatchesInString: string
                                        options: 0
                                          range: range
                                     usingBlock: ^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
       
        QMSemanticChunk * chunk = [QMSemanticChunk chunkUsingText: [string substringWithRange: result.range]
                                                     semanticType: QMSemanticTypeDetectedDate
                                                            range: result.range
                                                         position: NSNotFound];
        if (chunk == nil) {
            NSLog(@"<%@> get match in %@ but failed to create a chunk",
                       NSStringFromClass([self class]), NSStringFromRange(result.range));
            return;
        }
                                         
        [wself.possible addObject: chunk];
                                
        wself.detectedDate = [wself.dateFormatter dateFromString: chunk.token.text];
                         
        if (wself.detectedDate != nil) {
            [wself.detected addObject: chunk];
            *stop = YES;
        }
    }];
    
    NSString * passedBy = string;
    NSError * error = nil;
    
    if (self.failed) {
        BOOL notParsed = self.possible.count > 0;
        
        NSString * tokens = [[self.possible map:^id(QMSemanticChunk * chunk) {
            NSString * result = chunk.token.text;
            return result;
        }] componentsJoinedByString:@", "];
        
        error = notParsed ? [wself notParsedErrorUsingString: tokens]
                          : [wself notFoundErrorUsingString: string];
    } else {
        passedBy = [self stringByReducing: passedBy
                              usingChunks: self.detected];
        
        passedBy = [self stringByTrimmingMultipleSpacesIn: passedBy];
    }
    
    completion(passedBy, error);
}

    //MARK: - logic -

- (NSError *)notParsedErrorUsingString: (NSString *) string {
    NSString * desc = [NSString stringWithFormat: @"<%@> Date detected in '%@' but failed to be parsed",
                       NSStringFromClass([self class]), string];
    
    NSError * result = [NSError errorWithDomain: NSStringFromClass([self class])
                                           code: 1
                                       userInfo: @{NSLocalizedDescriptionKey : desc}];
    return result;
}


- (NSError *)notFoundErrorUsingString: (NSString *) string {
    NSString * desc = [NSString stringWithFormat: @"<%@> Date not found in '%@'",
                       NSStringFromClass([self class]), string];
    
    NSError * result = [NSError errorWithDomain: NSStringFromClass([self class])
                                           code: 0
                                       userInfo: @{NSLocalizedDescriptionKey : desc}];
    return result;
}

@end
