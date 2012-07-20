//
//  RedlandModel.h
//  Redland Objective-C Bindings
//  $Id: RedlandModel.h 654 2005-02-06 19:06:48Z kianga $
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
	@header RedlandModel.h
	Defines the RedlandModel class.
*/

#import <Foundation/Foundation.h>
#import <Redland/redland.h>
#import "RedlandWrappedObject.h"

@class RedlandStorage, RedlandStream, RedlandStatement, RedlandNode, RedlandIterator, RedlandIteratorEnumerator, RedlandStreamEnumerator;

/*! 
	@class RedlandModel
	@abstract This class provides the RDF model support. A model is a set of statements (duplicates are not allowed, except in separate Redland contexts). Models can have statements added and removed, be queried and stored which is implemented by the RedlandStorage class. Wraps librdf_model.
*/
@interface RedlandModel : RedlandWrappedObject {
}

/*! 
	@method model
	@abstract Creates and returns a new RedlandModel with an in-memory, context-enabled hash storage.
*/
+ (RedlandModel *)model;

/*! 
	@method initWithStorage:
	@abstract Initialises a new RedlandModel using the given storage. 
	@param aStorage The storage to use for the new model
*/
- (id)initWithStorage:(RedlandStorage *)aStorage;

/*! 
	@method wrappedModel
	@abstract Returns the underlying librdf_model pointer of the receiver.
*/
- (librdf_model *)wrappedModel;

/*! 
	@method print
	@abstract Dumps the contents of the receiver to standard error.
	@discussion For debugging purposes.
*/
- (void)print;

/*! 
	@method size
	@abstract Returns the number of statements in the receiver.
	@result The number of statements in the model, or a negative value on failure.
	@discussion Not all stores support this function. If you absolutely need an accurate size, you can enumerate the statements manually.
*/
- (int)size;

/*! 
	@method sync
	@abstract Synchronises the model to the model implementation. 
*/
- (void)sync;

/*! 
	@method storage
	@abstract Returns the underlying RedlandStorage of the receiver.
*/
- (RedlandStorage *)storage;

/*! 
	@method addStatement:
	@param aStatement A complete statement (with non-nil subject, predicate, and object)
	@abstract Adds a single statement to the receiver. Duplicate statements are ignored. 
*/
- (void)addStatement:(RedlandStatement *)aStatement;

/*! 
	@method addStatementsFromStream:
	@param aStream A stream of complete statements
	@abstract Adds a stream of statements to the receiver. Duplicate statements are ignored.
*/
- (void)addStatementsFromStream:(RedlandStream *)aStream;

/*! 
	@method addStatement:withContext:
	@param aStatement A complete statement
	@param contextNode The context to associate this statement with
	@abstract Adds a single statement to the receiver with the given context.
*/
- (void)addStatement:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode;

/*! 
	@method addStatementsFromStream:withContext:
	@param aStream A stream of complete statements
	@param contextNode The context to associate each statement with
	@abstract Adds a stream of statements to the receiver in the given context.
*/
- (void)addStatementsFromStream:(RedlandStream *)aStream withContext:(RedlandNode *)contextNode;

/*! 
	@method containsStatement:
	@abstract Returns YES if the receiver contains the given statement.
	@param aStatement A complete statement
	@discussion May not work in all cases; use enumeratorOfStatementsLike: instead.
*/
- (BOOL)containsStatement:(RedlandStatement *)aStatement;

/*! 
	@method removeStatement:
	@abstract Removes a single statement from the receiver. 
	@param aStatement A complete statement
    @result TRUE on success
*/
- (BOOL)removeStatement:(RedlandStatement *)aStatement;

/*! 
	@method removeStatement:withContext:
	@abstract Removes a single statement with the given context from the receiver.
	@param aStatement A complete statement
	@param contextNode The context of the statement to remove
    @result TRUE on success
*/
- (BOOL)removeStatement:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode;

/*! 
	@method removeAllStatementsWithContext:
	@abstract Removes all statements with the given context from the receiver.
	@param contextNode The context of the statements to remove
*/
- (void)removeAllStatementsWithContext:(RedlandNode *)contextNode;

/*! 
	@method streamOfStatementsLike:
	@abstract Returns a RedlandStream of all statements matching the given statement.
	@param aStatement A (possibly partial) statement
*/
- (RedlandStream *)streamOfStatementsLike:(RedlandStatement *)aStatement;

/*!
	@method streamOfStatementsLike:withContext:
	@abstract Returns a RedlandStream of statements matching the given statement and context.
	@param aStatement A (possibly partial) statement
	@param contextNode The context
*/
- (RedlandStream *)streamOfStatementsLike:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode;

/*! 
	@method streamOfAllStatementsWithContext:
	@abstract Returns a stream of all statements with the given context.
	@param contextNode The context to stream
*/
- (RedlandStream *)streamOfAllStatementsWithContext:(RedlandNode *)contextNode;

/*! Use -[RedlandModel enumeratorOfSourcesWithArc:target:] instead. */
- (RedlandIterator *)iteratorOfSourcesWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode;
/*! Use -[RedlandModel enumeratorOfArcsWithSource:target:] instead. */
- (RedlandIterator *)iteratorOfArcsWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode;
/*! Use -[RedlandModel enumeratorOfTargetsWithSource:arc:] instead. */
- (RedlandIterator *)iteratorOfTargetsWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode;
/*! Use -[RedlandModel enumeratorOfArcsIn:] instead. */
- (RedlandIterator *)iteratorOfArcsIn:(RedlandNode *)targetNode;
/*! Use -[RedlandModel enumeratorOfArcsOut:] instead. */
- (RedlandIterator *)iteratorOfArcsOut:(RedlandNode *)sourceNode;
/*! Use -[RedlandModel contextEnumerator] instead. */
- (RedlandIterator *)contextIterator;

/*! 
	@method sourceWithArc:target:
	@abstract Returns one matching source in the receiver for the given arcNode and targetNode.
	@param arcNode The arc (or predicate)
	@param targetNode The target (or object)
*/
- (RedlandNode *)sourceWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode;

/*! @method arcWithSource:target:
	@abstract Returns one matching arc in the receiver for the given sourceNode and targetNode.
	@param sourceNode The source (or subject)
	@param targetNode The target (or object)
*/
- (RedlandNode *)arcWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode;

/*! @method targetWithSource:arc:
	@abstract Returns one matching target in the receiver for the given sourceNode and arcNode.
	@param sourceNode The source (or subject)
	@param arcNode The arc (or predicate)
*/
- (RedlandNode *)targetWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode;

/*!
	@method node:hasIncomingArc:
	@abstract Returns YES if targetNode has at least one incoming arc arcNode.
	@param arcNode The arc (or predicate)
*/
- (BOOL)node:(RedlandNode *)targetNode hasIncomingArc:(RedlandNode *)arcNode;

/*! 
	@method node:hasOutgoingArc:
	@abstract Returns YES if sourceNode has at least one outgoing arc arcNode.
	@param arcNode The arc (or predicate)
*/
- (BOOL)node:(RedlandNode *)sourceNode hasOutgoingArc:(RedlandNode *)arcNode;

/*!
	@method statementStream
	@abstract Returns a stream of all statements in the receiver.
*/
- (RedlandStream *)statementStream;

/*!
    @method valueOfFeature:
    @abstract Returns the value of the model feature identified by featureURI.
    @param featureURI An NSString or a RedlandURI instance
*/
- (RedlandNode *)valueOfFeature:(id)featureURI;

/*!
    @method setValue:ofFeature:
	@abstract Sets the model feature identified by featureURI to a new value.
	@param featureValue A RedlandNode representing the new value
	@param featureURI An NSString or a RedlandURI instance
	@discussion Raises a RedlandException is no such feature exists.
*/
- (void)setValue:(RedlandNode *)featureValue ofFeature:(id)featureURI;

/*!
    @method containsContext:
    @abstract Check for a context in the model.
    @param aContext A RedlandNode representing the context
    @result TRUE if the model does contain the specified context
*/
- (BOOL)containsContext:(RedlandNode *)contextNode;
@end
