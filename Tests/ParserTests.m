//
//  ParserTests.m
//  Redland Objective-C Bindings
//  $Id: ParserTests.m 4 2004-09-25 15:49:17Z kianga $
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

#import "ParserTests.h"

#import "RedlandParser.h"
#import "RedlandURI.h"
#import "RedlandStream.h"
#import "RedlandStreamEnumerator.h"
#import "RedlandModel-Convenience.h"
#import "RedlandException.h"
#import "RedlandNode-Convenience.h"

static NSString *RDFXMLTestData = nil;
static NSString * const RDFXMLTestDataLocation = @"http://www.w3.org/1999/02/22-rdf-syntax-ns";

@implementation ParserTests

+ (void)initialize
{
    if (RDFXMLTestData == nil) {
        NSBundle *bundle = [NSBundle bundleForClass:self];
        NSString *path = [bundle pathForResource:@"rdf-syntax" ofType:@"rdf"];
		NSStringEncoding usedEncoding = 0;
        RDFXMLTestData = [[NSString alloc] initWithContentsOfFile:path usedEncoding:&usedEncoding error:nil];
    }
}

- (void)testParseRDFXML
{
    RedlandParser *parser;
    RedlandURI *testURI = [RedlandURI URIWithString:RDFXMLTestDataLocation];
    RedlandStream *stream;
    NSArray *allStatements;
    
    parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
    STAssertNoThrow(stream = [parser parseString:RDFXMLTestData asStreamWithBaseURI:testURI], nil);
    STAssertNotNil(stream, nil);
    allStatements = [[stream statementEnumerator] allObjects];
    STAssertNotNil(allStatements, nil);
    STAssertTrue([allStatements count] > 10, nil);
}

- (void)testParseRDFXMLData
{
    RedlandParser *parser;
    RedlandURI *testURI = [RedlandURI URIWithString:RDFXMLTestDataLocation];
    RedlandStream *stream;
    NSArray *allStatements;
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"rdf-syntax" ofType:@"rdf"];
	NSData *data = [NSData dataWithContentsOfFile:path];
    
	STAssertNotNil(data, nil);
    parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
    STAssertNoThrow(stream = [parser parseData:data asStreamWithBaseURI:testURI], nil);
    STAssertNotNil(stream, nil);
    allStatements = [[stream statementEnumerator] allObjects];
    STAssertNotNil(allStatements, nil);
    STAssertTrue([allStatements count] > 10, nil);
}

- (void)testConvenience
{
    RedlandModel *model = [RedlandModel new];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"rdf-syntax" ofType:@"rdf"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    
	STAssertNotNil(path, nil);
    STAssertNoThrow([model loadURL:url withContext:nil], nil);
    STAssertTrue([model size] > 0, nil);
}

- (void)testParseError
{
	NSString *string = @"This is NOT RDF/XML.";
	RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
	
	STAssertThrowsSpecific([parser parseString:string asStreamWithBaseURI:[RedlandURI URIWithString:@"http://foo/"]], RedlandException, nil);
}

- (void)testSetFeature
{
	RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
	STAssertNoThrow([parser setValue:[RedlandNode nodeWithLiteral:@"1"] ofFeature:RedlandScanForRDFFeature], nil);
}

@end
