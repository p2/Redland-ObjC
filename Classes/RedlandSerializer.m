//
//  RedlandSerializer.m
//  Redland Objective-C Bindings
//  $Id: RedlandSerializer.m 4 2004-09-25 15:49:17Z kianga $
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

#import <unistd.h>
#import <sys/types.h>
#import <sys/stat.h>
#import <fcntl.h>
#import "RedlandSerializer.h"
#import "RedlandWorld.h"
#import "RedlandModel.h"
#import "RedlandURI.h"
#import "RedlandException.h"
#import "RedlandNode.h"
#include <stdio.h>

NSString * const RedlandRDFXMLSerializerName = @"rdfxml";
NSString * const RedlandNTriplesSerializerName = @"ntriples";
NSString * const RedlandAbbreviatedRDFXMLSerializer = @"rdfxml-abbrev";
NSString * const RedlandRSS10Serializer = @"rss-1.0";

@implementation RedlandSerializer

#pragma mark Init and Cleanup

/**
 *  Returns an autoreleased RedlandSerializer initialized using initWithName:.
 *  @param factoryName The name for the serializer; use one of our Redland...SerializerName constants
 *  @return A new RedlandSerializer instance
 */
+ (id)serializerWithName:(NSString *)factoryName
{
	NSParameterAssert(factoryName != nil);
	return [[self alloc] initWithName:factoryName];
}

/**
 *  Convenience method which returns an autoreleased RedlandSerializer initialized using initWithName:mimeType:typeURI:.
 *  @param factoryName The name for the serializer; use one of our Redland...SerializerName constants
 *  @param mimeType The mime-type the serializer should produce
 *  @param typeURI type URI for the type of serialization
 *  @return A new RedlandSerializer instance
 */
+ (id)serializerWithName:(NSString *)factoryName mimeType:(NSString *)mimeType typeURI:(RedlandURI *)typeURI
{
	NSParameterAssert(factoryName != nil || mimeType != nil || typeURI != nil);
	return [[self alloc] initWithName:factoryName mimeType:mimeType typeURI:typeURI];
}

/**
 *  Initializes a RedlandSerializer with the given name.
 *  @param factoryName The name for the serializer; use one of our Redland...SerializerName constants
 *  @return A new RedlandSerializer instance
 */
- (id)initWithName:(NSString *)factoryName
{
	NSParameterAssert(factoryName != nil);
	return [self initWithName:factoryName mimeType:nil typeURI:nil];
}

/**
 *  Creates and returns a RedlandSerializer identified by either a name, a MIME type, or a type URI.
 *  @param factoryName The name for the serializer; use one of our Redland...SerializerName constants
 *  @param mimeType The mime-type the serializer should produce
 *  @param typeURI type URI for the type of serialization
 *  @return A new RedlandSerializer instance
 */
- (id)initWithName:(NSString *)factoryName mimeType:(NSString *)mimeType typeURI:(RedlandURI *)typeURI
{
	NSParameterAssert(factoryName != nil || mimeType != nil || typeURI != nil);
	librdf_serializer *serializer = librdf_new_serializer([RedlandWorld defaultWrappedWorld],
														  [factoryName UTF8String],
														  [mimeType UTF8String],
														  [typeURI wrappedURI]);
	return [self initWithWrappedObject:serializer];
}

- (void)dealloc
{
	if (isWrappedObjectOwner) {
		librdf_free_serializer(wrappedObject);
	}
}


/**
 *  Returns the underlying librdf_serializer of the receiver.
 */
- (librdf_serializer *)wrappedSerializer
{
	return wrappedObject;
}



#pragma mark - Serialization
/**
 *  Serializes a model to a file with the specified name.
 *  @param aModel The model (RedlandModel instance) to serialize
 *  @param fileName the filename to write to as NSString
 *  @param aURI The base-URI to use as RedlandURI
 */
- (void)serializeModel:(RedlandModel *)aModel toFileName:(NSString *)fileName withBaseURI:(RedlandURI *)aURI
{
	NSParameterAssert(aModel != nil);
	NSParameterAssert(fileName != nil);
	
	int result = librdf_serializer_serialize_model_to_file(wrappedObject,
														   [fileName cStringUsingEncoding:NSUTF8StringEncoding],
														   [aURI wrappedURI],
														   [aModel wrappedModel]);
	if (result != 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_serializer_serialize_model_to_file failed"
										  userInfo:nil];
	}
	[[RedlandWorld defaultWorld] handleStoredErrors];
}

/**
 *  Serializes a model to a C file handle.
 *  @param aModel The model (RedlandModel instance) to serialize
 *  @param file the C file handle
 *  @param aURI The base-URI to use as RedlandURI
 */
- (void)serializeModel:(RedlandModel *)aModel toFile:(FILE *)file withBaseURI:(RedlandURI *)aURI
{
	NSParameterAssert(aModel != nil);
	NSParameterAssert(file != NULL);
	
	int result = librdf_serializer_serialize_model_to_file_handle(wrappedObject,
																  file,
																  [aURI wrappedURI],
																  [aModel wrappedModel]);
	if (result != 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_serializer_serialize_model_to_file_handle failed"
										  userInfo:nil];
	}
	[[RedlandWorld defaultWorld] handleStoredErrors];
}

/**
 *  Serializes a model to the given NSFileHandle.
 *  @param aModel The model (RedlandModel instance) to serialize
 *  @param fileHandle the filehandle as NSFileHandle to write to
 *  @param aURI The base-URI to use as RedlandURI
 */
- (void)serializeModel:(RedlandModel *)aModel toFileHandle:(NSFileHandle *)fileHandle withBaseURI:(RedlandURI *)aURI;
{
	NSParameterAssert(aModel != nil);
	NSParameterAssert(fileHandle != nil);
	
	int fd = dup([fileHandle fileDescriptor]);
	FILE *handle = fdopen(fd, "w");
	if (handle == NULL) {
		close(fd);
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"fdopen of file descriptor failed"
										  userInfo:nil];
	}
	int result = librdf_serializer_serialize_model_to_file_handle(wrappedObject,
																  handle,
																  [aURI wrappedURI],
																  [aModel wrappedModel]);
	fclose(handle);
	if (result != 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_serializer_serialize_model_to_file_handle failed"
										  userInfo:nil];
	}
	[[RedlandWorld defaultWorld] handleStoredErrors];
}

/**
 *  Sets a namespace/URI prefix mapping.
 *  @param aPrefix The prefix as NSString
 *  @param uri The namespace URI as RedlandURI
 */
- (void)setPrefix:(NSString *)aPrefix forNamespaceURI:(RedlandURI *)uri
{
	NSParameterAssert(aPrefix != nil);
	NSParameterAssert(uri != nil);
	
	int result = librdf_serializer_set_namespace(wrappedObject, [uri wrappedURI], [aPrefix UTF8String]);
	if (result != 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_serializer_set_namespace failed"
										  userInfo:nil];
	}
}



#pragma mark - Features
/**
 *  Returns the value of the serializer feature identified by featureURI.
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
	librdf_node *feature_value = librdf_serializer_get_feature(wrappedObject, feature_uri);
	
	return [[RedlandNode alloc] initWithWrappedObject:feature_value];
}

/**
 *  Sets the serializer feature identified by featureURI to a new value.
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
	
	int result = librdf_serializer_set_feature(wrappedObject,
											   [featureURI wrappedURI],
											   [featureValue wrappedNode]);
	if (result > 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_serializer_set_feature returned >0"
										  userInfo:nil];
	}
	else if (result < 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"No such feature"
										  userInfo:nil];
	}
}


@end



@implementation RedlandSerializer (Convenience)

/**
 *  Returns a serialized string representation of a model using the given base URI.
 *  @param aModel The model (RedlandModel instance) to serialize
 *  @param baseURI The base-URI to use as RedlandURI
 *  @return An NSString
 */
- (NSString *)serializedStringFromModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)baseURI
{
	NSParameterAssert(aModel != nil);
	
	size_t len;
	unsigned char *result = librdf_serializer_serialize_model_to_counted_string(wrappedObject, [baseURI wrappedURI], [aModel wrappedModel], &len);
	[[RedlandWorld defaultWorld] handleStoredErrors];
	
	return [[NSString alloc] initWithBytesNoCopy:result length:len encoding:NSUTF8StringEncoding freeWhenDone:YES];
}

/**
 *  Returns a serialized data representation of a model using the given base URI.
 *  @param aModel The model (RedlandModel instance) to serialize
 *  @param baseURI The base-URI to use as RedlandURI
 *  @return NSData
 */
- (NSData *)serializedDataFromModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)baseURI
{
	NSParameterAssert(aModel != nil);
	
	size_t len;
	unsigned char *result = librdf_serializer_serialize_model_to_counted_string(wrappedObject, [baseURI wrappedURI], [aModel wrappedModel], &len);
	[[RedlandWorld defaultWorld] handleStoredErrors];
	
	return [[NSData alloc] initWithBytesNoCopy:result length:len freeWhenDone:YES];
}


@end



@implementation RedlandModel (SerializerConvenience)
/**
 *  Returns an RDF/XML serialization of the receiver using the given base URI.
 *  @param baseURI The base-URI to use as RedlandURI
 *  @return NSData
 */
- (NSData *)serializedRDFXMLDataWithBaseURI:(RedlandURI *)baseURI
{
	RedlandSerializer *serializer = [RedlandSerializer serializerWithName:RedlandRDFXMLSerializerName];
	return [serializer serializedDataFromModel:self withBaseURI:baseURI];
}


@end


/**
 *  librdf_serializer_serialize_model_to_file() uses the UNIX conformance variant for fopen, "fopen$UNIX2003". This method maps those two functions.
 *  @todo Is there a cleaner solution to this?
 */
FILE *fopen$UNIX2003( const char *filename, const char *mode )
{
	return fopen(filename, mode);
}

/**
 *  raptor_filename_iostream_write_bytes() uses the UNIX conformance variant for fwrite, "fwrite$UNIX2003". This method maps those two functions.
 *  @todo Is there a cleaner solution to this?
 */
size_t fwrite$UNIX2003( const void *a, size_t b, size_t c, FILE *d )
{
	return fwrite(a, b, c, d);
}

