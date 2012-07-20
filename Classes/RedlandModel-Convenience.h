//
//  RedlandModel-Convenience.h
//  Redland Objective-C Bindings
//  $Id: RedlandModel-Convenience.h 307 2004-11-02 11:24:18Z kianga $
//
//  Copyright 2004 Rene Puls <http://purl.org/net/kianga/>
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
//  <http://purl.org/net/kianga/latest/redland-objc>
//
//  For information about the Redland RDF Application Framework, including
//  the most recent version, see <http://librdf.org/>.
//

/*!
	@header RedlandModel-Convenience.h
	Defines convenience methods for the RedlandModel class.
*/

#import "RedlandModel.h"

@class RedlandNode, RedlandStatement, RedlandStreamEnumerator, RedlandIteratorEnumerator, RedlandURI;

/*! 
	@category RedlandModel(Convenience)
	@abstract Convenience methods for the RedlandModel class.
*/
@interface RedlandModel (Convenience)

/*! 
	@method enumeratorOfStatementsLike:
	@abstract Returns an enumerator of all statements in the receiver that match the given statement.
	@param aStatement A (possibly partial) statement.
	@result A RedlandStreamEnumerator of the matching statements
*/
- (RedlandStreamEnumerator *)enumeratorOfStatementsLike:(RedlandStatement *)aStatement;

/*!
	@method enumeratorOfStatementsLike:withContext:
	@abstract Returns an enumerator of all statements in the receiver that match the given statement and context.
	@param aStatement A (possibly partial) statement
	@param contextNode The context
	@result A RedlandStreamEnumerator of the matching statements
*/
- (RedlandStreamEnumerator *)enumeratorOfStatementsLike:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode;

/*! 
	@method statementEnumerator
	@abstract Returns an enumerator of all statements in the receiver.
*/
- (RedlandStreamEnumerator *)statementEnumerator;

/*! 
	@method statementEnumeratorWithContext:
	@abstract Returns an enumerator of all statements in the receiver with the given context.
	@param contextNode The context
*/
- (RedlandStreamEnumerator *)statementEnumeratorWithContext:(RedlandNode *)contextNode;

/*! 
	@method enumeratorOfSourcesWithArc:target:context:
	@abstract Returns an enumerator of all sources in the receiver that have the given arcNode, targetNode, and contextNode.
*/
- (NSEnumerator *)enumeratorOfSourcesWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode context:(RedlandNode *)contextNode;

/*! 
	@method enumeratorOfSourcesWithArc:target:
	@abstract Returns an enumerator of all sources in the receiver that have the given arcNode and targetNode. 
*/
- (NSEnumerator *)enumeratorOfSourcesWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode;

/*! 
	@method enumeratorOfArcsWithSource:target:context:
	@abstract Returns an enumerator of all arcs in the receiver with the given sourceNode, targetNode, and context.
*/
- (NSEnumerator *)enumeratorOfArcsWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode context:(RedlandNode *)contextNode;

/*! 
	@method enumeratorOfArcsWithSource:target:
	@abstract Returns an enumerator of all arcs in the receiver with the given sourceNode and targetNode. 
*/
- (NSEnumerator *)enumeratorOfArcsWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode;

/*! 
	@method enumeratorOfTargetsWithSource:arc:context:
	@abstract Returns an enumerator of all targets in the receiver with the given sourceNode, arcNode, and contextNode.
*/
- (NSEnumerator *)enumeratorOfTargetsWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode context:(RedlandNode *)contextNode;

/*! 
	@method enumeratorOfTargetsWithSource:arc:
	@abstract Returns an enumerator of all targets in the receiver with the given sourceNode and arcNode. 
*/
- (NSEnumerator *)enumeratorOfTargetsWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode;

/*! 
	@method enumeratorOfArcsIn:context:
	@abstract Returns an enumerator of all arcs going into targetNode in context contextNode. 
*/
- (NSEnumerator *)enumeratorOfArcsIn:(RedlandNode *)targetNode context:(RedlandNode *)contextNode;

/*! 
	@method enumeratorOfArcsIn:
	@abstract Returns an enumerator of all arcs going into targetNode. 
*/
- (NSEnumerator *)enumeratorOfArcsIn:(RedlandNode *)targetNode;

/*! 
	@method enumeratorOfArcsOut:context:
	@abstract Returns an enumerator of all arcs coming out of sourceNode in context contextNode. 
*/
- (NSEnumerator *)enumeratorOfArcsOut:(RedlandNode *)sourceNode context:(RedlandNode *)contextNode;

/*! 
	@method enumeratorOfArcsOut:
	@abstract Returns an enumerator of all arcs coming out of sourceNode. 
*/
- (NSEnumerator *)enumeratorOfArcsOut:(RedlandNode *)sourceNode;

/*! 
	@method contextEnumerator
	@abstract Returns an NSEnumerator of all contexts in the receiver.
*/
- (NSEnumerator *)contextEnumerator;

@end
