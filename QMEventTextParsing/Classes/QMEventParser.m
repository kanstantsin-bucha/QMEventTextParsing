//
//  QMLanguageParsing.h
//  QMLanguageParsing
//
//  Created by Kanstantsin Bucha on 2/10/18.
//

#import "QMEventParser.h"
#import "QMLinguisticParser.h"
#import "QMWaterfallParser.h"


@implementation QMEventParser


+ (id<QMEventParserInterface>) parserUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config
                                         peopleEntitled: (id<QMPeopleEntitledInterface>) entitled {
    
    Class parserClass = Nil;

    switch (config.eventParserServiceProvider) {
        case 1:
            parserClass = [QMWaterfallParser class];
            break;
        case 2:
            parserClass = [QMLinguisticParser class];
            break;
        default:
            parserClass = [QMWaterfallParser class];
            break;
    }
    
    id<QMEventParserInterface> result = [parserClass parserUsingConfiguration: config
                                                               peopleEntitled: entitled];
    
    return result;
}


@end
