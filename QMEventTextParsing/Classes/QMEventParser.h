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

+ (instancetype) parserUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config
                           peopleEntitled: (id<QMPeopleEntitledInterface>) entitled;

- (instancetype)init __unavailable;

/*!
 *  @brief parse text and provide
 *  QMParserResult object in completion block
 */

- (void)parseText: (NSString *) text
   withCompletion: (CDBObjectErrorCompletion) completion;


@end


@interface QMEventParser: NSObject

+ (id<QMEventParserInterface>) parserUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config
                                         peopleEntitled: (id<QMPeopleEntitledInterface>) entitled;

@end
