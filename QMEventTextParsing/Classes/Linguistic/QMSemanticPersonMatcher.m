//
//  QMSemanticPersonMatcher.m
//  QromaScan
//
//  Created by bucha on 9/2/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMSemanticPersonMatcher.h"
#import "QMSemanticMatcher+Private.h"


@interface QMSemanticPersonMatcher ()

@property (strong, nonatomic) id<QMPeopleEntitledInterface> peopleEntitled;
@property (strong, nonatomic, readwrite) NSArray<NSString *> * forbiddenPrepositions;

@property (strong, nonatomic) NSMutableArray<NSString *> * personsBucket;
@property (strong, nonatomic) NSArray<QMRelationship *> * detectedRelationships;
@property (copy, nonatomic, readwrite) NSString * possiblePerson;

@property (assign, nonatomic) BOOL hasForbiddenElement;
@property (assign, nonatomic) BOOL hasPronoun;
@property (assign, nonatomic) BOOL hasMatched;
@property (assign, nonatomic) BOOL hasNumber;

@end


@implementation QMSemanticPersonMatcher

//MARK: - property -

- (BOOL)hasResults {
    BOOL result = self.persons.count > 0;
    return result;
}

- (BOOL)hasDominant {
    BOOL result = self.hasMatched;
    return result;
}

- (BOOL)hasComplete {
    return NO;
}

- (BOOL)shouldProcess {
    BOOL result = YES;//self.possiblePerson != nil;
    return result;
}

- (BOOL)shouldFail {
    if (self.hasDominant) {
        return NO;
    }
    
    BOOL result = self.hasNumber
                  || (self.hasResults || self.shouldProcess) == NO;
    return result;
}

- (NSArray<NSString *> *)persons {
    return [self.personsBucket copy];
}

//MARK: - life cycle -

+ (instancetype) matcherUsing: (id<QMPeopleEntitledInterface>) peopleEntitled
        forbiddenPrepositions: (NSArray<NSString *> *) forbiddenPrepositions {
    QMSemanticPersonMatcher * result = [[self class] new];
    
    result.peopleEntitled = peopleEntitled;
    result.forbiddenPrepositions = forbiddenPrepositions;
    
    result.personsBucket = [NSMutableArray array];
    
    return result;
}

//MARK: - logic -

- (void) removeElement: (QMSemanticChunk *) element {
    // Is not allowed there
}

- (BOOL) shouldUpdateMatchFor: (QMSemanticChunk *) chunk {
    BOOL notPersonalName = chunk.type != QMSemanticTypePersonalName;
    BOOL notNoun = chunk.type != QMSemanticTypeNoun;
    BOOL notPronoun = chunk.type != QMSemanticTypePronoun;
    BOOL isDelimiter = notPersonalName
                      && notNoun
                      && notPronoun;
    
    BOOL result = isDelimiter == NO;
    
    if (isDelimiter) {
        self.possiblePerson = nil;
    }
    
    return result;
}

- (BOOL) isDelimiter: (QMSemanticChunk *) element {
    BOOL notPersonalName = element.type != QMSemanticTypePersonalName;
    BOOL notNoun = element.type != QMSemanticTypeNoun;
    BOOL notPronoun = element.type != QMSemanticTypePronoun;
    BOOL result = notPersonalName
                  && notNoun
                  && notPronoun;
    return result;
}

- (void) processDelimiter: (QMSemanticChunk *) delimiter {
    
    
}

- (BOOL) processChunk: (QMSemanticChunk *) chunk {
    
    if (chunk.type != QMSemanticTypeNoun) {
        self.possiblePerson = nil;
    }
    
    if (self.detectedRelationships != nil) {
        QMRelationship * relationship = [self.peopleEntitled resolveRelationships: self.detectedRelationships
                                                                   usingNextToken: chunk.token];
        if (relationship != nil) {
            [self.personsBucket addObjectsFromArray: relationship.people];
            
            self.detectedRelationships = nil;
            self.possiblePerson = nil;
            return YES;
        }
        self.detectedRelationships = nil;
    }
    
    switch (chunk.type) {
            
        case QMSemanticTypeNoun: {
            [self processNounToken: chunk.token];
        } break;
            
        case QMSemanticTypeAdjective: {
            [self processRelationshipToken: chunk.token];
        } break;
            
        case QMSemanticTypePronoun: {
            [self processRelationshipToken: chunk.token];
            self.hasPronoun = YES;
        } break;

        case QMSemanticTypePersonalName: {
            if ([self.forbiddenPrepositions indexOfObject: self.sequenceDelimiter.token.lowercase] == NSNotFound) {
                [self processNameToken: chunk.token];
            } else {
                [self processNounToken: chunk.token];
            }
        } break;

        case QMSemanticTypeNumber: {
            self.hasNumber = YES;
        } break;

        case QMSemanticTypeSpecialCharacter: {
            self.hasForbiddenElement = YES;
        } break;

        case QMSemanticTypePreposition: {
            self.hasForbiddenElement = YES; // possible not needed
        } break;

        default: {

        }
        break;
    }
    
    return YES;
}

- (void) processFinish {
    if (self.possiblePerson != nil) {
        [self processPossiblePerson: self.possiblePerson];
    }
    
    if (self.detectedRelationships != nil) {
        QMRelationship * relationship = [self.peopleEntitled resolveRelationships: self.detectedRelationships
                                                                   usingNextToken: nil];
        if (relationship != nil) {
            [self.personsBucket addObjectsFromArray: relationship.people];
        }
    }
}

- (void) processNounToken: (QMLinguisticToken *) token {
    BOOL succeed = [self processRelationshipToken: token];
    if (succeed) {
        return;
    }
    
    [self processPartialNameToken: token];
}

- (void) processNameToken: (QMLinguisticToken *) token {
    NSString * personName = [self.peopleEntitled validPersonNameUsing: token.text];
    if (personName == nil) {
        return;
    }
    
    [self.personsBucket addObject: personName];
}

- (BOOL) processRelationshipToken: (QMLinguisticToken *) token {
    NSArray<QMRelationship *> * relationships =
        [self.peopleEntitled relationshipsUsingRealtionshipToken: token];
    
    if (relationships.count == 1) {
        [self.personsBucket addObjectsFromArray: relationships.firstObject.people];
        return YES;
    }
    
    if (relationships.count > 1) {
        self.detectedRelationships = relationships;
        return YES;
    }
    
    return NO;
}

- (void) processPartialNameToken: (QMLinguisticToken *) token {
    if ([token hasFirstLetterUppercase] == NO) {
        self.possiblePerson = nil;
        return;
    }
    
    if (self.possiblePerson != nil) {
        NSString * fullName = [self.possiblePerson stringByAppendingFormat:@" %@", token.text];
        self.possiblePerson = nil;
        BOOL foundFullName = [self processPossiblePerson: fullName];
        if (foundFullName) {
            return;
        }
    }
    
    BOOL found = [self processPossiblePerson: token.text];
    if (found) {
        return;
    }
    
    self.possiblePerson = token.text;
}

- (BOOL) processPossiblePerson: (NSString *) possiblePerson {
    NSString * personName = [self.peopleEntitled validPersonNameUsing: possiblePerson];
    if (personName == nil) {
        return NO;
    }
    
    [self.personsBucket addObject: personName];
    return YES;
}

- (NSString *) description {
    
    NSString * result = [super description];
    result = [result stringByAppendingFormat: @" persons = %@, possible = %@",
                                              self.persons, self.possiblePerson];
    return result;
}

@end


