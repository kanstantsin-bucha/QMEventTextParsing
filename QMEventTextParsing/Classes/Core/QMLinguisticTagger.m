//
//  QMLinguisticTagger.m
//  QromaScan
//
//  Created by bucha on 10/5/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMLinguisticTagger.h"
#import <CDBKit/CDBKit.h>
#import "QMTextRecognitionConfig.h"


@interface QMLinguisticTagger ()

@property (strong, nonatomic) NSLinguisticTagger * tagger;
@property (strong, nonatomic, readwrite) id<QMTextRecognitionConfigInterface> config;

@end


@implementation QMLinguisticTagger

//MARK: - property -

- (NSLinguisticTagger *)tagger {
    if (_tagger != nil) {
        return _tagger;
    }
    
    _tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: @[NSLinguisticTagSchemeNameTypeOrLexicalClass]
                                                     options: 0];
    return _tagger;
}

// MARK: - life cycle -

+ (instancetype) taggerUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config {
    
    QMLinguisticTagger * result = [QMLinguisticTagger new];

    result.config = config;

    return result;
}

//MARK: - interface -

- (BOOL)isMacOS {
#if TARGET_OS_IPHONE
    return NO;
#else
    return YES;
#endif
}

- (void) enumerateChunksInString: (NSString *) string
                      usingBlock: (void (^)(QMSemanticChunk * chunk, BOOL *stop)) block {
    
    if (block == nil) {
        return;
    }
    
    NSArray * tagSchemes = [NSLinguisticTagger availableTagSchemesForLanguage: self.config.language];
    
    NSLog(@"ATag:: Language: %@. Available tag schemes: %@",
              self.config.language, tagSchemes);
    
    if ([tagSchemes containsObject: NSLinguisticTagSchemeNameTypeOrLexicalClass] == NO) {
        NSLog(@"ATag:: Failed enumerate tokens because NSLinguisticTagSchemeNameTypeOrLexicalClass not available");
        return;
    }
    
    self.tagger.string = string;
    
    NSRange fullRange = NSMakeRange(0, string.length);
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace;
    
    BOOL bugFreeOS = NO;

    #if TARGET_OS_IPHONE

        if (@available(iOS 11, *)) {
            bugFreeOS = YES;
            
            // in iOS 10 and erlier this makes parsing fully impossible
            // because it detects noun + number pairs as a noun or person name
            options |= NSLinguisticTaggerJoinNames;
            
            NSLog(@"ATag:: iOS => 11");
            NSLog(@"ATag:: Dominant language: %@", self.tagger.dominantLanguage);
        } else {
            NSLog(@"ATag:: iOS < 11");
        }
    #else
    
        if (@available(macos 10.13, *)) {
            
            bugFreeOS = YES;
            
            // in macos 10.12 and erlier this makes parsing fully impossible
            // because it detects noun + number pairs as a noun or person name
            options |= NSLinguisticTaggerJoinNames;
            
            NSLog(@"ATag:: macOS => 10.13");
            NSLog(@"ATag:: Dominant language: %@", self.tagger.dominantLanguage);
        } else {
            NSLog(@"ATag:: macOS < 10.13");
        }
    #endif

    weakCDB(wself);
    __block NSInteger position = 0;
    [self.tagger enumerateTagsInRange: fullRange
                               scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass
                              options: options
                           usingBlock: ^(NSLinguisticTag  _Nullable tag, NSRange tokenRange, NSRange sentenceRange, BOOL * _Nonnull stop) {
                          
        QMSemanticChunk * chunk = [wself chunkUsing: string
                                        inBugFreeOS: bugFreeOS
                                         tokenRange: tokenRange
                                           position: position
                                                tag: tag];
        if (chunk == nil) {
            return;
        }
        position += 1;
        block(chunk, stop);
    }];
    
}

- (QMSemanticChunk *) chunkUsing: (NSString *) unitString
                     inBugFreeOS: (BOOL) bugFreeOS
                      tokenRange: (NSRange) tokenRange
                        position: (NSInteger) position
                             tag: (NSString *) tag {
    
    NSString * token = [unitString substringWithRange: tokenRange];
    
    NSLog(@"ATag:: %@ = %@", token, tag);
    
    QMSemanticType type = QMSemanticTypeUndefined;
    if ([tag isEqualToString: NSLinguisticTagAdjective]) {
        type = QMSemanticTypeAdjective;
    }
    
    if ([tag isEqualToString: NSLinguisticTagNumber]) {
        type = QMSemanticTypeNumber;
        /*
         iOS 10 tagger provide "April 19 74" as PersonalName
         so we decompose number as 19 74
         and should join parts if number has a space
         [QMLinguisticParserTest testN12]
         */
        if (bugFreeOS == NO) {
            token = [self removeAllWhitespacesIn: token];
        }
        /* iOS 10 tagger provide "April 19 74" as PersonalName */
    }
    
    if ([tag isEqualToString: NSLinguisticTagNoun]) {
        type = QMSemanticTypeNoun;
    }
    
    if ([tag isEqualToString: NSLinguisticTagPronoun]) {
       
        if (bugFreeOS == NO) {
            type = QMSemanticTypePronoun;
        } else {
            // iOS 11.1 detects 2017, 201999 as pronoun
            NSInteger number = token.integerValue;
            if (number == 0) {
                type = QMSemanticTypePronoun;
            } else {
                type = QMSemanticTypeNumber;
            }
        }
    }
    
    if ([tag isEqualToString: NSLinguisticTagPersonalName]) {
        if (bugFreeOS) {
            type = QMSemanticTypePersonalName;
        } else {
            type = QMSemanticTypeNoun;
        }
    }
    
    if ([tag isEqualToString: NSLinguisticTagOrganizationName]) {
        type = QMSemanticTypeOrganizationName;
    }
    
    if ([tag isEqualToString: NSLinguisticTagPlaceName]) {
        type = QMSemanticTypePlaceName;
    }
    
    if ([tag isEqualToString: NSLinguisticTagPreposition]) {
        if ([self.config.unifyingPrepositions indexOfObject: token.lowercaseString] != NSNotFound) {
            type = QMSemanticTypeUnifyingPreposition;
        } else {
            /*
             apple tagger tags "AT&T" as preposition AT punctuation and noun T. So-so tagging
             will add additional logic to check this issue
             [QMLinguisticParserTest testN15]
             */
            NSCharacterSet * upper = [NSCharacterSet uppercaseLetterCharacterSet];
            NSRange upperRange = [token rangeOfCharacterFromSet: upper];
            
            NSCharacterSet * capital = [NSCharacterSet capitalizedLetterCharacterSet];
            NSRange capitalRange = [token rangeOfCharacterFromSet: capital];
            
            if (capitalRange.location == 0
                || upperRange.location == 0) {
                type = QMSemanticTypeNoun;
            } else {
                type = QMSemanticTypePreposition;
            }
            /* apple tagger tags "AT&T" as preposition AT punctuation and noun T. So-so tagging */
        }
    }
    
    if ([tag isEqualToString: NSLinguisticTagPunctuation]) {
        if ([self.config.punctuationMarks indexOfObject: token.lowercaseString] != NSNotFound) {
            return nil;
        } else {
            type = QMSemanticTypeSpecialCharacter;;
        }
    }
    
    if ([tag isEqualToString: NSLinguisticTagDeterminer]
        && [self.config.definiteArticles indexOfObject: token.lowercaseString] != NSNotFound) {
        type = QMSemanticTypeDefinedArticle;
    }
    
    /*
     apple tagger tags "201999" as pronoun. So-so tagging
     will add additional logic to check this issue
     [QMLinguisticParserTest testThatAllRevealedN3]
     */
    
    if (bugFreeOS == NO
        && token.integerValue != 0) {
        type = QMSemanticTypeNumber;
    }
    
    /* apple tagger tags "201999" as pronoun. So-so tagging */
    
    QMSemanticChunk * result = [QMSemanticChunk chunkUsingText: token
                                                  semanticType: type
                                                         range: tokenRange
                                                      position: position];
    return result;
}

//MARK: - logic -

- (NSString *) removeAllWhitespacesIn: (NSString *) string {
    NSString * result = [string stringByReplacingOccurrencesOfString: @" "
                                                          withString: @""];
    return result;
}

@end
