//
//  RedlandSerializer.m
//  Redland Objective-C Bindings
//  $Id: RedlandSerializer.m 4 2004-09-25 15:49:17Z kianga $
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

NSString * const RedlandRDFXMLSerializerName = @"rdfxml";
NSString * const RedlandNTriplesSerializerName = @"ntriples";
NSString * const RedlandAbbreviatedRDFXMLSerializer = @"rdfxml-abbrev";
NSString * const RedlandRSS10Serializer = @"rss-1.0";

@implementation RedlandSerializer

#pragma mark Init and Cleanup

+ (id)serializerWithName:(NSString *)factoryName
{
	NSParameterAssert(factoryName != nil);
    return [[[self alloc] initWithName:factoryName] autorelease];
}

+ (id)serializerWithName:(NSString *)factoryName 
                mimeType:(NSString *)mimeType 
                 typeURI:(RedlandURI *)typeURI
{
	NSParameterAssert(factoryName != nil || mimeType != nil || typeURI != nil);
	return [[[self alloc] initWithName:factoryName mimeType:mimeType typeURI:typeURI] autorelease];
}

- (id)initWithName:(NSString *)factoryName
{
	NSParameterAssert(factoryName != nil);
	return [self initWithName:factoryName mimeType:nil typeURI:nil];
}

- (id)initWithName:(NSString *)factoryName mimeType:(NSString *)mimeType typeURI:(RedlandURI *)typeURI
{
    librdf_serializer *serializer;
	NSParameterAssert(factoryName != nil || mimeType != nil || typeURI != nil);
    serializer = librdf_new_serializer([RedlandWorld defaultWrappedWorld],
                                       [factoryName UTF8String], 
                                       [mimeType UTF8String],
                                       [typeURI wrappedURI]);
    return [self initWithWrappedObject:serializer];
}

- (void)dealloc
{
    if (isWrappedObjectOwner)
        librdf_free_serializer(wrappedObject);
    [super dealloc];
}

- (librdf_serializer *)wrappedSerializer
{
	return wrappedObject;
}

- (void)serializeModel:(RedlandModel *)aModel 
            toFileName:(NSString *)fileName 
           withBaseURI:(RedlandURI *)aURI
{
    int result;
    NSParameterAssert(aModel != nil);
    NSParameterAssert(fileName != nil);
    result = librdf_serializer_serialize_model_to_file(wrappedObject, 
                                                       [fileName cString], 
                                                       [aURI wrappedURI], 
                                                       [aModel wrappedModel]);
    if (result != 0) {
        @throw [RedlandException exceptionWithName:RedlandExceptionName
                                            reason:@"librdf_serializer_serialize_model_to_file failed"
                                          userInfo:nil];
    }
    [[RedlandWorld defaultWorld] handleStoredErrors];
}

- (void)serializeModel:(RedlandModel *)aModel 
                toFile:(FILE *)file
           withBaseURI:(RedlandURI *)aURI
{
    int result;
    NSParameterAssert(aModel != nil);
    NSParameterAssert(file != NULL);
	
    result = librdf_serializer_serialize_model_to_file_handle(wrappedObject, 
															  file,
															  [aURI wrappedURI], 
															  [aModel wrappedModel]);
    if (result != 0) {
        @throw [RedlandException exceptionWithName:RedlandExceptionName
                                            reason:@"librdf_serializer_serialize_model_to_file failed"
                                          userInfo:nil];
    }
    [[RedlandWorld defaultWorld] handleStoredErrors];
}

- (void)serializeModel:(RedlandModel *)aModel 
          toFileHandle:(NSFileHandle *)fileHandle
           withBaseURI:(RedlandURI *)aURI;
{
    int result;
    int fd;
    FILE *handle;
    NSParameterAssert(aModel != nil);
    NSParameterAssert(fileHandle != nil);
	
    fd = dup([fileHandle fileDescriptor]);
    handle = fdopen(fd, "w");
    if (handle == NULL) {
        close(fd);
        @throw [RedlandException exceptionWithName:RedlandExceptionName
                                            reason:@"fdopen of file descriptor failed"
                                          userInfo:nil];
    }
    result = librdf_serializer_serialize_model(wrappedObject, 
                                               handle,
                                               [aURI wrappedURI], 
                                               [aModel wrappedModel]);
    fclose(handle);
    if (result != 0) {
        @throw [RedlandException exceptionWithName:RedlandExceptionName
                                            reason:@"librdf_serializer_serialize_model_to_file failed"
                                          userInfo:nil];
    }
    [[RedlandWorld defaultWorld] handleStoredErrors];
}

- (void)setPrefix:(NSString *)aPrefix forNamespaceURI:(RedlandURI *)uri
{
	int result;
	NSParameterAssert(aPrefix != nil);
	NSParameterAssert(uri != nil);
	
	result = librdf_serializer_set_namespace(wrappedObject, [uri wrappedURI], [aPrefix UTF8String]);
	if (result != 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_serializer_set_namespace failed"
										  userInfo:nil];
	}
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
	feature_value = librdf_serializer_get_feature(wrappedObject, feature_uri);
	
	return [[[RedlandNode alloc] initWithWrappedObject:feature_value] autorelease];
}

- (void)setValue:(RedlandNode *)featureValue ofFeature:(id)featureURI
{
	int result;
	NSParameterAssert(featureURI != nil);
	
	if ([featureURI isKindOfClass:[NSString class]])
		featureURI = [RedlandURI URIWithString:featureURI];
	NSAssert([featureURI isKindOfClass:[RedlandURI class]], @"featureURI has invalid class");
	
	result = librdf_serializer_set_feature(wrappedObject, 
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

- (NSString *)serializedStringFromModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)baseURI
{
	unsigned char *result;
	size_t len;
	NSParameterAssert(aModel != nil);
	
	result = librdf_serializer_serialize_model_to_counted_string(wrappedObject, [baseURI wrappedURI], [aModel wrappedModel], &len);
	[[RedlandWorld defaultWorld] handleStoredErrors];
	
	return [[[NSString alloc] initWithBytesNoCopy:result length:len encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
}

- (NSData *)serializedDataFromModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)baseURI
{
	unsigned char *result;
	size_t len;
	NSParameterAssert(aModel != nil);
	
	result = librdf_serializer_serialize_model_to_counted_string(wrappedObject, [baseURI wrappedURI], [aModel wrappedModel], &len);
	[[RedlandWorld defaultWorld] handleStoredErrors];
	
	return [[[NSData alloc] initWithBytesNoCopy:result length:len freeWhenDone:YES] autorelease];
}

@end

@implementation RedlandModel (SerializerConvenience)

- (NSData *)serializedRDFXMLDataWithBaseURI:(RedlandURI *)baseURI
{
    RedlandSerializer *serializer;
    serializer = [RedlandSerializer serializerWithName:RedlandRDFXMLSerializerName];
    return [serializer serializedDataFromModel:self withBaseURI:baseURI];
}

@end
