//
//  SerializerTests.m
//  Redland Objective-C Bindings
//  $Id: SerializerTests.m 4 2004-09-25 15:49:17Z kianga $
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

#import "SerializerTests.h"

#import "RedlandModel.h"
#import "RedlandURI.h"
#import "RedlandParser.h"
#import "RedlandSerializer.h"

static NSString *RDFXMLTestData = nil;
static NSString * const RDFXMLTestDataLocation = @"http://www.w3.org/1999/02/22-rdf-syntax-ns";

@implementation SerializerTests

- (BOOL)needsRunLoop
{
	return NO;
}

+ (void)initialize
{
    if (RDFXMLTestData == nil) {
        NSBundle *bundle = [NSBundle bundleForClass:self];
        NSString *path = [bundle pathForResource:@"rdf-syntax" ofType:@"rdf"];
        RDFXMLTestData = [[NSString alloc] initWithContentsOfFile:path];
    }
}

- (void)setUp
{
	RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
	model = [[RedlandModel model] retain];
	uri = [RedlandURI URIWithString:RDFXMLTestDataLocation];
	[parser parseString:RDFXMLTestData intoModel:model withBaseURI:uri];
}

- (void)tearDown
{
    [model release];
	model = nil;
}

- (void)testToFile
{
    RedlandSerializer *serializer = [RedlandSerializer serializerWithName:RedlandRDFXMLSerializerName];
    NSString *tempFileName = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]]; 
    BOOL isDir;
    
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:tempFileName], nil);
    STAssertNoThrow([serializer serializeModel:model toFileName:tempFileName withBaseURI:uri], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:tempFileName isDirectory:(BOOL *)&isDir], nil);
    STAssertTrue([(NSString *)[NSString stringWithContentsOfFile:tempFileName] length] > 0, nil);
    if (!isDir)
        [[NSFileManager defaultManager] removeFileAtPath:tempFileName handler:nil];
}

- (void)testInMemoryRoundTrip
{
    RedlandSerializer *serializer = [RedlandSerializer serializerWithName:RedlandRDFXMLSerializerName];
    RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
    NSData *data = nil;
    RedlandModel *newModel = [RedlandModel model];
    
    STAssertNoThrow(data = [serializer serializedDataFromModel:model withBaseURI:uri], nil);
    STAssertNotNil(data, nil);
    STAssertTrue([data length] > 0, nil);
    STAssertNoThrow([parser parseData:data intoModel:newModel withBaseURI:uri], nil);
    STAssertTrue([newModel size] > 0, nil);
    STAssertEquals([model size], [newModel size], nil);
}

- (void)testConvenience
{
    NSData *data;
    
    STAssertNoThrow(data = [model serializedRDFXMLDataWithBaseURI:uri], nil);
    STAssertTrue([data length] > 0, nil);
}

@end
