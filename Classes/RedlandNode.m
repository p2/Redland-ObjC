//
//  RedlandNode.m
//  Redland Objective-C Bindings
//  $Id: RedlandNode.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandNode.h"

#import "RedlandWorld.h"
#import "RedlandURI.h"
#import "RedlandNamespace.h"
#import "RedlandException.h"

#if defined TARGET_OS_IPHONE || defined TARGET_IPHONE_SIMULATOR
#	define NSBadComparisonException @"NSBadComparisonException"
#else
	// For some strange reason, NSBadComparisonException is defined in an AppKit instead of Foundation...
#	import <AppKit/NSErrors.h>
#endif


@implementation RedlandNode

/**
 *  The "init" initializer redirects to "initWithBlankID:" which creates a blank node with a generated id.
 *  @return A RedlandNode of the blank type
 */
- (id)init
{
	return [self initWithBlankID:nil];
}



#pragma mark - Convenience Initializers
/**
 *  @param aString The literal string
 *  @return a RedlandNode of the literal type with the given string value. No language or datatype are specified.
 */
+ (id)nodeWithLiteral:(NSString *)aString
{
	return [[self alloc] initWithLiteral:aString language:nil isXML:NO];
}

/**
 *  @param aString The literal string
 *  @param aLanguage The language of the literal string (will be nil if xmLFlag is YES)
 *  @param xmlFlag If YES, the node is marked as containing well-formed XML data and aLanguage is being ignored
 *  @return a RedlandLiteralNode containing a literal with an an optional language and XML flag.
 */
+ (id)nodeWithLiteral:(NSString *)aString language:(NSString *)aLanguage isXML:(BOOL)xmlFlag
{
	return [[self alloc] initWithLiteral:aString language:aLanguage isXML:xmlFlag];
}

+ (id)nodeWithLiteral:(NSString *)aString language:(NSString *)aLanguage type:(RedlandURI *)typeURI
{
	return [[self alloc] initWithLiteral:aString language:aLanguage type:typeURI];
}


/**
 *  @return an autoreleased RedlandResourceNode representing a resource with the given URI.
 *  @param aURI The URI as a RedlandURI.
 */
+ (id)nodeWithURI:(RedlandURI *)aURI
{
	return [[self alloc] initWithURI:aURI];
}

/**
 *  @param aString The URI as a string value.
 *  @return a RedlandResourceNode representing a resource with the given URI.
 */
+ (id)nodeWithURIString:(NSString *)aString
{
	return [[self alloc] initWithURIString:aString];
}


/**
 *  @param anID The blank node ID. If nil, a new ID is generated.
 *  @return an autoreleased RedlandNode with the specified node ID.
 */
+ (id)nodeWithBlankID:(NSString *)anID
{
	return [[self alloc] initWithBlankID:anID];
}



#pragma mark - Init and Cleanup
/**
 *  Initializes a new RedlandLiteralNode containing a literal with an optional language and XML flag.
 *  @param aString The literal string
 *  @param aLanguage The language of the literal string (will be nil if xmLFlag is YES)
 *  @param xmlFlag If YES, the node is marked as containing well-formed XML data and aLanguage is being ignored
 */
- (id)initWithLiteral:(NSString *)aString language:(NSString *)aLanguage isXML:(BOOL)xmlFlag
{
	NSParameterAssert(aString != nil);
	librdf_node *newNode = librdf_new_node_from_literal([RedlandWorld defaultWrappedWorld],
														(unsigned char *)[aString UTF8String],
														xmlFlag ? NULL : [aLanguage UTF8String],
														xmlFlag);
	if (NULL == newNode) {
		DLog(@"librdf_new_node_from_literal() failed with world %@, string \"%@\", language %@ as XML: %d", [RedlandWorld defaultWorld], aString, aLanguage, xmlFlag);
		return nil;
	}
	return [self initWithWrappedObject:newNode];
}

/**
 *  Initializes a new RedlandLiteralNode, with either a language or a datatype URI.
 *  
 *  @param aString The literal string
 *  @param aLanguage The language of the literal string (ignored if typeURI is present)
 *  @param typeURI The datatype URI (sets aLanguage to nil if present)
 */
- (id)initWithLiteral:(NSString *)aString language:(NSString *)aLanguage type:(RedlandURI *)typeURI
{
	NSParameterAssert(aString != nil);
	librdf_node *newNode = librdf_new_node_from_typed_literal([RedlandWorld defaultWrappedWorld],
															  (unsigned char *)[aString UTF8String],
															  typeURI ? NULL : [aLanguage UTF8String],
															  [typeURI wrappedURI]);
	if (NULL == newNode) {
		DLog(@"librdf_new_node_from_typed_literal() failed with world %@, string \"%@\", language %@ and type %@", [RedlandWorld defaultWorld], aString, aLanguage, typeURI);
		return nil;
	}
	return [self initWithWrappedObject:newNode];
}

/**
 *  Initializes a new RedlandResourceNode representing a resource with the given URI.
 *  @param aString The URI as a string value.
 */
- (id)initWithURIString:(NSString *)aString
{
	NSParameterAssert(aString != nil);
	librdf_node *newNode = librdf_new_node_from_uri_string([RedlandWorld defaultWrappedWorld],
														   (unsigned char *)[aString UTF8String]);
	if (NULL == newNode) {
		DLog(@"librdf_new_node_from_uri_string() failed with world %@ and URI string \"%@\"", [RedlandWorld defaultWrappedWorld], aString);
		return nil;
	}
	return [self initWithWrappedObject:newNode];
}

/**
 *  Initializes a blank RedlandNode with the specified node ID.
 *  @param anID The blank node ID. If nil, a new ID is generated.
 */
- (id)initWithBlankID:(NSString *)anID
{
	librdf_node *newNode = librdf_new_node_from_blank_identifier([RedlandWorld defaultWrappedWorld], (unsigned char *)[anID UTF8String]);
	if (NULL == newNode) {
		DLog(@"librdf_new_node_from_blank_identifier() failed with world %@ and id string \"%@\"", [RedlandWorld defaultWrappedWorld], anID);
		return nil;
	}
	return [self initWithWrappedObject:newNode];
}

/**
 *  Initializes a RedlandResourceNode representing a resource with the given URI.
 *  @param aURI The URI as a RedlandURI.
 */
- (id)initWithURI:(RedlandURI *)aURI
{
	NSParameterAssert(aURI != nil);
	librdf_node *newNode = librdf_new_node_from_uri([RedlandWorld defaultWrappedWorld], [aURI wrappedURI]);
	if (NULL == newNode) {
		DLog(@"librdf_new_node_from_uri() failed with world %@ and URI %@", [RedlandWorld defaultWrappedWorld], aURI);
		return nil;
	}
	return [self initWithWrappedObject:newNode];
}

- (id)copyWithZone:(NSZone *)aZone
{
	librdf_node *copy = librdf_new_node_from_node(wrappedObject);
	if (NULL == copy) {
		DLog(@"Failed to init rdf_node");
		return nil;
	}
	return [[[self class] alloc] initWithWrappedObject:copy];
}

- (void)dealloc
{
    if (isWrappedObjectOwner) {
        librdf_free_node(wrappedObject);
	}
}



#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)coder
{
	unsigned char const *buffer;
	NSUInteger bufSize;
	NSParameterAssert(coder != nil);
	
	if ([coder allowsKeyedCoding]) {
		buffer = [coder decodeBytesForKey:@"encodedBytes" returnedLength:&bufSize];
	}
	else {
		buffer = [coder decodeBytesWithReturnedLength:&bufSize];
	}
	librdf_node *node = librdf_node_decode([RedlandWorld defaultWrappedWorld],
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
	size_t bufSize;
	NSParameterAssert(coder != nil);
	
	bufSize = librdf_node_encode(wrappedObject, NULL, 0);
	@try {
		buffer = malloc(bufSize);
		if (buffer == NULL) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException
										   reason:[NSString stringWithFormat:@"Failed to allocate buffer of %zu bytes for librdf_node_encode", bufSize]
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
	librdf_node *node = wrappedObject;
	unsigned char *outString;
	
	// write to a stream
	raptor_iostream *stream = raptor_new_iostream_to_string(node->world, (void**)&outString, NULL, malloc);
	int ret = librdf_node_write(node, stream);
	raptor_free_iostream(stream);
	if (0 != ret) {
		raptor_free_memory(outString);
		outString = NULL;
	}
	
	// return as NSString
	if (outString) {
		return [NSString stringWithCString:(const char *)outString encoding:NSUTF8StringEncoding];
	}
	
	DLog(@"xxx>  FAILED to write to librdf_node, node type: %d", node->type);
	return [super description];
}



#pragma mark - Comparing Nodes
/**
 *  @param otherNode The node to compare the receiver to
 *  @return YES if the receiver is equal to otherNode.
 */
- (BOOL)isEqualToNode:(RedlandNode *)otherNode
{
	if (otherNode == nil) {
		return NO;
	}
	return (0 != librdf_node_equals(wrappedObject, [otherNode wrappedNode]));
}

- (BOOL)isEqual:(id)otherNode
{
	if ([otherNode isKindOfClass:[self class]]) {
		return [self isEqualToNode:otherNode];
	}
	return NO;
}

- (NSUInteger)hash
{
	return (NSUInteger)wrappedObject;
}

- (NSComparisonResult)compare:(id)otherNode
{
	if (![otherNode isKindOfClass:[self class]]) {
		NSString *reason = [NSString stringWithFormat:
							@"Cannot compare %@ to %@",
							NSStringFromClass([self class]),
							NSStringFromClass([otherNode class])];
		@throw [NSException exceptionWithName:NSBadComparisonException
									   reason:reason
									 userInfo:nil];
	}
	
	// literal nodes
	if ([self isLiteral]) {
		if ([otherNode isLiteral]) {
			
			// compare data type
			RedlandURI *mType = [self literalDataType];
			RedlandURI *oType = [otherNode literalDataType];
			if ((mType && [mType isEqual:oType]) || (!mType && !oType)) {
				
				// compare language
				NSString *mLang = [self literalLanguage];
				NSString *oLang = [otherNode literalLanguage];
				if ((mLang && [mLang isEqualToString:oLang]) || (!mLang && !oLang)) {
					return [[self literalValue] isEqualToString:[otherNode literalValue]];
				}
			}
		}
	}
	
	// resource nodes
	else if ([self isResource]) {
		return [[self URIValue] isEqual:[otherNode URIValue]];
	}
	
	// blank nodes
	else if ([self isBlank]) {
		return [[self blankID] isEqualToString:[otherNode blankID]];
	}
	
	// fallback method
	return [[self description] compare:[otherNode description]];
}



#pragma mark - Accessors
/**
 *  @return the underlying librdf_node object of the receiver.
 */
- (librdf_node *)wrappedNode
{
	return wrappedObject;
}

/**
 *  Returns the node type of the receiver.
 *  @return Possible values include LIBRDF_NODE_TYPE_RESOURCE, LIBRDF_NODE_TYPE_LITERAL, and LIBRDF_NODE_TYPE_BLANK.
 */
- (librdf_node_type)type
{
	return librdf_node_get_type(wrappedObject);
}

/**
 *  @return YES if the receiver is a literal node
 */
- (BOOL)isLiteral
{
	return librdf_node_is_literal(wrappedObject);
}

/**
 *  @return YES if the receiver is a resource (i.e. if it has a URI)
 */
- (BOOL)isResource
{
	return librdf_node_is_resource(wrappedObject);
}

/**
 *  @return YES if the receiver is a blank node.
 */
- (BOOL)isBlank
{
	return librdf_node_is_blank(wrappedObject);
}

/**
 *  @return YES if the receiver is a literal node and contains well-formed XML data.
 */
- (BOOL)isXML
{
	return librdf_node_get_literal_value_is_wf_xml(wrappedObject);
}

/**
 *  Hello World
 *  @return the literal value of the receiver (literal nodes only).
 */
- (NSString *)literalValue
{
	if (![self isLiteral]) {
		return nil;
	}
	
	size_t length;
	unsigned char *literal_value;
	
	literal_value = librdf_node_get_literal_value_as_counted_string(wrappedObject, &length);
	return [[NSString alloc] initWithBytes:literal_value length:length encoding:NSUTF8StringEncoding];
}

/**
 *  @return the resource of the receiver as an RedlandURI object (resource nodes only).
 */
- (RedlandURI *)URIValue
{
	if (![self isResource]) {
		return nil;
	}
	
	librdf_uri *uri_value;
	uri_value = librdf_node_get_uri(wrappedObject);
	if (uri_value != NULL) {
		uri_value = librdf_new_uri_from_uri(uri_value);
	}
	return [[RedlandURI alloc] initWithWrappedObject:uri_value];
}

/**
 *  @return the blank node ID of the receiver (blank nodes only).
 */
- (NSString *)blankID
{
	char *blank_id = (char *)librdf_node_get_blank_identifier(wrappedObject);
	return [[NSString alloc] initWithUTF8String:blank_id];
}

/**
 *  @return the ordinal value of the reciever (for rdf:li nodes).
 */
- (int)ordinalValue
{
	return librdf_node_get_li_ordinal(wrappedObject);
}

/**
 *  @return the literal datatype URI of the receiver (literal nodes only).
 */
- (RedlandURI *)literalDataType
{
	librdf_uri *uri_value;
	uri_value = librdf_node_get_literal_value_datatype_uri(wrappedObject);
	if (uri_value != NULL) {
		uri_value = librdf_new_uri_from_uri(uri_value);
		return [[RedlandURI alloc] initWithWrappedObject:uri_value];
	}
	return nil;
}

/**
 *  @return the XML language of the receiver (literal nodes only).
 */
- (NSString *)literalLanguage
{
	char *language = librdf_node_get_literal_value_language(wrappedObject);
	if (language) {
		return [[NSString alloc] initWithUTF8String:language];
	}
	return nil;
}


@end
