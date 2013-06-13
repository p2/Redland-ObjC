//
//  RedlandParser.m
//  Redland Objective-C Bindings
//  $Id: RedlandParser.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandParser.h"

#import "RedlandWorld.h"
#import "RedlandModel.h"
#import "RedlandURI.h"
#import "RedlandStream.h"
#import "RedlandException.h"
#import "RedlandNode.h"

NSString * const RedlandRDFXMLParserName = @"rdfxml";
NSString * const RedlandNTriplesParserName = @"ntriples";
NSString * const RedlandTurtleParserName = @"turtle";
NSString * const RedlandRSSTagSoupParserName = @"rss-tag-soup";

NSString * const RedlandScanForRDFFeature = @"http://feature.librdf.org/raptor-scanForRDF";
NSString * const RedlandAssumeIsRDFFeature = @"http://feature.librdf.org/raptor-assumeIsRDF";
NSString * const RedlandAllowNonNSAttributesFeature = @"http://feature.librdf.org/raptor-allowNonNsAttributes";
NSString * const RedlandAllowOtherParseTypesFeature = @"http://feature.librdf.org/raptor-allowOtherParsetypes";
NSString * const RedlandAllowBagIDFeature = @"http://feature.librdf.org/raptor-allowBagID";
NSString * const RedlandAllowRDFTypeRDFListFeature = @"http://feature.librdf.org/raptor-allowRDFtypeRDFlist";
NSString * const RedlandNormalizeLanguageFeature = @"http://feature.librdf.org/raptor-normalizeLanguage";
NSString * const RedlandNonNFCFatalFeature = @"http://feature.librdf.org/raptor-nonNFCfatal";
NSString * const RedlandWarnOtherParseTypesFeature = @"http://feature.librdf.org/raptor-warnOtherParseTypes";
NSString * const RedlandCheckRDFIDFeature = @"http://feature.librdf.org/raptor-checkRdfID";
NSString * const RedlandRelativeURIsFeature = @"http://feature.librdf.org/raptor-relativeURIs";

@implementation RedlandParser

/**
 *  Returns an autoreleased RedlandParser of the given type.
 *  @param aName The name of the parser to use; use one of the constants
 *  @return A new RedlandParser instance
 */
+ (RedlandParser *)parserWithName:(NSString *)aName
{
	return [[self alloc] initWithName:aName];
}

/**
 *  Returns an autoreleased RedlandParser initialized using initWithName:mimeType:syntaxURI:.
 *  @param aName The name of the parser to use; use one of the constants
 *  @param mimeType The mime-type the parser should produce
 *  @param uri The syntax-URI the parser should use; see our constants
 *  @return A new RedlandParser instance
 */
+ (RedlandParser *)parserWithName:(NSString *)aName mimeType:(NSString *)mimeType syntaxURI:(RedlandURI *)uri
{
	return [[self alloc] initWithName:aName mimeType:mimeType syntaxURI:uri];
}

/**
 *  Initializes a new RedlandParser of the given type.
 *  @param aName The name of the parser to use; use one of the constants
 *  @return A new RedlandParser instance
 */
- (id)initWithName:(NSString *)aName
{
	return [self initWithName:aName mimeType:nil syntaxURI:nil];
}

/**
 *  The designated initializer.
 *
 *  Returns a new RedlandParser which can be identified either by name (see the Redland...ParserName constants), mimeType (e.g. "application/rdf+xml"), or by
 *  syntaxURI. Defaults to a RDF+XML parser.
 *  @param aName The name of the parser to use; use one of the constants
 *  @param mimeType The mime-type the parser should produce
 *  @param uri The syntax-URI the parser should use; see our constants
 *  @return A new RedlandParser instance
 */
- (id)initWithName:(NSString *)aName mimeType:(NSString *)mimeType syntaxURI:(RedlandURI *)uri
{
	if ((aName == nil) && (mimeType == nil) && (uri == nil)) {
		aName = RedlandRDFXMLParserName;
	}
	
	librdf_parser *newParser = librdf_new_parser([RedlandWorld defaultWrappedWorld],
												 [aName UTF8String],
												 [mimeType UTF8String],
												 [uri wrappedURI]);
	return [self initWithWrappedObject:newParser];
}

- (void)dealloc
{
	if (isWrappedObjectOwner) {
		librdf_free_parser(wrappedObject);
	}
}


/**
 *  Returns the underlying librdf_parser object of the receiver.
 *  @return A librdf_parser struct
 */
- (librdf_parser *)wrappedParser
{
	return wrappedObject;
}



#pragma mark - Parsing
/**
 *  Tries to parse the specified string into aModel using baseURI as the base URI.
 *  @warning Raises a RedlandException if there is a parse error or if "aModel" or "uri" is missing.
 *  @param aString The string to parse
 *  @param aModel The model to parse into; required
 *  @param uri The base URI
 */
- (void)parseString:(NSString *)aString intoModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)uri
{
	if ([aString length] < 1) {
		return;
	}
	
	NSParameterAssert(aModel != nil);
	NSParameterAssert(uri != nil);
	
	int result = librdf_parser_parse_string_into_model(wrappedObject,
													   (unsigned char *)[aString UTF8String],
													   [uri wrappedURI],
													   [aModel wrappedModel]);
	[[RedlandWorld defaultWorld] handleStoredErrors];
	if (result != 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_parser_parse_string_into_model failed"
										  userInfo:nil];
	}
}

/**
 *  Tries to parse the specified string using baseURI as the base URI and returns a RedlandStream of statements.
 *  @warning Raises a RedlandException if there is a parse error.
 *  @param aString The string to parse
 *  @param uri The base URI
 *  @return A RedlandStream instance
 */
- (RedlandStream *)parseString:(NSString *)aString asStreamWithBaseURI:(RedlandURI *)uri
{
	if ([aString length] < 1) {
		return nil;
	}
	
	NSParameterAssert(uri != nil);
	
	librdf_stream *stream = librdf_parser_parse_string_as_stream(wrappedObject,
																 (unsigned char *)[aString UTF8String],
																 [uri wrappedURI]);
	[[RedlandWorld defaultWorld] handleStoredErrors];
	return [[RedlandStream alloc] initWithWrappedObject:stream];
}

/**
 *  Tries to parse data into a model using the given base URI.
 *  @warning Raises a RedlandException if there is a parse error.
 *  @param data The data to parse as NSData
 *  @param aModel The model to parse into; required
 *  @param baseURI The base URI
 */
- (void)parseData:(NSData *)data intoModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)baseURI
{
	NSParameterAssert(data != nil);
	NSParameterAssert(aModel != nil);
	NSParameterAssert(baseURI != nil);
	
	int result = librdf_parser_parse_counted_string_into_model(wrappedObject,
															   [data bytes],
															   [data length],
															   [baseURI wrappedURI],
															   [aModel wrappedModel]);
	if (result != 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_parser_parse_counted_string_into_model failed"
										  userInfo:nil];
	}
	[[RedlandWorld defaultWorld] handleStoredErrors];
}

/**
 *  Tries to parse data using the given base URI and returns a RedlandStream of statements.
 *  @warning Raises a RedlandException if there is a parse error.
 *  @param data The data to parse as NSData
 *  @param baseURI The base URI
 */
- (RedlandStream *)parseData:(NSData *)data asStreamWithBaseURI:(RedlandURI *)baseURI
{
	NSParameterAssert(data != nil);
	NSParameterAssert(baseURI != nil);
	
	librdf_stream *stream = librdf_parser_parse_counted_string_as_stream(wrappedObject,
																		 [data bytes],
																		 [data length],
																		 [baseURI wrappedURI]);
	[[RedlandWorld defaultWorld] handleStoredErrors];
	return [[RedlandStream alloc] initWithWrappedObject:stream];
}



#pragma mark - Features
/**
 *  Returns the value of the parser feature identified by featureURI.
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
	librdf_node *feature_value = librdf_parser_get_feature(wrappedObject, feature_uri);
	
	return [[RedlandNode alloc] initWithWrappedObject:feature_value];
}

/**
 *  Sets the parser feature identified by featureURI to a new value.
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
	
	int result = librdf_parser_set_feature(wrappedObject,
										   [featureURI wrappedURI],
										   [featureValue wrappedNode]);
	if (result > 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_parser_set_feature returned >0"
										  userInfo:nil];
	}
	else if (result < 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"No such feature"
										  userInfo:nil];
	}
}

@end



@implementation RedlandModel (ParserConvenience)

/**
 *  Fetches data from the given URL using the Cocoa NSURL loading system, parses it with a parser deduced from the returned MIME type, and adds the statements
 *  into the given context of the receiver.
 *  @warning This is a nice and uncomplicated convenience function, but it will block until the data has been downloaded and parsed. If the parser type cannot
 *  be guessed from the MIME type, an RDF/XML parser will be used.
 *  @param aURL The NSURL to load
 *  @param context an optional context
 */
- (void)loadURL:(NSURL *)aURL withContext:(RedlandNode *)context
{
	NSParameterAssert(aURL != nil);
	
	NSError *error = nil;
	NSURLRequest *request = nil;
	NSURLResponse *response = nil;
	
	@try {
		// create the request and fetch data SYNCHRONOUSLY
		request = [[NSURLRequest alloc] initWithURL:aURL
										cachePolicy:NSURLRequestReloadIgnoringCacheData
									timeoutInterval:30.0];
		NSData *data = [NSURLConnection sendSynchronousRequest:request
											 returningResponse:&response
														 error:&error];
		if (data == nil) {
			@throw [RedlandException exceptionWithName:RedlandExceptionName
												reason:[NSString stringWithFormat:@"Could not fetch URL %@: %@", aURL, error]
											  userInfo:nil];
		}
		if ([data length] == 0) {
			@throw [RedlandException exceptionWithName:RedlandExceptionName
												reason:[NSString stringWithFormat:@"Empty content of URL %@", aURL]
											  userInfo:nil];
		}
		
		// create the parser based on the mime-type (except if we get a generic type)
		RedlandParser *parser = nil;
		if (![[response MIMEType] isEqualToString:@"application/octet-stream"] && ![[response MIMEType] isEqualToString:@"text/plain"]) {
			parser = [RedlandParser parserWithName:nil mimeType:[response MIMEType] syntaxURI:nil];
		}
		
		// fall back to RDF/XML
		if (parser == nil) {
			parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
		}
		NSAssert(parser != nil, @"Cannot create parser");
		RedlandStream *stream = [parser parseData:data asStreamWithBaseURI:[RedlandURI URIWithURL:aURL]];
		NSAssert(stream != nil, @"Parser did not return a stream");
		[self addStatementsFromStream:stream withContext:context];
	}
	@finally {
		request = nil;
	}
}


@end
