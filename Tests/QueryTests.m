//
//  QueryTests.m
//  Redland Objective-C Bindings
//  $Id: QueryTests.m 4 2004-09-25 15:49:17Z kianga $
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

#import "QueryTests.h"

#import "RedlandQuery.h"
#import "RedlandQueryResults.h"
#import "RedlandParser.h"
#import "RedlandException.h"
#import "RedlandURI.h"

static NSString *RDFXMLTestData = nil;
static NSString * const RDFXMLTestDataLocation = @"http://www.w3.org/1999/02/22-rdf-syntax-ns";

@implementation QueryTests

+ (void)initialize
{
    if (RDFXMLTestData == nil) {
        NSBundle *bundle = [NSBundle bundleForClass:self];
        NSString *path = [bundle pathForResource:@"rdf-syntax" ofType:@"rdf"];
        RDFXMLTestData = [[NSString alloc] initWithContentsOfFile:path];
		NSAssert(RDFXMLTestData != nil, @"Could not load RDFXML test data");
    }
}

- (void)setUp
{
	RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
	model = [[RedlandModel model] retain];
	uri = [RedlandURI URIWithString:RDFXMLTestDataLocation];
	[parser parseString:RDFXMLTestData intoModel:model withBaseURI:uri];
	NSAssert([model size] > 0, @"Test model is empty");
}

- (void)tearDown
{
    [model release];
	model = nil;
}

- (void)testBadQuery
{
	NSString *queryString = @"This is not a valid query.";
	RedlandQuery *query;
	
	query = [RedlandQuery queryWithLanguageName:RedlandRDQLLanguageName
									queryString:queryString baseURI:nil];
	STAssertThrowsSpecific([query executeOnModel:model], RedlandException, nil);
}

- (void)testQueryAll
{
    NSString *queryString;
    RedlandQuery *query;
    RedlandQueryResults *results;
    NSArray *allResults;
    
	STAssertTrue([model size] > 0, nil);
	
    queryString = @"SELECT ?s ?p ?o WHERE (?s ?p ?o)";
    STAssertNoThrow(query = [RedlandQuery queryWithLanguageName:RedlandRDQLLanguageName queryString:queryString baseURI:nil], nil);
    STAssertNotNil(query, nil);
    STAssertNoThrow(results = [query executeOnModel:model], nil);
    STAssertNotNil(results, nil);
	if (results != nil) {
		STAssertEquals(3, [results countOfBindings], nil);
		STAssertNoThrow(allResults = [[results resultEnumerator] allObjects], nil);
		STAssertEquals((unsigned)[model size], (unsigned)[allResults count], nil);
	}
}

- (void)testSimpleQuery
{
    NSString *queryString;
    RedlandQuery *query;
    RedlandQueryResults *results;
    NSArray *allResults;
    
	STAssertTrue([model size] > 0, nil);
	
    queryString = @"SELECT ?s ?o WHERE (?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?o)";
    STAssertNoThrow(query = [RedlandQuery queryWithLanguageName:RedlandRDQLLanguageName queryString:queryString baseURI:nil], nil);
    STAssertNotNil(query, nil);
    STAssertNoThrow(results = [query executeOnModel:model], nil);
    STAssertNotNil(results, nil);
	if (results != nil) {
		STAssertEquals(2, [results countOfBindings], nil);
		STAssertNoThrow(allResults = [[results resultEnumerator] allObjects], nil);
		STAssertTrue([allResults count] > 0, nil);
	}
}

@end
