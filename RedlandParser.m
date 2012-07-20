//
//  RedlandParser.m
//  Redland Objective-C Bindings
//  $Id: RedlandParser.m 4 2004-09-25 15:49:17Z kianga $
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

+ (RedlandParser *)parserWithName:(NSString *)aName
{
    return [[[self alloc] initWithName:aName] autorelease];
}

+ (RedlandParser *)parserWithName:(NSString *)aName mimeType:(NSString *)mimeType syntaxURI:(RedlandURI *)uri
{
    return [[[self alloc] initWithName:aName mimeType:mimeType syntaxURI:uri] autorelease];
}

- (id)initWithName:(NSString *)aName
{
	return [self initWithName:aName mimeType:nil syntaxURI:nil];
}

- (id)initWithName:(NSString *)aName mimeType:(NSString *)mimeType syntaxURI:(RedlandURI *)uri
{
    librdf_parser *newParser;
    
    if ((aName == nil) && (mimeType == nil) && (uri == nil))
        aName = RedlandRDFXMLParserName;
    
    newParser = librdf_new_parser([RedlandWorld defaultWrappedWorld],
                                  [aName UTF8String],
                                  [mimeType UTF8String],
                                  [uri wrappedURI]);
    return [self initWithWrappedObject:newParser];
}

- (void)dealloc
{
    if (isWrappedObjectOwner)
        librdf_free_parser(wrappedObject);
    [super dealloc];
}

- (librdf_parser *)wrappedParser
{
	return wrappedObject;
}

- (void)parseString:(NSString *)aString intoModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)uri
{
    int result;
    NSParameterAssert(aString != nil);
    NSParameterAssert(aModel != nil);
    NSParameterAssert(uri != nil);
    result = librdf_parser_parse_string_into_model(wrappedObject, 
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

- (RedlandStream *)parseString:(NSString *)aString asStreamWithBaseURI:(RedlandURI *)uri
{
    librdf_stream *stream;
    NSParameterAssert(aString != nil);
    NSParameterAssert(uri != nil);
    stream = librdf_parser_parse_string_as_stream(wrappedObject, 
                                                  (unsigned char *)[aString UTF8String], 
                                                  [uri wrappedURI]);
    [[RedlandWorld defaultWorld] handleStoredErrors];
    return [[[RedlandStream alloc] initWithWrappedObject:stream] autorelease];
}

- (void)parseData:(NSData *)data intoModel:(RedlandModel *)aModel withBaseURI:(RedlandURI *)baseURI
{
    int result;
    NSParameterAssert(data != nil);
    NSParameterAssert(aModel != nil);
    NSParameterAssert(baseURI != nil);
    result = librdf_parser_parse_counted_string_into_model(wrappedObject,
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

- (RedlandStream *)parseData:(NSData *)data asStreamWithBaseURI:(RedlandURI *)baseURI
{
    librdf_stream *stream;
    NSParameterAssert(data != nil);
    NSParameterAssert(baseURI != nil);
    stream = librdf_parser_parse_counted_string_as_stream(wrappedObject,
                                                          [data bytes],
                                                          [data length],
                                                          [baseURI wrappedURI]);
    [[RedlandWorld defaultWorld] handleStoredErrors];
    return [[[RedlandStream alloc] initWithWrappedObject:stream] autorelease];
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
	feature_value = librdf_parser_get_feature(wrappedObject, feature_uri);
	
	return [[[RedlandNode alloc] initWithWrappedObject:feature_value] autorelease];
}

- (void)setValue:(RedlandNode *)featureValue ofFeature:(id)featureURI
{
	int result;
	NSParameterAssert(featureURI != nil);

	if ([featureURI isKindOfClass:[NSString class]])
		featureURI = [RedlandURI URIWithString:featureURI];
	NSAssert([featureURI isKindOfClass:[RedlandURI class]], @"featureURI has invalid class");

	result = librdf_parser_set_feature(wrappedObject, 
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

- (void)loadURL:(NSURL *)aURL withContext:(RedlandNode *)context
{
    RedlandParser *parser = nil;
    RedlandStream *stream;
    NSError *error = nil;
    NSData *data = nil;
    NSURLRequest *request = nil;
    NSURLResponse *response;
	
	NSParameterAssert(aURL != nil);
    
    @try {
        request = [[NSURLRequest alloc] initWithURL:aURL
										cachePolicy:NSURLRequestReloadIgnoringCacheData
									timeoutInterval:30.0];
        data = [NSURLConnection sendSynchronousRequest:request
                                     returningResponse:(NSURLResponse **)&response
                                                 error:(NSError **)&error];
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
		if (![[response MIMEType] isEqualToString:@"application/octet-stream"])
			parser = [RedlandParser parserWithName:nil mimeType:[response MIMEType] syntaxURI:nil];
        if (parser == nil) // fall back to RDF/XML
            parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
		NSAssert(parser != nil, @"Cannot create parser");
        stream = [parser parseData:data asStreamWithBaseURI:[RedlandURI URIWithURL:aURL]];
		NSAssert(stream != nil, @"Parser did not return a stream");
        [self addStatementsFromStream:stream withContext:context];
    }
    @finally {
        [request release];
    }
}

@end
