//
//  RedlandNode.m
//  Redland Objective-C Bindings
//  $Id: RedlandNode.m 4 2004-09-25 15:49:17Z kianga $
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

// For some strange reason, NSBadComparisonException is defined in an AppKit
// instead of Foundation...
#import <AppKit/NSErrors.h> 

#import "RedlandNode.h"

#import "RedlandWorld.h"
#import "RedlandURI.h"
#import "RedlandNamespace.h"
#import "RedlandException.h"

@implementation RedlandNode

#pragma mark Convenience Initializers

+ (id)nodeWithLiteral:(NSString *)aString
{
	NSParameterAssert(aString != nil);
    return [self nodeWithLiteral:aString language:nil isXML:NO];
}

+ (id)nodeWithLiteral:(NSString *)aString language:(NSString *)aLanguage isXML:(BOOL)xmlFlag
{
	return [[[self alloc] initWithLiteral:aString language:aLanguage isXML:xmlFlag] autorelease];
}

+ (id)nodeWithLiteral:(NSString *)aString language:(NSString *)aLanguage type:(RedlandURI *)typeURI
{
    return [[[self alloc] initWithLiteral:aString language:aLanguage type:typeURI] autorelease];
}

+ (id)nodeWithURIString:(NSString *)aString
{
	NSParameterAssert(aString != nil);
	return [[[self alloc] initWithURIString:aString] autorelease];
}

+ (id)nodeWithBlankID:(NSString *)anID
{
	return [[[self alloc] initWithBlankID:anID] autorelease];
}

+ (id)nodeWithURI:(RedlandURI *)aURI
{
	NSParameterAssert(aURI != nil);
	return [[[self alloc] initWithURI:aURI] autorelease];
}

#pragma mark Init and Cleanup

- (id)initWithLiteral:(NSString *)aString language:(NSString *)aLanguage isXML:(BOOL)xmlFlag
{
    librdf_node *newNode;
	NSParameterAssert(aString != nil);
    newNode = librdf_new_node_from_literal([RedlandWorld defaultWrappedWorld], 
                                           (unsigned char *)[aString UTF8String], 
                                           [aLanguage UTF8String],
                                           xmlFlag);
    return [self initWithWrappedObject:newNode];
}


- (id)initWithLiteral:(NSString *)aString language:(NSString *)aLanguage type:(RedlandURI *)typeURI
{
    librdf_node *newNode;
	NSParameterAssert(aString != nil);
    newNode = librdf_new_node_from_typed_literal([RedlandWorld defaultWrappedWorld], 
                                                 (unsigned char *)[aString UTF8String], 
                                                 [aLanguage UTF8String],
                                                 [typeURI wrappedURI]);
    return [self initWithWrappedObject:newNode];
}

- (id)initWithURIString:(NSString *)aString
{
    librdf_node *newNode;
	NSParameterAssert(aString != nil);
    newNode = librdf_new_node_from_uri_string([RedlandWorld defaultWrappedWorld], 
                                              (unsigned char *)[aString UTF8String]);
    return [self initWithWrappedObject:newNode];
}

- (id)initWithBlankID:(NSString *)anID
{
    librdf_node *newNode;
    newNode = librdf_new_node_from_blank_identifier([RedlandWorld defaultWrappedWorld], (unsigned char *)[anID UTF8String]);
    return [self initWithWrappedObject:newNode];
}

- (id)initWithURI:(RedlandURI *)aURI
{
    librdf_node *newNode;
	NSParameterAssert(aURI != nil);
    newNode = librdf_new_node_from_uri([RedlandWorld defaultWrappedWorld], [aURI wrappedURI]);
    return [self initWithWrappedObject:newNode];
}

- (void)dealloc
{
    if (isWrappedObjectOwner)
        librdf_free_node(wrappedObject);
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)aZone
{
    librdf_node *copy;
    copy = librdf_new_node_from_node(wrappedObject);
    return [[isa alloc] initWithWrappedObject:copy];
}

#pragma mark Coding

- (id)initWithCoder:(NSCoder *)coder
{
    unsigned char const *buffer;
    unsigned int bufSize;
    librdf_node *node;
    NSParameterAssert(coder != nil);
    
    if ([coder allowsKeyedCoding])
        buffer = [coder decodeBytesForKey:@"encodedBytes" returnedLength:&bufSize];
    else
        buffer = [coder decodeBytesWithReturnedLength:&bufSize];
    node = librdf_node_decode([RedlandWorld defaultWrappedWorld],
                              NULL,
                              (unsigned char *)buffer,
                              bufSize);
    if (node == NULL) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"librdf_node_decode returned NULL"
                                     userInfo:nil];
    }
    
    self = [super initWithWrappedObject:node];
    if (self == nil) {
        librdf_free_node(node);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    unsigned char *buffer = NULL;
    unsigned int bufSize;
	NSParameterAssert(coder != nil);
    
    bufSize = librdf_node_encode(wrappedObject, NULL, 0);
    @try {
        buffer = malloc(bufSize);
        if (buffer == NULL) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:@"Failed to allocate buffer of %u bytes for librdf_node_encode", bufSize]
                                         userInfo:nil];
        }
        bufSize = librdf_node_encode(wrappedObject, buffer, bufSize);
        if (bufSize == 0) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"librdf_node_encode returned zero"
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

- (NSString *)description
{
    size_t length;
    unsigned char *node_string = librdf_node_to_counted_string(wrappedObject, &length);
    return [[[NSString alloc] initWithBytesNoCopy:node_string length:length encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
}

#pragma mark Comparing Nodes

- (BOOL)isEqualToNode:(RedlandNode *)aNode
{
    if (aNode == nil)
        return NO;
    return librdf_node_equals(wrappedObject, [aNode wrappedNode]);
}

- (BOOL)isEqual:(id)otherNode
{
    if ([otherNode isKindOfClass:isa])
        return [self isEqualToNode:otherNode];
    else
        return NO;
}

- (unsigned)hash
{
    return (unsigned)wrappedObject;
}

- (NSComparisonResult)compare:(id)otherNode
{
    if (![otherNode isKindOfClass:[self class]]) {
        @throw [NSException exceptionWithName:NSBadComparisonException
                                       reason:[NSString stringWithFormat: @"Cannot compare %@ to %@", [self class], [otherNode class]]
                                     userInfo:nil];
    }
    return [[self description] compare:[otherNode description]];
}

#pragma mark Accessors

- (librdf_node *)wrappedNode
{
    return wrappedObject;
}

- (librdf_node_type)type
{
    return librdf_node_get_type(wrappedObject);
}

- (BOOL)isLiteral
{
    return librdf_node_is_literal(wrappedObject);
}

- (BOOL)isResource
{
    return librdf_node_is_resource(wrappedObject);
}

- (BOOL)isBlank
{
    return librdf_node_is_blank(wrappedObject);
}

- (BOOL)isXML
{
    return librdf_node_get_literal_value_is_wf_xml(wrappedObject);
}

- (NSString *)literalValue
{
    size_t length;
    unsigned char *literal_value;
    
    literal_value = librdf_node_get_literal_value_as_counted_string(wrappedObject, &length);
    return [[[NSString alloc] initWithBytes:literal_value length:length encoding:NSUTF8StringEncoding] autorelease];
}

- (RedlandURI *)URIValue
{
    librdf_uri *uri_value;
	uri_value = librdf_node_get_uri(wrappedObject);
	if (uri_value != NULL)
		uri_value = librdf_new_uri_from_uri(uri_value);
    return [[[RedlandURI alloc] initWithWrappedObject:uri_value] autorelease];
}

- (NSString *)blankID
{
    char *blank_id = (char *)librdf_node_get_blank_identifier(wrappedObject);
    return [[[NSString alloc] initWithUTF8String:blank_id] autorelease];
}

- (int)ordinalValue
{
    return librdf_node_get_li_ordinal(wrappedObject);
}

- (RedlandURI *)literalDataType
{
    librdf_uri *uri_value;
    uri_value = librdf_node_get_literal_value_datatype_uri(wrappedObject);
    if (uri_value != NULL) {
        uri_value = librdf_new_uri_from_uri(uri_value);
        return [[[RedlandURI alloc] initWithWrappedObject:uri_value] autorelease];
    }
    else return nil;
}

- (NSString *)literalLanguage
{
    char *language = librdf_node_get_literal_value_language(wrappedObject);
    if (language)
        return [[[NSString alloc] initWithUTF8String:language] autorelease];
    else
        return nil;
}

@end

