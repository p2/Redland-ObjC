//
//  RedlandParser.h
//  Redland Objective-C Bindings
//  $Id: RedlandParser.h 361 2004-11-10 20:53:38Z kianga $
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

@class RedlandURI, RedlandStream;

extern NSString * const RedlandRDFXMLParserName;				///< The name of the built-in RDF/XML parser
extern NSString * const RedlandNTriplesParserName;				///< The name of the built-in NTriples parser
extern NSString * const RedlandTurtleParserName;				///< The name of the built-in Turtle parser
extern NSString * const RedlandRSSTagSoupParserName;			///< The name of the built-in RSS Tag Soup parser

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

/** 
 *  This class parses various RDF serializations (RDF/XML, NTriples, Turtle) into either a RedlandStream or directly into a RedlandModel, wraps librdf_parser.
 */
@interface RedlandParser : RedlandWrappedObject

+ (RedlandParser *)parserWithName:(NSString *)aName;
+ (RedlandParser *)parserWithName:(NSString *)aName mimeType:(NSString *)mimeType syntaxURI:(RedlandURI *)syntaxURI;

- (id)initWithName:(NSString *)aName;
- (id)initWithName:(NSString *)aName mimeType:(NSString *)mimeType syntaxURI:(RedlandURI *)syntaxURI;

- (librdf_parser *)wrappedParser;

- (void)parseData:(NSData *)data intoModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)baseURI;
- (RedlandStream *)parseData:(NSData *)data asStreamWithBaseURI:(RedlandURI *)baseURI;

- (void)parseString:(NSString *)aString intoModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)baseURI;
- (RedlandStream *)parseString:(NSString *)aString asStreamWithBaseURI:(RedlandURI *)anURI;

- (RedlandNode *)valueOfFeature:(id)featureURI;
- (void)setValue:(RedlandNode *)featureValue ofFeature:(id)featureURI;


@end


/**
 *  Category to add convenience parsing methods to RedlandModel.
 */
@interface RedlandModel (ParserConvenience)

- (void)loadURL:(NSURL *)aURL withContext:(RedlandNode *)context;

@end
