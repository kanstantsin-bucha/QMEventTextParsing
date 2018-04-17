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

@property (strong, nonatomic, readonly, nullable) NSString * alias;
@property (strong, nonatomic, readonly, nullable) QMPeople * people;

+ (instancetype _Nullable)relationshipForAlias: (NSString * _Nonnull) alias
                                         using: (QMPeople * _Nonnull) people;

@end


typedef NSDictionary<NSString *, NSArray<QMRelationship *> *> QMRelationships;


@protocol QMPeopleEntitledInterface

/*!
 * @brief relationship has noun as a key and persons array as an object;
 */

@property (strong, nonatomic, readonly) QMRelationships * relationships;

- (NSString * _Nullable) validPersonNameUsing: (NSString * _Nonnull) name;
- (NSArray<QMRelationship *> * _Nullable) relationshipsUsingRealtionshipToken: (QMLinguisticToken * _Nonnull) token;
- (QMRelationship * _Nullable) resolveRelationships: (NSArray<QMRelationship *> * _Nonnull) relationships
                                     usingNextToken: (QMLinguisticToken * _Nullable) token;

@end


@interface QMPeopleEntitled : NSObject
<
QMPeopleEntitledInterface
>

@property (strong, nonatomic, readonly, nullable) QMPeople * people;


+ (instancetype _Nullable)entitledUsingPeople: (QMPeople * _Nonnull) people
                                relationships: (QMRelationships * _Nonnull) relationships;

- (void) updateRelationshipsUsing: (QMRelationships * _Nonnull) relationships;


+ (QMRelationships * _Nonnull) composeRelationshipsFrom: (NSArray<QMRelationship *> * _Nullable) relationshipsList;

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

+ (NSArray<QMRelationship *> * _Nullable) buildRelationshipsListUsing: (NSArray * _Nonnull) strings;

@end
