#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "QMPeopleEntitled.h"
#import "QMTextRecognitionConfig+Private.h"
#import "QMTextRecognitionConfig.h"
#import "QMDateParser.h"
#import "QMLinguisticTagger.h"
#import "QMLinguisticToken.h"
#import "QMParserResult+Private.h"
#import "QMParserResult.h"
#import "QMSemanticChunk.h"
#import "QMLinguisticParser.h"
#import "QMLinguisticUnit.h"
#import "QMSemantic.h"
#import "QMSemanticDateMatcher.h"
#import "QMSemanticLocationMatcher.h"
#import "QMSemanticMatcher+Private.h"
#import "QMSemanticMatcher.h"
#import "QMSemanticPersonMatcher.h"
#import "QMEventParser.h"
#import "QMEventTextParsing.h"
#import "QMDateDataDetector.h"
#import "QMDetector+Private.h"
#import "QMDetector.h"
#import "QMLogicDateDetector.h"
#import "QMLogicPlaceDetector.h"
#import "QMPeopleDataDetector.h"
#import "QMPlaceDataDetector.h"
#import "QMWaterfallParser.h"

FOUNDATION_EXPORT double QMEventTextParsingVersionNumber;
FOUNDATION_EXPORT const unsigned char QMEventTextParsingVersionString[];

