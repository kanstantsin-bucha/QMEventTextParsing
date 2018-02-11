//
//  QMPeopleEntitled.h
//  QromaScan
//
//  Created by bucha on 8/20/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMLinguisticToken.h"


#define QM_Documents_Settings_Initial_Relationships_File_LogicSeparators_Characters @"="
#define QM_Documents_Settings_Initial_Relationships_File_ComponentsSeparators_Characters @","


typedef NSArray<NSString *> QMPeople;


@interface QMRelationship : NSObject

@property (strong, nonatomic, readonly) NSString * alias;
@property (strong, nonatomic, readonly) QMPeople * people;

+ (instancetype)relationshipForAlias: (NSString *) alias
                               using: (QMPeople *) people;

@end


typedef NSDictionary<NSString *, NSArray<QMRelationship *> *> QMRelationships;


@protocol QMPeopleEntitledInterface

/*!
 * @brief relationship has noun as a key and persons array as an object;
 */

@property (strong, nonatomic, readonly) QMRelationships * relationships;

- (NSString *) validPersonNameUsing: (NSString *) name;
- (NSArray<QMRelationship *> *) relationshipsUsingRealtionshipToken: (QMLinguisticToken *) token;
- (QMRelationship *) resolveRelationships: (NSArray<QMRelationship *> *) relationships
                           usingNextToken: (QMLinguisticToken *) token;

@end


@interface QMPeopleEntitled : NSObject
<
QMPeopleEntitledInterface
>

@property (strong, nonatomic, readonly) QMPeople * people;


+ (instancetype)entitledUsingPeople: (QMPeople *) people
                      relationships: (QMRelationships *) relationships;

- (void) updateRelationshipsUsing: (QMRelationships *) relationships;


+ (QMRelationships *) composeRelationshipsFrom: (NSArray<QMRelationship *> *) relationshipsList;

/*!
 * @brief each object of strings array
 *   has nouns list list separated with ',' as the first part,
 *   separated with ('=') from the second part,
 *   which contains persons list separated ',';
 *   fathers,relatives=Mr. Gabriel, Mr. Smith
 * @result 
 *   each QMRelationship has alias that leads to string that contains persons separated by ','
 * @look 
 * QM_Documents_Settings_Initial_Relationships_File_ComponentsSeparators_Characters
 * QM_Documents_Settings_Initial_Relationships_File_LogicSeparators_Characters
 */

+ (NSArray<QMRelationship *> *) buildRelationshipsListUsing: (NSArray *) strings;

@end
