//
//  QMPeopleDataDetector.m
//  QromaScan
//
//  Created by bucha on 10/8/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMPeopleDataDetector.h"
#import "QMDetector+Private.h"
#import "QMLinguisticTagger.h"
#import <CDBKit/CDBKit.h>


@interface QMPeopleDataDetector ()

@property (strong, nonatomic) id<QMPeopleEntitledInterface> entitled;
@property (strong, nonatomic) id<QMTextRecognitionConfigInterface> config;
@property (strong, nonatomic) QMLinguisticTagger * tagger;

@property (strong, nonatomic) NSMutableArray<NSString *> * personNames;
@property (strong, nonatomic) NSArray<QMRelationship *> * detectedRelationships;
@property (strong, nonatomic) QMSemanticChunk * detectedRelationshipsChunk;

@end


@implementation QMPeopleDataDetector

    //MARK: - property -

- (QMLinguisticTagger *) tagger {
    if (_tagger != nil) {
        return _tagger;
    }
    
    _tagger = [QMLinguisticTagger taggerUsingConfiguration: self.config];
    return _tagger;
}

- (BOOL)failed {
    BOOL result = self.personNames.count == 0;
    return result;
}

- (NSArray<NSString *> *) detectedPeople {
    return [self.personNames copy];
}

- (NSString *)detectedValueDescription {
    NSString * result = [NSString stringWithFormat: @"people: %@", self.detectedPeople];
    return result;
}

    //MARK: - life cycle -

+ (instancetype) detectorUsingConfiguration: (id<QMTextRecognitionConfigInterface>) config
                             peopleEntitled: (id<QMPeopleEntitledInterface>) entitled {
    if (entitled == nil
        || config.language == nil) {
        return nil;
    }
    
    QMPeopleDataDetector * result = [[self class] new];
    
    result.entitled = entitled;
    result.config = config;
    
    return result;
}

    //MARK: - logic -

- (void)detectDataUsingString: (NSString *)string
                   completion: (CDBObjectErrorCompletion)completion {
    if (completion == nil) {
        return;
    }
    
    self.personNames = [NSMutableArray array];
    self.detected = [NSMutableArray array];
    self.possible = [NSMutableArray array];
    
    weakCDB(wself);
    [self.tagger enumerateChunksInString: string
                              usingBlock: ^ (QMSemanticChunk * chunk, BOOL * stop) {
//        NSLog(@":: %@", chunk.token.text);
                                  
        if (self.detectedRelationships != nil) {
            QMRelationship * relationship = [wself.entitled resolveRelationships: wself.detectedRelationships
                                                                  usingNextToken: chunk.token];
            if (relationship != nil) {
                [wself.detected addObject: wself.detectedRelationshipsChunk];
                [wself.detected addObject: chunk];
                [wself.personNames addObjectsFromArray: relationship.people];
                
                wself.detectedRelationshipsChunk = nil;
                wself.detectedRelationships = nil;
                
                return;
            } else {
                QMRelationship * relationship = [self.entitled resolveRelationships: self.detectedRelationships
                                                                     usingNextToken: nil];
                if (relationship != nil) {
                    [self.detected addObject: wself.detectedRelationshipsChunk];
                    [self.personNames addObjectsFromArray: relationship.people];
                }
                
                wself.detectedRelationshipsChunk = nil;
                wself.detectedRelationships = nil;
            }
        }
                                  
        NSArray<NSString *> * personNames = nil;
                                  
        switch (chunk.type) {
            case QMSemanticTypeAdjective:
            case QMSemanticTypePronoun:
            case QMSemanticTypeNoun: {
                [self.possible addObject: chunk];
                
                NSArray<QMRelationship *> * relationships = [wself.entitled relationshipsUsingRealtionshipToken: chunk.token];
                if (relationships.count == 1) {
                    personNames = relationships.firstObject.people;
                }
                
                if (relationships.count > 1) {
                    wself.detectedRelationships = relationships;
                    wself.detectedRelationshipsChunk = chunk;
                }
                
            } break;
              
            case QMSemanticTypePersonalName: {
                [self.possible addObject: chunk];
                personNames = [wself personNamesUsingName: chunk.token];
            } break;
              
            default : {
            } break;
        }
                                  
        if (personNames != nil) {
            [wself.personNames addObjectsFromArray: personNames];
            [wself.detected addObject: chunk];
        }
    }];
    
    if (self.detectedRelationships != nil) {
        QMRelationship * relationship = [self.entitled resolveRelationships: self.detectedRelationships
                                                             usingNextToken: nil];
        if (relationship != nil) {
            [self.detected addObject: wself.detectedRelationshipsChunk];
            [self.personNames addObjectsFromArray: relationship.people];
        }
        
        wself.detectedRelationshipsChunk = nil;
        wself.detectedRelationships = nil;
    }
    
    if (wself.detected.count == 0) {
        NSError * error = [self notFoundErrorUsingString: string];
        completion(string, error);
        return;
    }
    
    if (self.failed) {
        NSArray * tokens = [self.possible map:^id(QMSemanticChunk * chunk) {
            NSString * result = chunk.token.text;
            return result;
        }];
        
        NSString * possibleTokens = [tokens componentsJoinedByString:@", "];
        NSError * error = [self notValidatedErrorUsingString: possibleTokens];
        completion(string, error);
        return;
    }
    
    NSString * passedBy = [self stringByReducing: string
                                     usingChunks: self.detected];
    
    passedBy = [self stringByTrimmingMultipleSpacesIn: passedBy];
    
    completion(passedBy, nil);
}

    //MARK: - logic -

- (NSArray<NSString *> *) personNamesUsingName: (QMLinguisticToken *) token {
    NSString * name = [self.entitled validPersonNameUsing: token.text];
    
    if (name == nil) {
        return nil;
    }
    
    return @[name];
}

- (NSError *)notValidatedErrorUsingString: (NSString *) string {
    NSString * desc = [NSString stringWithFormat: @"<%@> People found '%@' but validation failed",
                       NSStringFromClass([self class]), string];
    
    NSError * result = [NSError errorWithDomain: NSStringFromClass([self class])
                                           code: 1
                                       userInfo: @{NSLocalizedDescriptionKey : desc}];
    return result;
}

- (NSError *)notFoundErrorUsingString: (NSString *) string {
    NSString * desc = [NSString stringWithFormat: @"<%@> People not found in '%@'",
                       NSStringFromClass([self class]), string];
    
    NSError * result = [NSError errorWithDomain: NSStringFromClass([self class])
                                           code: 0
                                       userInfo: @{NSLocalizedDescriptionKey : desc}];
    return result;
}

@end
