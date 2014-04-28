//
//  RedlandStatement.m
//  Redland Objective-C Bindings
//  $Id: RedlandStatement.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandStatement.h"

#import "RedlandWorld.h"
#import "RedlandNode.h"
#import "RedlandNode-Convenience.h"
#import "RedlandNamespace.h"


@implementation RedlandStatement

@dynamic subject, predicate, object;


#pragma mark - Init and Cleanup
/**
 *  Convenience method which returns an autoreleased statement initialized using the designated initializer.
 *  @param subjectNode The subject for the statement
 *  @param predicateNode The predicate
 *  @param objectNode The object
 */
+ (RedlandStatement *)statementWithSubject:(id)subjectNode predicate:(id)predicateNode object:(id)objectNode
{
	return [[self alloc] initWithSubject:subjectNode predicate:predicateNode object:objectNode];
}

/**
 *  The designated initializer, initializes a new RedlandStatement.
 *
 *  Each parameter can be either be nil, of type RedlandNode, or of any other class that responds to the selector <tt>nodeValue</tt>. The Redland Objective-C
 *  framework provides additional <tt>nodeValue</tt> methods for the core Cocoa classes NSString, NSNumber, NSURL, and NSDate.
 *  
 *  @param subjectNode An object representing the subject or source of the statement.
 *  @param predicateNode An object representing the predicate or arc of the statement.
 *  @param objectNode An object representing the object or target of the statement.
 */
- (id)initWithSubject:(id)subjectNode predicate:(id)predicateNode object:(id)objectNode
{
	// prepare the nodes
	if (subjectNode != nil) {
		subjectNode = [RedlandNode nodeWithObject:subjectNode];
	}
	if (predicateNode != nil) {
		predicateNode = [RedlandNode nodeWithObject:predicateNode];
	}
	if (objectNode != nil) {
		objectNode = [RedlandNode nodeWithObject:objectNode];
	}
	
	// copy the nodes, as they will be owned by the new statement
	librdf_node *subject = subjectNode ? librdf_new_node_from_node([subjectNode wrappedNode]) : NULL;
	librdf_node *predicate = predicateNode ? librdf_new_node_from_node([predicateNode wrappedNode]) : NULL;
	librdf_node *object = objectNode ? librdf_new_node_from_node([objectNode wrappedNode]) : NULL;
	
	librdf_statement *newStatement = librdf_new_statement_from_nodes([RedlandWorld defaultWrappedWorld], subject, predicate, object);
	
	return [self initWithWrappedObject:newStatement];
}

- (void)dealloc
{
	if (isWrappedObjectOwner) {
		librdf_free_statement(wrappedObject);
	}
}



#pragma mark - Accessors

/**
 *  @return Returns the underlying librdf_statement pointer of the receiver.
 */
- (librdf_statement *)wrappedStatement
{
	return wrappedObject;
}

- (RedlandNode *)subject
{
	/// @todo is it a good idea to cache these in an ivar?
	librdf_node *node = librdf_statement_get_subject(wrappedObject);
	if (node) {
		node = librdf_new_node_from_node(node);
	}
	return [[RedlandNode alloc] initWithWrappedObject:node];
}

- (RedlandNode *)predicate
{
	librdf_node *node = librdf_statement_get_predicate(wrappedObject);
	if (node) {
		node = librdf_new_node_from_node(node);
	}
	return [[RedlandNode alloc] initWithWrappedObject:node];
}

- (RedlandNode *)object
{
	librdf_node *node = librdf_statement_get_object(wrappedObject);
	if (node) {
		node = librdf_new_node_from_node(node);
	}
	return [[RedlandNode alloc] initWithWrappedObject:node];
}

/**
 *  @return Returns YES if the receiver has all non-nil subject, predicate, and object parts.
 */
- (BOOL)isComplete
{
	return librdf_statement_is_complete(wrappedObject);
}



#pragma mark - Comparing
/**
 *  @param aStatement The statement to compare the receiver to.
 *  @warning All parts of aStatement which are non-nil must be equal to their counterparts in the receiver.
 *  @return Returns YES if the receiver matches aStatement.
 */
- (BOOL)matchesPartialStatement:(RedlandStatement *)aStatement
{
	NSParameterAssert(aStatement != nil);
	return librdf_statement_match(wrappedObject, [aStatement wrappedStatement]);
}

- (BOOL)isEqualToStatement:(RedlandStatement *)aStatement
{
	if (aStatement == nil) {
		return NO;
	}
	return librdf_statement_equals(wrappedObject, [aStatement wrappedStatement]);
}

- (BOOL)isEqual:(id)otherStatement
{
	if ([otherStatement isKindOfClass:[self class]]) {
		return [self isEqualToStatement:otherStatement];
	}
	return NO;
}

- (NSUInteger)hash
{
	return (NSUInteger)wrappedObject;
}



#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)aZone
{
	librdf_statement *copy;
	copy = librdf_new_statement_from_statement(wrappedObject);
	return [[[self class] alloc] initWithWrappedObject:copy];
}



#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)coder
{
	NSParameterAssert(coder != nil);
	
	unsigned char const *buffer;
	NSUInteger bufSize;
	if ([coder allowsKeyedCoding]) {
		buffer = [coder decodeBytesForKey:@"encodedBytes" returnedLength:&bufSize];
	}
	else {
		buffer = [coder decodeBytesWithReturnedLength:&bufSize];
	}
	
	librdf_world *myWorld = [RedlandWorld defaultWrappedWorld];
	librdf_statement *statement = librdf_new_statement(myWorld);
	if (0 == librdf_statement_decode2(myWorld, statement, NULL, (unsigned char*) buffer, bufSize)) {
		librdf_free_statement(statement);
		@throw [NSException exceptionWithName:NSInternalInconsistencyException
									   reason:@"librdf_statement_decode2 returned zero"
									 userInfo:nil];
	}
	
	self = [super initWithWrappedObject:statement];
	if (self == nil) {
		librdf_free_statement(statement);
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	NSParameterAssert(coder != nil);
	
	librdf_world *myWorld = [RedlandWorld defaultWrappedWorld];
	unsigned char *buffer;
	size_t bufSize = librdf_statement_encode2(myWorld, wrappedObject, NULL, 0);
	@try {
		buffer = malloc(bufSize);
		if (buffer == NULL) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException
										   reason:[NSString stringWithFormat:@"Failed to allocate buffer of %zu bytes for librdf_statement_encode", bufSize]
										 userInfo:nil];
		}
		bufSize = librdf_statement_encode2(myWorld, wrappedObject, buffer, bufSize);
		if (bufSize == 0) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException
										   reason:@"librdf_statement_encode returned zero"
										 userInfo:nil];
		}
		
		if ([coder allowsKeyedCoding]) {
			[coder encodeBytes:buffer length:bufSize forKey:@"encodedBytes"];
		}
		else {
			[coder encodeBytes:buffer length:bufSize];
		}
	}
	@finally {
		free(buffer);
	}
}



#pragma mark - Descriptions
- (NSString *)description
{
	librdf_statement *stmt = wrappedObject;
	unsigned char *outString;
	
	// write to a stream
	raptor_iostream *stream = raptor_new_iostream_to_string(stmt->world, (void**)&outString, NULL, malloc);
	int ret = librdf_statement_write(stmt, stream);
	raptor_free_iostream(stream);
	if (0 != ret) {
		raptor_free_memory(outString);
		outString = NULL;
	}
	
	// return as NSString
	if (outString) {
		return [NSString stringWithCString:(const char *)outString encoding:NSUTF8StringEncoding];
	}
	
	DLog(@"xxx>  FAILED to write to librdf_statement");
	return [super description];
}


@end
