//
//  RedlandModel.h
//  Redland Objective-C Bindings
//  $Id: RedlandModel.h 654 2005-02-06 19:06:48Z kianga $
//
//  Copyright 2004 Rene Puls <http://purl.org/net/kianga/>
//	Copyright 2012 Pascal Pfiffner <http://www.chip.org/>
//
//  This file is available under the following three licenses:
//   1. GNU Lesser General Public License (LGPL), version 2.1
//   2. GNU General Public License (GPL), version 2
//   3. Apache License, version 2.0
//
//  You may not use this file except in compliance with at least one of
//  the above three licenses. See LICENSE.txt at the top of this package
//  for the complete terms and further details.
//
//  The most recent version of this software can be found here:
//  <https://github.com/p2/Redland-ObjC>
//
//  For information about the Redland RDF Application Framework, including
//  the most recent version, see <http://librdf.org/>.
//


#import <Foundation/Foundation.h>
#import <redland.h>
#import "RedlandWrappedObject.h"

@class RedlandStorage, RedlandStream, RedlandStatement, RedlandNode, RedlandIterator, RedlandIteratorEnumerator, RedlandStreamEnumerator;

/**
 *  This class provides the RDF model support.
 *
 *  A model is a set of statements (duplicates are not allowed, except in separate Redland contexts). Models can have statements added and removed, be queried
 *  and stored which is implemented by the RedlandStorage class. Wraps librdf_model.
 */
@interface RedlandModel : RedlandWrappedObject


+ (id)modelWithStorage:(RedlandStorage *)aStorage;
- (id)initWithStorage:(RedlandStorage *)aStorage;

- (librdf_model *)wrappedModel;

- (int)size;
- (void)sync;

- (RedlandStorage *)storage;

- (void)addStatement:(RedlandStatement *)aStatement;
- (void)addStatementsFromStream:(RedlandStream *)aStream;
- (void)addStatement:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode;
- (void)addStatementsFromStream:(RedlandStream *)aStream withContext:(RedlandNode *)contextNode;

- (BOOL)containsStatement:(RedlandStatement *)aStatement;
- (BOOL)removeStatement:(RedlandStatement *)aStatement;
- (BOOL)removeStatement:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode;
- (void)removeStatementsLike:(RedlandStatement *)aStatement;
- (void)removeAllStatementsWithContext:(RedlandNode *)contextNode;

- (BOOL)containsContext:(RedlandNode *)contextNode;

- (RedlandModel *)submodelForSubject:(RedlandNode *)aSubject;
- (BOOL)addSubmodel:(RedlandModel *)submodel;
- (BOOL)removeSubmodel:(RedlandModel *)submodel;
- (NSArray *)statementsLike:(RedlandStatement *)aStatement withDescendants:(BOOL)recursive;

- (RedlandStream *)statementStream;
- (RedlandStream *)streamOfStatementsLike:(RedlandStatement *)aStatement;
- (RedlandStream *)streamOfStatementsLike:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode;
- (RedlandStream *)streamOfAllStatementsWithContext:(RedlandNode *)contextNode;

- (RedlandIterator *)iteratorOfSourcesWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode;			//< Use -[RedlandModel enumeratorOfSourcesWithArc:target:] instead.
- (RedlandIterator *)iteratorOfArcsWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode;		//< Use -[RedlandModel enumeratorOfArcsWithSource:target:] instead.
- (RedlandIterator *)iteratorOfTargetsWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode;			//< Use -[RedlandModel enumeratorOfTargetsWithSource:arc:] instead.
- (RedlandIterator *)iteratorOfArcsIn:(RedlandNode *)targetNode;												//< Use -[RedlandModel enumeratorOfArcsIn:] instead.
- (RedlandIterator *)iteratorOfArcsOut:(RedlandNode *)sourceNode;												//< Use -[RedlandModel enumeratorOfArcsOut:] instead.
- (RedlandIterator *)contextIterator;																			//< Use -[RedlandModel contextEnumerator] instead.

- (RedlandNode *)sourceWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode;
- (RedlandNode *)arcWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode;
- (RedlandNode *)targetWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode;

- (BOOL)node:(RedlandNode *)targetNode hasIncomingArc:(RedlandNode *)arcNode;
- (BOOL)node:(RedlandNode *)sourceNode hasOutgoingArc:(RedlandNode *)arcNode;


- (RedlandNode *)valueOfFeature:(id)featureURI;
- (void)setValue:(RedlandNode *)featureValue ofFeature:(id)featureURI;


@end
