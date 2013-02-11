//
//  RedlandModel.m
//  Redland Objective-C Bindings
//  $Id: RedlandModel.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandModel.h"
#import "RedlandWorld.h"
#import "RedlandStorage.h"
#import "RedlandStream.h"
#import "RedlandStatement.h"
#import "RedlandNode.h"
#import "RedlandIterator.h"
#import "RedlandIteratorEnumerator.h"
#import "RedlandStreamEnumerator.h"
#import "RedlandURI.h"
#import "RedlandParser.h"
#import "RedlandSerializer.h"
#import "RedlandModel-Convenience.h"
#import "RedlandException.h"

@implementation RedlandModel


+ (id)modelWithStorage:(RedlandStorage *)aStorage
{
	return [[self alloc] initWithStorage:aStorage];
}


- (id)init
{
	return [self initWithStorage:[RedlandStorage new]];
}


/**
 *  Initialises a new RedlandModel using the given storage.
 *  @param aStorage The storage to use for the new model
 */
- (id)initWithStorage:(RedlandStorage *)aStorage
{
	NSParameterAssert(aStorage != nil);

	librdf_model *model = librdf_new_model([RedlandWorld defaultWrappedWorld],
										   [aStorage wrappedStorage],
										   NULL);
	self = [super initWithWrappedObject:model];
	if (self == nil) {
		librdf_free_model(model);
	}
	return self;
}

- (void)dealloc
{
	if (isWrappedObjectOwner) {
		librdf_free_model(wrappedObject);
	}
}

/**
 *  Returns the underlying librdf_model pointer of the receiver.
 */
- (librdf_model *)wrappedModel
{
	return wrappedObject;
}

/**
 *  Returns the underlying RedlandStorage of the receiver.
 */
- (RedlandStorage *)storage
{
	librdf_storage *storage = librdf_model_get_storage(wrappedObject);
	return [[RedlandStorage alloc] initWithWrappedObject:storage owner:NO];
}

/**
 *  Synchronises the model to the model implementation.
 */
- (void)sync
{
	librdf_model_sync(wrappedObject);
}

/**
 *  Returns the number of statements in the receiver.
 *  @return The number of statements in the model, or a negative value on failure.
 *  @warning Not all stores support this function. If you absolutely need an accurate size, you can enumerate the statements manually.
 */
- (int)size
{
	return librdf_model_size(wrappedObject);
}



#pragma mark - Statement Handling
/**
 *  Adds a single statement to the receiver.
 *  Duplicate statements are ignored.
 *  @param aStatement A complete statement (with non-nil subject, predicate, and object)
 */
- (void)addStatement:(RedlandStatement *)aStatement
{
	librdf_statement *statement;
	NSParameterAssert(aStatement != nil);
	statement = librdf_new_statement_from_statement([aStatement wrappedStatement]);
	if (statement == NULL) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"unable to copy statement"
										  userInfo:@{ @"statement": aStatement, @"model": self }];
	}
	if (librdf_model_add_statement(wrappedObject, statement) != 0) {
		librdf_free_statement(statement);
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_model_add_statement failed"
										  userInfo:@{ @"statement": aStatement, @"model": self }];
	}
}

/**
 *  Adds a stream of statements to the receiver.
 *  Duplicate statements are ignored.
 *  @param aStream A stream of complete statements
 */
- (void)addStatementsFromStream:(RedlandStream *)aStream
{
	NSParameterAssert(aStream != nil);
	if (librdf_model_add_statements(wrappedObject, [aStream wrappedStream]) != 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_model_add_statements failed"
										  userInfo:nil];
	}
}

/**
 *  Adds a single statement to the receiver with the given context.
 *  @param aStatement A complete statement
 *  @param contextNode The context to associate this statement with
 */
- (void)addStatement:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode
{
	librdf_statement *statement;
	NSParameterAssert(aStatement != nil);
	statement = librdf_new_statement_from_statement([aStatement wrappedStatement]);
	if (librdf_model_context_add_statement(wrappedObject,
										   [contextNode wrappedNode],
										   statement) != 0) {
		librdf_free_statement(statement);
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_model_context_add_statement failed"
										  userInfo:nil];
	}
}

/**
 *  Adds a stream of statements to the receiver in the given context.
 *  @param aStream A stream of complete statements
 *  @param contextNode The context to associate each statement with
 */
- (void)addStatementsFromStream:(RedlandStream *)aStream withContext:(RedlandNode *)contextNode
{
	NSParameterAssert(aStream != nil);
	if (librdf_model_context_add_statements(wrappedObject, [contextNode wrappedNode], [aStream wrappedStream]) != 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_model_context_add_statements failed"
										  userInfo:nil];
	}
}

/**
 *  Returns YES if the receiver contains the given statement.
 *  @param aStatement A complete statement
 *  @warning May not work in all cases; use enumeratorOfStatementsLike: instead.
 */
- (BOOL)containsStatement:(RedlandStatement *)aStatement
{
	NSParameterAssert(aStatement != nil);
	return librdf_model_contains_statement(wrappedObject, [aStatement wrappedStatement]);
}

/**
 *  Removes a single statement from the receiver.
 *  @param aStatement A complete statement
 *  @return YES on success
 */
- (BOOL)removeStatement:(RedlandStatement *)aStatement
{
	NSParameterAssert(aStatement != nil);
	
	return (0 == librdf_model_remove_statement(wrappedObject, [aStatement wrappedStatement]));
}

/**
 *  Removes a single statement with the given context from the receiver.
 *  @param aStatement A complete statement
 *  @param contextNode The context of the statement to remove
 *  @return YES on success
 */
- (BOOL)removeStatement:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode
{
	NSParameterAssert(aStatement != nil);
	
	int result = librdf_model_context_remove_statement(wrappedObject,
													   [contextNode wrappedNode],
													   [aStatement wrappedStatement]);
	return (0 == result);
}

/**
 *  Removes all statements with the given context from the receiver.
 *  @param contextNode The context of the statements to remove
 */
- (void)removeAllStatementsWithContext:(RedlandNode *)contextNode
{
	NSParameterAssert(contextNode != nil);
	if (librdf_model_context_remove_statements(wrappedObject, [contextNode wrappedNode]) != 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_model_context_remove_statements failed"
										  userInfo:nil];
	}
}



#pragma mark - Stream Retrieval
/**
 *  Returns a RedlandStream of all statements matching the given statement.
 *  @param aStatement A (possibly partial) statement
 */
- (RedlandStream *)streamOfStatementsLike:(RedlandStatement *)aStatement
{
	NSParameterAssert(aStatement != nil);
	
	librdf_stream *stream = librdf_model_find_statements(wrappedObject, [aStatement wrappedStatement]);
	return [[RedlandStream alloc] initWithWrappedObject:stream];
}

/**
 *  Returns a RedlandStream of statements matching the given statement and context.
 *  @param aStatement A (possibly partial) statement
 *  @param contextNode The context
 */
- (RedlandStream *)streamOfStatementsLike:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode
{
	NSParameterAssert(aStatement != nil);
	
	librdf_stream *stream = librdf_model_find_statements_in_context(wrappedObject,
													 [aStatement wrappedStatement],
													 [contextNode wrappedNode]);
	return [[RedlandStream alloc] initWithWrappedObject:stream];
}

/**
 *  Returns a stream of all statements with the given context.
 *  @param contextNode The context to stream
 */
- (RedlandStream *)streamOfAllStatementsWithContext:(RedlandNode *)contextNode
{
	NSParameterAssert(contextNode != nil);
	
	librdf_stream *stream = librdf_model_context_as_stream(wrappedObject, [contextNode wrappedNode]);
	return [[RedlandStream alloc] initWithWrappedObject:stream];
}



#pragma mark - Iterators
- (RedlandIterator *)iteratorOfSourcesWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode
{
	NSParameterAssert(arcNode != nil);
	NSParameterAssert(targetNode != nil);
	
	librdf_iterator *iterator = librdf_model_get_sources(wrappedObject, [arcNode wrappedNode], [targetNode wrappedNode]);
	return [[RedlandIterator alloc] initWithWrappedObject:iterator];
}

- (RedlandIterator *)iteratorOfArcsWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode
{
	NSParameterAssert(sourceNode != nil);
	NSParameterAssert(targetNode != nil);
	
	librdf_iterator *iterator = librdf_model_get_arcs(wrappedObject, [sourceNode wrappedNode], [targetNode wrappedNode]);
	return [[RedlandIterator alloc] initWithWrappedObject:iterator];
}

- (RedlandIterator *)iteratorOfTargetsWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode
{
	NSParameterAssert(sourceNode != nil);
	NSParameterAssert(arcNode != nil);
	
	librdf_iterator *iterator = librdf_model_get_targets(wrappedObject, [sourceNode wrappedNode], [arcNode wrappedNode]);
	return [[RedlandIterator alloc] initWithWrappedObject:iterator];
}

- (RedlandIterator *)iteratorOfArcsIn:(RedlandNode *)targetNode
{
	NSParameterAssert(targetNode != nil);
	
	librdf_iterator *iterator = librdf_model_get_arcs_in(wrappedObject, [targetNode wrappedNode]);
	return [[RedlandIterator alloc] initWithWrappedObject:iterator];
}

- (RedlandIterator *)iteratorOfArcsOut:(RedlandNode *)sourceNode
{
	NSParameterAssert(sourceNode != nil);
	
	librdf_iterator *iterator = librdf_model_get_arcs_out(wrappedObject, [sourceNode wrappedNode]);
	return [[RedlandIterator alloc] initWithWrappedObject:iterator];
}


- (RedlandIterator *)contextIterator
{
	librdf_iterator *iterator = librdf_model_get_contexts(wrappedObject);
	return [[RedlandIterator alloc] initWithWrappedObject:iterator];
}



#pragma mark - Sources, Arcs and Targets
/**
 *  Returns one matching source in the receiver for the given arcNode and targetNode.
 *  @param arcNode The arc (or predicate)
 *  @param targetNode The target (or object)
 */
- (RedlandNode *)sourceWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode
{
	NSParameterAssert(arcNode != nil);
	NSParameterAssert(targetNode != nil);
	
	librdf_node *node = librdf_model_get_source(wrappedObject, [arcNode wrappedNode], [targetNode wrappedNode]);
	if (node) {
		node = librdf_new_node_from_node(node);
	}
	return [[RedlandNode alloc] initWithWrappedObject:node];
}

/**
 *  Returns one matching arc in the receiver for the given sourceNode and targetNode.
 *  @param sourceNode The source (or subject)
 *  @param targetNode The target (or object)
 */
- (RedlandNode *)arcWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode
{
	NSParameterAssert(sourceNode != nil);
	NSParameterAssert(targetNode != nil);
	
	librdf_node *node = librdf_model_get_arc(wrappedObject, [sourceNode wrappedNode], [targetNode wrappedNode]);
	if (node) {
		node = librdf_new_node_from_node(node);
	}
	return [[RedlandNode alloc] initWithWrappedObject:node];
}

/**
 *  Returns one matching target in the receiver for the given sourceNode and arcNode.
 *  @param sourceNode The source (or subject)
 *  @param arcNode The arc (or predicate)
 */
- (RedlandNode *)targetWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode
{
	NSParameterAssert(sourceNode != nil);
	NSParameterAssert(arcNode != nil);
	
	librdf_node *node = librdf_model_get_target(wrappedObject, [sourceNode wrappedNode], [arcNode wrappedNode]);
	if (node) {
		node = librdf_new_node_from_node(node);
	}
	return [[RedlandNode alloc] initWithWrappedObject:node];
}


/**
 *  Returns YES if targetNode has at least one incoming arc arcNode.
 *  @param targetNode The node to query
 *  @param arcNode The arc (or predicate)
 */
- (BOOL)node:(RedlandNode *)targetNode hasIncomingArc:(RedlandNode *)arcNode
{
	NSParameterAssert(targetNode != nil);
	NSParameterAssert(arcNode != nil);
	
	return librdf_model_has_arc_in(wrappedObject, [targetNode wrappedNode], [arcNode wrappedNode]);
}

/**
 *  Returns YES if sourceNode has at least one outgoing arc arcNode.
 *  @param sourceNode The node to query
 *  @param arcNode The arc (or predicate)
 */
- (BOOL)node:(RedlandNode *)sourceNode hasOutgoingArc:(RedlandNode *)arcNode
{
	NSParameterAssert(sourceNode != nil);
	NSParameterAssert(arcNode != nil);
	
	return librdf_model_has_arc_out(wrappedObject, [sourceNode wrappedNode], [arcNode wrappedNode]);
}



#pragma mark - Stream and Context
/**
 *  Returns a stream of all statements in the receiver.
 */
- (RedlandStream *)statementStream
{
	librdf_stream *stream = librdf_model_as_stream(wrappedObject);
	return [[RedlandStream alloc] initWithWrappedObject:stream];
}

/**
 *  Check for a context in the model.
 *  @param contextNode A RedlandNode representing the context
 *  @return YES if the model does contain the specified context
 */
- (BOOL)containsContext:(RedlandNode *)contextNode
{
	return librdf_model_contains_context(wrappedObject, [contextNode wrappedNode]) != 0;
}



#pragma mark - Features
/**
 *  Returns the value of the model feature identified by featureURI.
 *  @param featureURI An NSString or a RedlandURI instance
 */
- (RedlandNode *)valueOfFeature:(id)featureURI
{
	NSParameterAssert(featureURI != nil);
	
	if ([featureURI isKindOfClass:[NSString class]]) {
		featureURI = [RedlandURI URIWithString:featureURI];
	}
	NSAssert([featureURI isKindOfClass:[RedlandURI class]], @"featureURI has invalid class");
	
	librdf_uri *feature_uri = [featureURI wrappedURI];
	librdf_node *feature_value = librdf_model_get_feature(wrappedObject, feature_uri);
	
	return [[RedlandNode alloc] initWithWrappedObject:feature_value];
}

/**
 *  Sets the model feature identified by featureURI to a new value.
 *  @param featureValue A RedlandNode representing the new value
 *  @param featureURI An NSString or a RedlandURI instance
 *  @warning Raises a RedlandException is no such feature exists.
 */
- (void)setValue:(RedlandNode *)featureValue ofFeature:(id)featureURI
{
	NSParameterAssert(featureURI != nil);
	
	if ([featureURI isKindOfClass:[NSString class]]) {
		featureURI = [RedlandURI URIWithString:featureURI];
	}
	NSAssert([featureURI isKindOfClass:[RedlandURI class]], @"featureURI has invalid class");
	
	int result = librdf_model_set_feature(wrappedObject,
										  [featureURI wrappedURI],
										  [featureValue wrappedNode]);
	if (result > 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_model_set_feature returned >0"
										  userInfo:nil];
	}
	else if (result < 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"No such feature"
										  userInfo:nil];
	}
}


@end
