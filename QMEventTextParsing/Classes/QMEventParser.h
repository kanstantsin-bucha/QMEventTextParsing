//
//  QMLanguageParsing.h
//  QMLanguageParsing
//
//  Created by Kanstantsin Bucha on 2/10/18.
//

#import <CDBKit/CDBKit.h>
#import "QMPeopleEntitled.h"
#import "QMTextRecognitionConfig.h"
#import "QMParserResult.h"

@protocol QMEventParserInterface

@property (strong, nonatomic, readonly) id<QMTextRecognitionConfigInterface> config;
@property (strong, nonatomic, readonly) id<QMPeopleEntitledInterface> peopleEntitled;

+ (instancetype _Nullable) parserUsingConfiguration: (id<QMTextRecognitionConfigInterface> _Nonnull) config
                                     peopleEntitled: (id<QMPeopleEntitledInterface> _Nonnull) entitled;

- (instancetype _Nullable)init __unavailable;

/*!
 *  @brief parse text and provide
 *  QMParserResult object in completion block
 */

- (void)parseText: (NSString * _Nonnull) text
   withCompletion: (CDBObjectErrorCompletion _Nonnull) completion;


@end


@interface QMEventParser: NSObject

+ (id<QMEventParserInterface> _Nullable) parserUsingConfiguration: (id<QMTextRecognitionConfigInterface> _Nonnull) config
                                                   peopleEntitled: (id<QMPeopleEntitledInterface> _Nonnull) entitled;

@end
