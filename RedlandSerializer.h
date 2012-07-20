//
//  RedlandSerializer.h
//  Redland Objective-C Bindings
//  $Id: RedlandSerializer.h 654 2005-02-06 19:06:48Z kianga $
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

#import <Foundation/Foundation.h>
#import <Redland/redland.h>
#import "RedlandWrappedObject.h"
#import "RedlandModel.h"

/*!
	@header RedlandSerializer.h
	Defines the RedlandSerializer class and various serializer name constants.
*/
@class RedlandURI;

/*! The name of the RDF/XML serializer. */
extern NSString * const RedlandRDFXMLSerializerName;
/*! The name of the NTriples serializer. */
extern NSString * const RedlandNTriplesSerializerName;
/*! The name of the abbreviated RDF/XML serializer. */
extern NSString * const RedlandAbbreviatedRDFXMLSerializer;
/*! The name of the RSS 1.0 serializer. */
extern NSString * const RedlandRSS10Serializer;

/*!
	@class RedlandSerializer
	@abstract A serializer turns a RedlandModel into a serialized format like RDF/XML or NTriples. Wraps librdf_serializer.
*/
@interface RedlandSerializer : RedlandWrappedObject {
}

/*!
    @method serializerWithName:
    @abstract Returns an autoreleased RedlandSerializer initialized using initWithName:.
*/

+ (id)serializerWithName:(NSString *)factoryName;

/*!
	@method initWithName:
	@abstract Initializes a RedlandSerializer with the given name.
	@discussion See the Redland...SerializerName constants for possible names.
*/

- (id)initWithName:(NSString *)factoryName;

/*!
	@method serializerWithName:mimeType:typeURI:
    @abstract Convenience method which returns an autoreleased RedlandSerializer initialized using initWithName:mimeType:typeURI:.
*/
+ (id)serializerWithName:(NSString *)factoryName 
                mimeType:(NSString *)mimeType 
                 typeURI:(RedlandURI *)typeURI;

/*!
    @method initWithName:mimeType:typeURI:
    @abstract Creates and returns a RedlandSerializer identified by either a name, a MIME type, or a type URI.
*/

- (id)initWithName:(NSString *)factoryName mimeType:(NSString *)mimeType typeURI:(RedlandURI *)typeURI;

/*!
	@method wrappedSerializer
	@abstract Returns the underlying librdf_serializer of the receiver.
*/
- (librdf_serializer *)wrappedSerializer;

/*!
	@method serializeModel:toFileName:withBaseURI:
	@abstract Serializes a model to a file with the specified name.
*/
- (void)serializeModel:(RedlandModel *)aModel toFileName:(NSString *)fileName withBaseURI:(RedlandURI *)aURI;

/*!
	@method serializeModel:toFile:withBaseURI:
	@abstract Serializes a model to a C file handle.
*/
- (void)serializeModel:(RedlandModel *)aModel toFile:(FILE *)file withBaseURI:(RedlandURI *)aURI;

/*!
	@method serializeModel:toFileHandle:withBaseURI:
	@abstract Serializes a model to the given NSFileHandle.
*/
- (void)serializeModel:(RedlandModel *)aModel toFileHandle:(NSFileHandle *)fileHandle withBaseURI:(RedlandURI *)aURI;

/*!
	@method valueOfFeature:
	@abstract Returns the value of the serializer feature identified by featureURI.
	@param featureURI An NSString or a RedlandURI instance
*/
- (RedlandNode *)valueOfFeature:(id)featureURI;

/*!
	@method setValue:ofFeature:
	@abstract Sets the serializer feature identified by featureURI to a new value.
	@param featureValue A RedlandNode representing the new value
	@param featureURI An NSString or a RedlandURI instance
	@discussion Raises a RedlandException is no such feature exists.
*/
- (void)setValue:(RedlandNode *)featureValue ofFeature:(id)featureURI;

/*!
    @method setPrefix:forNamespaceURI:
    @abstract Sets a namespace/URI prefix mapping.
*/
- (void)setPrefix:(NSString *)aPrefix forNamespaceURI:(RedlandURI *)uri;
@end

/*! @category RedlandSerializer(Convenience) */
@interface RedlandSerializer (Convenience)

/*! 
@method serializedStringFromModel:withBaseURI:
@abstract Returns a serialized string representation of a model using the given base URI.
*/
- (NSString *)serializedStringFromModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)baseURI;

/*! 
	@method serializedDataFromModel:withBaseURI:
	@abstract Returns a serialized data representation of a model using the given base URI.
*/
- (NSData *)serializedDataFromModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)baseURI;
@end

/*! @category RedlandModel(SerializerConvenience) */
@interface RedlandModel (SerializerConvenience)

/*! 
	@method serializedRDFXMLDataWithBaseURI:
	@abstract Returns an RDF/XML serialization of the receiver using the given base URI.
*/
- (NSData *)serializedRDFXMLDataWithBaseURI:(RedlandURI *)baseURI;


@end
