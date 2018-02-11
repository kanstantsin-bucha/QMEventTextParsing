//
//  QMPeopleEntitled.m
//  QromaScan
//
//  Created by bucha on 8/20/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import "QMPeopleEntitled.h"
#import "QMLinguisticToken.h"


@interface QMRelationship ()

@property (strong, nonatomic, readwrite) NSString * alias;
@property (strong, nonatomic, readwrite) QMPeople * people;

@end


@interface QMPeopleEntitled ()

@property (strong, nonatomic, readwrite) QMPeople * people;
@property (strong, nonatomic, readwrite) QMRelationships * relationships;

- (void) updateRelationshipsUsing: (QMRelationships *) relationships;

@end


@implementation QMPeopleEntitled

//MARK: - life cycle -

+ (instancetype)entitledUsingPeople:(QMPeople *)people
                      relationships:(QMRelationships *)relationships {
    QMPeopleEntitled * result = [[self class] new];
    result.people = people;
    result.relationships = relationships;
    
    return result;
}

//MARK: - interface -

- (void) updateRelationshipsUsing: (QMRelationships *) relationships {
    self.relationships = relationships;
}

+ (QMRelationships *) composeRelationshipsFrom: (NSArray<QMRelationship *> *) relationshipsList {
    
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    
    for (QMRelationship * relationship in relationshipsList) {
        NSString * key = relationship.alias;
        
        NSArray * relationshipsList = result[key];
        if (relationshipsList != nil) {
            relationshipsList = [relationshipsList arrayByAddingObject: relationship];
        } else {
            relationshipsList = @[relationship];
        }
        
        result[key] = relationshipsList;
    }
    
    return [result copy];
}

+ (NSArray<QMRelationship *> *) buildRelationshipsListUsing: (NSArray *) strings {
    
    NSCharacterSet * logicSeparators = [NSCharacterSet characterSetWithCharactersInString:
                                        QM_Documents_Settings_Initial_Relationships_File_LogicSeparators_Characters];
    NSCharacterSet * componentsSeparators = [NSCharacterSet characterSetWithCharactersInString:
                                             QM_Documents_Settings_Initial_Relationships_File_ComponentsSeparators_Characters];
    
    NSMutableArray * result = [NSMutableArray array];
    
    for (NSString * relationshipString in strings) {
        NSArray * parts = [relationshipString componentsSeparatedByCharactersInSet: logicSeparators];
        if (parts.count != 2) {
            continue;
        }
        
        NSArray * names = [parts.lastObject componentsSeparatedByCharactersInSet: componentsSeparators];
        NSMutableArray * rightNames = [NSMutableArray array];
        
        for (NSString * name in names) {
            NSString * rightName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (rightName.length == 0) {
                continue;
            }
            [rightNames addObject: rightName];
        }
        
        if (rightNames.count == 0) {
            continue;
        }
        
        NSArray * aliases = [[parts.firstObject lowercaseString] componentsSeparatedByCharactersInSet: componentsSeparators];
        
        for (NSString * alias in aliases) {
            if (alias.length == 0) {
                continue;
            }
            NSString * rightAlias = [alias stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            QMRelationship * relationship = [QMRelationship relationshipForAlias: rightAlias
                                                                           using: rightNames];
            if (relationship == nil) {
                NSLog(@"Failed to create relationship using alias: %@\r names: %@", rightAlias, rightNames);
                continue;
            }
            
            [result addObject: relationship];;
        }
    }
    
    return result.count > 0 ? [result copy]
                            : nil;
}

//MARK: QMPeopleEntitledInterface

- (NSString *) validPersonNameUsing: (NSString *) name {
    
    if ([self.people containsObject: name]) {
        return  name;
    }
    
    return nil;
}

- (NSArray<QMRelationship *> *) relationshipsUsingRealtionshipToken: (QMLinguisticToken *) token {
    NSArray<QMRelationship *> * result = self.relationships[token.lowercase];
    return result;
}

- (QMRelationship *) resolveRelationships: (NSArray<QMRelationship *> *) relationships
                           usingNextToken: (QMLinguisticToken *) token {
    if (token.text.length == 0
        || [token hasFirstLetterUppercase] == NO) {
        return relationships.firstObject;
    }
    
    for (QMRelationship * relationship in relationships) {
        if ([relationship.people.firstObject rangeOfString: token.text].location == 0) {
            return relationship;
        }
    }
    return nil;
}

//MARK: - logic -

@end

@implementation QMRelationship

    //MARK: -life cycle-

+ (instancetype)relationshipForAlias: (NSString *) alias
                               using: (NSArray<NSString *> *) people; {
    if (alias.length == 0
        || people.count == 0) {
        return nil;
    }
    
    QMRelationship * result = [[self class] new];
    result.alias = alias;
    result.people = people;
    return result;
}

    //MARK -equality-

- (NSUInteger) hash {
    return self.people.hash;
}

- (BOOL) isEqual: (id) object {
    if (object == nil) {
        return NO;
    }
    
    if ([[self class] isEqual: [object class]] == NO) {
        return NO;
    }
    
    if ([self.people isEqualToArray: [(QMRelationship *)object people]] == NO) {
        return NO;
    }
    
    return YES;
}

- (NSString *) description {
    NSString * result = [NSString stringWithFormat: @"<%@-%@> alias: %@\r, people: %@",
                         NSStringFromClass([self class]), @(self.hash), self.alias, self.people];
    return result;
}

@end
