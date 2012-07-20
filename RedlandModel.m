//
//  RedlandModel.m
//  Redland Objective-C Bindings
//  $Id: RedlandModel.m 4 2004-09-25 15:49:17Z kianga $
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

+ (RedlandModel *)model
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    return [self initWithStorage:[RedlandStorage storage]];
}

- (id)initWithStorage:(RedlandStorage *)aStorage
{
    librdf_model *model;

    NSParameterAssert(aStorage != nil);
    
    model = librdf_new_model([RedlandWorld defaultWrappedWorld],
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
    if (isWrappedObjectOwner)
        librdf_free_model(wrappedObject);
    [super dealloc];
}

- (librdf_model *)wrappedModel
{
    return wrappedObject;
}

- (RedlandStorage *)storage
{
    librdf_storage *storage;
    storage = librdf_model_get_storage(wrappedObject);
    return [[[RedlandStorage alloc] initWithWrappedObject:storage owner:NO] autorelease];
}

- (void)print
{
    librdf_model_print(wrappedObject, stderr);
}

- (void)sync
{
    librdf_model_sync(wrappedObject);
}

- (int)size
{
    return librdf_model_size(wrappedObject);
}

- (void)addStatement:(RedlandStatement *)aStatement
{
    librdf_statement *statement;
    NSParameterAssert(aStatement != nil);
    statement = librdf_new_statement_from_statement([aStatement wrappedStatement]);
	if (statement == NULL) {
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
			aStatement, @"statement",
			self, @"model",
			nil];
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"unable to copy statement"
										  userInfo:errorDict];
	}
    if (librdf_model_add_statement(wrappedObject, statement) != 0) {
        librdf_free_statement(statement);
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
			aStatement, @"statement",
			self, @"model",
			nil];
        @throw [RedlandException exceptionWithName:RedlandExceptionName
                                            reason:@"librdf_model_add_statement failed"
                                          userInfo:errorDict];
    }
}

- (void)addStatementsFromStream:(RedlandStream *)aStream
{
    NSParameterAssert(aStream != nil);
    if (librdf_model_add_statements(wrappedObject, [aStream wrappedStream]) != 0) {
        @throw [RedlandException exceptionWithName:RedlandExceptionName
                                            reason:@"librdf_model_add_statements failed"
                                          userInfo:nil];
    }
}

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

- (void)addStatementsFromStream:(RedlandStream *)aStream withContext:(RedlandNode *)contextNode
{
    NSParameterAssert(aStream != nil);
    if (librdf_model_context_add_statements(wrappedObject, [contextNode wrappedNode], [aStream wrappedStream]) != 0) {
        @throw [RedlandException exceptionWithName:RedlandExceptionName
                                            reason:@"librdf_model_context_add_statements failed"
                                          userInfo:nil];
    }
}

- (BOOL)containsStatement:(RedlandStatement *)aStatement
{
    NSParameterAssert(aStatement != nil);
    return librdf_model_contains_statement(wrappedObject, [aStatement wrappedStatement]);
}

- (BOOL)removeStatement:(RedlandStatement *)aStatement
{
	int result;
    NSParameterAssert(aStatement != nil);
	
    result = librdf_model_remove_statement(wrappedObject, [aStatement wrappedStatement]);
	return result == 0;
}

- (BOOL)removeStatement:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode
{
	int result;
    NSParameterAssert(aStatement != nil);
    
	result = librdf_model_context_remove_statement(wrappedObject, 
												   [contextNode wrappedNode], 
												   [aStatement wrappedStatement]);
	return result == 0;
}

- (void)removeAllStatementsWithContext:(RedlandNode *)contextNode
{
    NSParameterAssert(contextNode != nil);
    if (librdf_model_context_remove_statements(wrappedObject, [contextNode wrappedNode]) != 0) {
        @throw [RedlandException exceptionWithName:RedlandExceptionName
                                            reason:@"librdf_model_context_remove_statements failed"
                                          userInfo:nil];
    }
}

- (RedlandStream *)streamOfStatementsLike:(RedlandStatement *)aStatement
{
    librdf_stream *stream;
    NSParameterAssert(aStatement != nil);
    stream = librdf_model_find_statements(wrappedObject, [aStatement wrappedStatement]);
    return [[[RedlandStream alloc] initWithWrappedObject:stream] autorelease];
}

- (RedlandStream *)streamOfAllStatementsWithContext:(RedlandNode *)contextNode
{
    librdf_stream *stream;
    NSParameterAssert(contextNode != nil);
    stream = librdf_model_context_as_stream(wrappedObject, [contextNode wrappedNode]);
    return [[[RedlandStream alloc] initWithWrappedObject:stream] autorelease];
}

- (RedlandStream *)streamOfStatementsLike:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode
{
    librdf_stream *stream;
    NSParameterAssert(aStatement != nil);
    stream = librdf_model_find_statements_in_context(wrappedObject, 
                                                     [aStatement wrappedStatement],
                                                     [contextNode wrappedNode]);
    return [[[RedlandStream alloc] initWithWrappedObject:stream] autorelease];
}

- (RedlandIterator *)iteratorOfSourcesWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode
{
    librdf_iterator *iterator;
    NSParameterAssert(arcNode != nil);
    NSParameterAssert(targetNode != nil);
    iterator = librdf_model_get_sources(wrappedObject, [arcNode wrappedNode], [targetNode wrappedNode]);
    return [[[RedlandIterator alloc] initWithWrappedObject:iterator] autorelease];
}

- (RedlandIterator *)iteratorOfArcsWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode
{
    librdf_iterator *iterator;
    NSParameterAssert(sourceNode != nil);
    NSParameterAssert(targetNode != nil);
    iterator = librdf_model_get_arcs(wrappedObject, [sourceNode wrappedNode], [targetNode wrappedNode]);
    return [[[RedlandIterator alloc] initWithWrappedObject:iterator] autorelease];
}

- (RedlandIterator *)iteratorOfTargetsWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode
{
    librdf_iterator *iterator;
    NSParameterAssert(sourceNode != nil);
    NSParameterAssert(arcNode != nil);
    iterator = librdf_model_get_targets(wrappedObject, [sourceNode wrappedNode], [arcNode wrappedNode]);
    return [[[RedlandIterator alloc] initWithWrappedObject:iterator] autorelease];
}

- (RedlandIterator *)contextIterator
{
    librdf_iterator *iterator = librdf_model_get_contexts(wrappedObject);
    return [[[RedlandIterator alloc] initWithWrappedObject:iterator] autorelease];
}

- (RedlandNode *)sourceWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode
{
    librdf_node *node;
    NSParameterAssert(arcNode != nil);
    NSParameterAssert(targetNode != nil);
    node = librdf_model_get_source(wrappedObject, [arcNode wrappedNode], [targetNode wrappedNode]);
	if (node)
		node = librdf_new_node_from_node(node);
    return [[[RedlandNode alloc] initWithWrappedObject:node] autorelease];
}

- (RedlandNode *)arcWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode
{
    librdf_node *node;
    NSParameterAssert(sourceNode != nil);
    NSParameterAssert(targetNode != nil);
    node = librdf_model_get_arc(wrappedObject, [sourceNode wrappedNode], [targetNode wrappedNode]);
	if (node)
		node = librdf_new_node_from_node(node);
    return [[[RedlandNode alloc] initWithWrappedObject:node] autorelease];
}

- (RedlandNode *)targetWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode
{
    librdf_node *node;
    NSParameterAssert(sourceNode != nil);
    NSParameterAssert(arcNode != nil);
    node = librdf_model_get_target(wrappedObject, [sourceNode wrappedNode], [arcNode wrappedNode]);
	if (node)
		node = librdf_new_node_from_node(node);
    return [[[RedlandNode alloc] initWithWrappedObject:node] autorelease];
}

- (RedlandIterator *)iteratorOfArcsIn:(RedlandNode *)targetNode
{
    librdf_iterator *iterator;
    NSParameterAssert(targetNode != nil);
    iterator = librdf_model_get_arcs_in(wrappedObject, [targetNode wrappedNode]);
    return [[[RedlandIterator alloc] initWithWrappedObject:iterator] autorelease];
}

- (RedlandIterator *)iteratorOfArcsOut:(RedlandNode *)sourceNode
{
    librdf_iterator *iterator;
    NSParameterAssert(sourceNode != nil);
    iterator = librdf_model_get_arcs_out(wrappedObject, [sourceNode wrappedNode]);
    return [[[RedlandIterator alloc] initWithWrappedObject:iterator] autorelease];
}

- (BOOL)node:(RedlandNode *)targetNode hasIncomingArc:(RedlandNode *)arcNode
{
    NSParameterAssert(targetNode != nil);
    NSParameterAssert(arcNode != nil);
    return librdf_model_has_arc_in(wrappedObject, [targetNode wrappedNode], [arcNode wrappedNode]);
}

- (BOOL)node:(RedlandNode *)sourceNode hasOutgoingArc:(RedlandNode *)arcNode
{
    NSParameterAssert(sourceNode != nil);
    NSParameterAssert(arcNode != nil);
    return librdf_model_has_arc_out(wrappedObject, [sourceNode wrappedNode], [arcNode wrappedNode]);
}

- (RedlandStream *)statementStream
{
    librdf_stream *stream;
    stream = librdf_model_as_stream(wrappedObject);
    return [[[RedlandStream alloc] initWithWrappedObject:stream] autorelease];
}

- (BOOL)containsContext:(RedlandNode *)contextNode
{
	return librdf_model_contains_context(wrappedObject, [contextNode wrappedNode]) != 0;
}

#pragma mark Features

- (RedlandNode *)valueOfFeature:(id)featureURI
{
	librdf_node *feature_value;
	librdf_uri *feature_uri;
	NSParameterAssert(featureURI != nil);
	
	if ([featureURI isKindOfClass:[NSString class]])
		featureURI = [RedlandURI URIWithString:featureURI];
	NSAssert([featureURI isKindOfClass:[RedlandURI class]], @"featureURI has invalid class");
	
	feature_uri = [featureURI wrappedURI];
	feature_value = librdf_model_get_feature(wrappedObject, feature_uri);
	
	return [[[RedlandNode alloc] initWithWrappedObject:feature_value] autorelease];
}

- (void)setValue:(RedlandNode *)featureValue ofFeature:(id)featureURI
{
	int result;
	NSParameterAssert(featureURI != nil);
	
	if ([featureURI isKindOfClass:[NSString class]])
		featureURI = [RedlandURI URIWithString:featureURI];
	NSAssert([featureURI isKindOfClass:[RedlandURI class]], @"featureURI has invalid class");
	
	result = librdf_model_set_feature(wrappedObject, 
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
