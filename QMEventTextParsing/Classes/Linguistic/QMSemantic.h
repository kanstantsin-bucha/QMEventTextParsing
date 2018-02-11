//
//  QMSemantic.h
//  QromaScan
//
//  Created by bucha on 9/4/17.
//  Copyright © 2017 Qroma. All rights reserved.
//

#ifndef QMSemantic_h
#define QMSemantic_h

typedef NS_ENUM(NSUInteger, QMSemanticType) {
    QMSemanticTypeUndefined = 0,
    QMSemanticTypeNoun,
    QMSemanticTypePronoun,
    QMSemanticTypePersonalName,
    QMSemanticTypeOrganizationName,
    QMSemanticTypePlaceName,
    QMSemanticTypeAdjective,
    QMSemanticTypeNumber,
    QMSemanticTypePreposition,
    QMSemanticTypeDefinedArticle,
    QMSemanticTypeSpecialCharacter,
    QMSemanticTypeUnifyingPreposition,
    
    QMSemanticTypeDetectedDate,
    QMSemanticTypeDetectedPlace,
    QMSemanticTypeDetectedPerson
};

#define StringFromLinguisticTokenType(enum) (([@[\
@"Undefined",\
@"Noun",\
@"Pronoun",\
@"PersonalName",\
@"OrganizationName",\
@"PlaceName",\
@"Adjective",\
@"Number",\
@"Preposition",\
@"DefinedArticle",\
@"SpecialCharacter",\
@"UnifyingPreposition"\
] objectAtIndex:(enum)]))

typedef NS_ENUM(NSUInteger, QMSemanticeMatch) {
    QMSemanticeMatchUndefined = 0,
    QMSemanticeMatchFailed,
    QMSemanticeMatchProcessing,
    QMSemanticeMatchSoSo,
    QMSemanticeMatchResults,
    QMSemanticeMatchDominant,
    QMSemanticeMatchComplete
};

#define StringFromQMSemanticeMatch(enum) (([@[\
@"QMSemanticeMatchUndefined",\
@"QMSemanticeMatchFailed",\
@"QMSemanticeMatchProcessing",\
@"QMSemanticeMatchSoSo",\
@"QMSemanticeMatchResults",\
@"QMSemanticeMatchDominant",\
@"QMSemanticeMatchComplete",\
] objectAtIndex:(enum)]))


#endif /* QMSemantic_h */
