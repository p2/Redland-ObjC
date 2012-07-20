//
//  RedlandStatement.m
//  Redland Objective-C Bindings
//  $Id: RedlandStatement.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandStatement.h"

#import "RedlandWorld.h"
#import "RedlandNode.h"
#import "RedlandNode-Convenience.h"
#import "RedlandNamespace.h"

@implementation RedlandStatement

#pragma mark Init and Cleanup

+ (RedlandStatement *)statementWithSubject:(id)subjectNode 
                                 predicate:(id)predicateNode 
                                    object:(id)objectNode
{
	return [[[self alloc] initWithSubject:subjectNode predicate:predicateNode object:objectNode] autorelease];
}

- (id)initWithSubject:(id)subjectNode predicate:(id)predicateNode object:(id)objectNode
{
    librdf_statement *newStatement;
    librdf_node *subject, *predicate, *object;
    
    if (subjectNode != nil)
        subjectNode = [RedlandNode nodeWithObject:subjectNode];
    if (predicateNode != nil)
        predicateNode = [RedlandNode nodeWithObject:predicateNode];
    if (objectNode != nil)
        objectNode = [RedlandNode nodeWithObject:objectNode];
    
    // copy the nodes, as they will be owned by the new statement
    subject = subjectNode ? librdf_new_node_from_node([subjectNode wrappedNode]) : NULL;
    predicate = predicateNode ? librdf_new_node_from_node([predicateNode wrappedNode]) : NULL;
    object = objectNode ? librdf_new_node_from_node([objectNode wrappedNode]) : NULL;
    newStatement = librdf_new_statement_from_nodes([RedlandWorld defaultWrappedWorld],
                                                   subject, predicate, object);
    return [self initWithWrappedObject:newStatement];
}

- (void)dealloc
{
    if (isWrappedObjectOwner)
        librdf_free_statement(wrappedObject);
    [super dealloc];
}

#pragma mark Copying

- (id)copyWithZone:(NSZone *)aZone
{
    librdf_statement *copy;
    copy = librdf_new_statement_from_statement(wrappedObject);
    return [[isa alloc] initWithWrappedObject:copy];
}

#pragma mark Archiving

- (id)initWithCoder:(NSCoder *)coder
{
    unsigned char const *buffer;
    unsigned int bufSize;
    librdf_statement *statement;
    
    NSParameterAssert(coder != nil);
    
    if ([coder allowsKeyedCoding])
        buffer = [coder decodeBytesForKey:@"encodedBytes" returnedLength:&bufSize];
    else
        buffer = [coder decodeBytesWithReturnedLength:&bufSize];
    statement = librdf_new_statement([RedlandWorld defaultWrappedWorld]);
    if (librdf_statement_decode(statement, (unsigned char *)buffer, bufSize) == 0) {
        librdf_free_statement(statement);
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"librdf_statement_decode returned zero"
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
    unsigned char *buffer = NULL;
    unsigned int bufSize;
	
	NSParameterAssert(coder != nil);
    
    bufSize = librdf_statement_encode(wrappedObject, NULL, 0);
    @try {
        buffer = malloc(bufSize);
        if (buffer == NULL) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:@"Failed to allocate buffer of %u bytes for librdf_statement_encode", bufSize]
                                         userInfo:nil];
        }
        bufSize = librdf_statement_encode(wrappedObject, buffer, bufSize);
        if (bufSize == 0) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"librdf_statement_encode returned zero"
                                         userInfo:nil];
        }
        
        if ([coder allowsKeyedCoding])
            [coder encodeBytes:buffer length:bufSize forKey:@"encodedBytes"];
        else
            [coder encodeBytes:buffer length:bufSize];
    }
    @finally {
        free(buffer);
    }
}

#pragma mark Descriptions

- (NSString *)description
{
    unsigned char *statement_string = librdf_statement_to_string(wrappedObject);
    return [[[NSString alloc] initWithBytesNoCopy:statement_string length:strlen((char *)statement_string) encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
}

- (void)print
{
    librdf_statement_print(wrappedObject, stderr);
}

#pragma mark Accessors

- (librdf_statement *)wrappedStatement
{
    return wrappedObject;
}

- (RedlandNode *)subject
{
    librdf_node *node = librdf_statement_get_subject(wrappedObject);
	if (node)
		node = librdf_new_node_from_node(node);
    return [[[RedlandNode alloc] initWithWrappedObject:node] autorelease];
}

- (RedlandNode *)predicate
{
    librdf_node *node = librdf_statement_get_predicate(wrappedObject);
	if (node)
		node = librdf_new_node_from_node(node);
    return [[[RedlandNode alloc] initWithWrappedObject:node] autorelease];
}

- (RedlandNode *)object
{
    librdf_node *node = librdf_statement_get_object(wrappedObject);
	if (node)
		node = librdf_new_node_from_node(node);
    return [[[RedlandNode alloc] initWithWrappedObject:node] autorelease];
}

- (BOOL)isComplete
{
    return librdf_statement_is_complete(wrappedObject);
}

#pragma mark Comparing

- (BOOL)matchesPartialStatement:(RedlandStatement *)aStatement
{
    NSParameterAssert(aStatement != nil);
    return librdf_statement_match(wrappedObject, [aStatement wrappedStatement]);
}

- (BOOL)isEqualToStatement:(RedlandStatement *)aStatement
{
    if (aStatement == nil)
        return NO;
    return librdf_statement_equals(wrappedObject, [aStatement wrappedStatement]);
}

- (BOOL)isEqual:(id)otherStatement
{
    if ([otherStatement isKindOfClass:[self class]])
        return [self isEqualToStatement:otherStatement];
    else
        return NO;
}

- (unsigned int)hash
{
    // FIXME: This is very, very inefficient.
    return [[self description] hash];
}

@end
