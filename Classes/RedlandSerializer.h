//
//  RedlandSerializer.h
//  Redland Objective-C Bindings
//  $Id: RedlandSerializer.h 654 2005-02-06 19:06:48Z kianga $
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

#import <Foundation/Foundation.h>
#import <redland.h>
#import "RedlandWrappedObject.h"
#import "RedlandModel.h"

/**
 *  @header RedlandSerializer.h
 *  Defines the RedlandSerializer class and various serializer name constants.
 */
@class RedlandURI;

extern NSString * const RedlandRDFXMLSerializerName;				///< The name of the RDF/XML serializer
extern NSString * const RedlandNTriplesSerializerName;				///< The name of the NTriples serializer
extern NSString * const RedlandAbbreviatedRDFXMLSerializer;			///< The name of the abbreviated RDF/XML serializer
extern NSString * const RedlandRSS10Serializer;						///< The name of the RSS 1.0 serializer


/**
 *  A serializer turns a RedlandModel into a serialized format like RDF/XML or NTriples.
 *
 *  Wraps librdf_serializer. It seems you should use a new serializer for every model that you want to serialize because of namespace caching (see issue #18 on
 *  redland's bugtracker: http://bugs.librdf.org/mantis/view.php?id=18)
 */
@interface RedlandSerializer : RedlandWrappedObject

+ (id)serializerWithName:(NSString *)factoryName;
+ (id)serializerWithName:(NSString *)factoryName mimeType:(NSString *)mimeType typeURI:(RedlandURI *)typeURI;

- (id)initWithName:(NSString *)factoryName;
- (id)initWithName:(NSString *)factoryName mimeType:(NSString *)mimeType typeURI:(RedlandURI *)typeURI;

- (librdf_serializer *)wrappedSerializer;

- (void)serializeModel:(RedlandModel *)aModel toFileName:(NSString *)fileName withBaseURI:(RedlandURI *)aURI;
- (void)serializeModel:(RedlandModel *)aModel toFile:(FILE *)file withBaseURI:(RedlandURI *)aURI;
- (void)serializeModel:(RedlandModel *)aModel toFileHandle:(NSFileHandle *)fileHandle withBaseURI:(RedlandURI *)aURI;

- (void)setPrefix:(NSString *)aPrefix forNamespaceURI:(RedlandURI *)uri;

- (RedlandNode *)valueOfFeature:(id)featureURI;
- (void)setValue:(RedlandNode *)featureValue ofFeature:(id)featureURI;


@end


/**
 *  RedlandSerializer(Convenience)
 */
@interface RedlandSerializer (Convenience)

- (NSString *)serializedStringFromModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)baseURI;
- (NSData *)serializedDataFromModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)baseURI;

@end


/**
 *  RedlandModel(SerializerConvenience)
 */
@interface RedlandModel (SerializerConvenience)

- (NSData *)serializedRDFXMLDataWithBaseURI:(RedlandURI *)baseURI;

@end
