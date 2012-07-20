//
//  RedlandParser.h
//  Redland Objective-C Bindings
//  $Id: RedlandParser.h 361 2004-11-10 20:53:38Z kianga $
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

/*!
	@header RedlandParser.h
	Defines the RedlandParser class
*/

#import <Foundation/Foundation.h>
#import <Redland/redland.h>
#import "RedlandWrappedObject.h"
#import "RedlandModel.h"

@class RedlandURI, RedlandStream;

/*! The name of the built-in RDF/XML parser. */
extern NSString * const RedlandRDFXMLParserName;

/*! The name of the built-in NTriples parser. */
extern NSString * const RedlandNTriplesParserName;

/*! The name of the built-in Turtle parser. */
extern NSString * const RedlandTurtleParserName;

/*! The name of the built-in RSS Tag Soup parser. */
extern NSString * const RedlandRSSTagSoupParserName;

extern NSString * const RedlandScanForRDFFeature;
extern NSString * const RedlandAssumeIsRDFFeature;
extern NSString * const RedlandAllowNonNSAttributesFeature;
extern NSString * const RedlandAllowOtherParseTypesFeature;
extern NSString * const RedlandAllowBagIDFeature;
extern NSString * const RedlandAllowRDFTypeRDFListFeature;
extern NSString * const RedlandNormalizeLanguageFeature;
extern NSString * const RedlandNonNFCFatalFeature;
extern NSString * const RedlandWarnOtherParseTypesFeature;
extern NSString * const RedlandCheckRDFIDFeature;
extern NSString * const RedlandRelativeURIsFeature;

/*! 
	@class RedlandParser
	@abstract This class parses various RDF serializations (RDF/XML, NTriples, Turtle) into either a RedlandStream or directly into a RedlandModel. Wraps librdf_parser.
*/
@interface RedlandParser : RedlandWrappedObject {
}

/*!
	@method wrappedParser
	@abstract Returns the underlying librdf_parser object of the receiver.
*/
- (librdf_parser *)wrappedParser;

/*!
    @method parserWithName:
    @abstract Returns an autoreleased RedlandParser of the given type.
*/
+ (RedlandParser *)parserWithName:(NSString *)aName;

/*! 
	@method initWithName:
	@abstract Initializes a new RedlandParser of the given type.
	@discussion See the Redland...ParserName constants for possible values. 
*/
- (id)initWithName:(NSString *)aName;

/*!
    @method parserWithName:mimeType:syntaxURI:
    @abstract Returns an autoreleased RedlandParser initialized using initWithName:mimeType:syntaxURI:.
*/
+ (RedlandParser *)parserWithName:(NSString *)aName mimeType:(NSString *)mimeType syntaxURI:(RedlandURI *)syntaxURI;

/*! 
	@method initWithName:mimeType:syntaxURI:
	@abstract Returns a new RedlandParser which can be identified either by name (see the Redland...ParserName constants), mimeType (e.g. "application/rdf+xml"), or by syntaxURI.
*/
- (id)initWithName:(NSString *)aName mimeType:(NSString *)mimeType syntaxURI:(RedlandURI *)syntaxURI;

/*! 
	@method parseData:intoModel:withBaseURI:
	@abstract Tries to parse data into a model using the given base URI. Raises a RedlandException if there is a parse error. 
*/
- (void)parseData:(NSData *)data 
        intoModel:(RedlandModel *)aModel 
      withBaseURI:(RedlandURI *)baseURI;

/*! 
	@method parseData:asStreamWithBaseURI:
	@abstract Tries to parse data using the given base URI and returns a RedlandStream of statements. Raises a RedlandException if there is a parse error. 
*/
- (RedlandStream *)parseData:(NSData *)data 
         asStreamWithBaseURI:(RedlandURI *)baseURI;

/*! 
	@method parseString:intoModel:withBaseURI:
	@abstract Tries to parse the specified string into aModel using baseURI as the base URI. Raises a RedlandException if there is a parse error. 
*/
- (void)parseString:(NSString *)aString 
          intoModel:(RedlandModel *)aModel 
        withBaseURI:(RedlandURI *)baseURI;

/*! 
	@method parseString:asStreamWithBaseURI:
	@abstract Tries to parse the specified string using baseURI as the base URI and 
    returns a RedlandStream of statements. Raises a RedlandException if there is a parse error. 
*/
- (RedlandStream *)parseString:(NSString *)aString 
           asStreamWithBaseURI:(RedlandURI *)anURI;

/*!
    @method valueOfFeature:
    @abstract Returns the value of the parser feature identified by featureURI.
    @param featureURI An NSString or a RedlandURI instance
*/
- (RedlandNode *)valueOfFeature:(id)featureURI;

/*!
    @method setValue:ofFeature:
    @abstract Sets the parser feature identified by featureURI to a new value.
    @param featureValue A RedlandNode representing the new value
    @param featureURI An NSString or a RedlandURI instance
    @discussion Raises a RedlandException is no such feature exists.
*/
- (void)setValue:(RedlandNode *)featureValue ofFeature:(id)featureURI;
@end

/*! @category RedlandModel(ParserConvenience) */
@interface RedlandModel (ParserConvenience)

/*! 
	@method loadURL:withContext:
	@abstract Fetches data from the given URL using the Cocoa NSURL loading system,    parses it with a parser deduced from the returned MIME type, and adds the statements into the given context of the receiver.
	@discussion This is a nice and uncomplicated convenience function, but it will block until the data has been downloaded and parsed. If the parser type cannot be guessed from the MIME type, an RDF/XML parser will be used.
*/
- (void)loadURL:(NSURL *)aURL withContext:(RedlandNode *)context;

@end
