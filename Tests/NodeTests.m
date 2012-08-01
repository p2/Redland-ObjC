//
//  NodeTests.m
//  Redland Objective-C Bindings
//  $Id: NodeTests.m 4 2004-09-25 15:49:17Z kianga $
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

#import "NodeTests.h"
#import "RedlandNode.h"
#import "RedlandNode-Convenience.h"
#import "RedlandURI.h"
#import "RedlandException.h"

@implementation NodeTests

- (void)testLiteral
{
	NSString *string = @"Hello world";
	NSString *language = @"en";
	RedlandURI *typeURI = [RedlandURI URIWithString:@"http://foo/"];
	
	RedlandNode *nodeWithType = [RedlandNode nodeWithLiteral:string language:language type:typeURI];
	RedlandNode *nodeWithLang = [RedlandNode nodeWithLiteral:string language:language type:nil];
	STAssertNotNil(nodeWithType, nil);
	STAssertNotNil(nodeWithLang, nil);
	STAssertTrue([nodeWithType isLiteral], nil);
	STAssertTrue([nodeWithLang isLiteral], nil);
	STAssertEqualObjects(string, [nodeWithType literalValue], nil);
	STAssertEqualObjects(string, [nodeWithLang literalValue], nil);
	STAssertEqualObjects(nil, [nodeWithType literalLanguage], nil);				// language can only be set if type is nil
	STAssertEqualObjects(language, [nodeWithLang literalLanguage], nil);		// language is now set
	STAssertEqualObjects(typeURI, [nodeWithType literalDataType], nil);
	STAssertFalse([nodeWithType isXML], nil);
}

- (void)testLiteralXML
{
	NSString *string = @"<hello>world</hello>";
	NSString *language = @"en";
	
	RedlandNode *nodeXML = [RedlandNode nodeWithLiteral:string language:language isXML:YES];
	RedlandNode *nodeNot = [RedlandNode nodeWithLiteral:string language:language isXML:NO];
	STAssertNotNil(nodeXML, nil);
	STAssertNotNil(nodeNot, nil);
	STAssertTrue([nodeXML isLiteral], nil);
	STAssertTrue([nodeNot isLiteral], nil);
	STAssertEqualObjects(string, [nodeXML literalValue], nil);
	STAssertEqualObjects(string, [nodeNot literalValue], nil);
	STAssertEqualObjects(nil, [nodeXML literalLanguage], nil);				// language can only be set if the node is NOT XML
	STAssertEqualObjects(language, [nodeNot literalLanguage], nil);			// language is now set
	STAssertTrue([nodeXML isXML], nil);
	STAssertFalse([nodeNot isXML], nil);
}

- (void)testBlank
{
	NSString *string = @"myBlankId";
	
	RedlandNode *node = [RedlandNode nodeWithBlankID:string];
	STAssertNotNil(node, nil);
	STAssertTrue([node isBlank], nil);
	STAssertEqualObjects(string, [node blankID], nil);
}

- (void)testBlankRandom
{
	RedlandNode *node1 = [RedlandNode nodeWithBlankID:nil];
	STAssertNotNil(node1, nil);
	RedlandNode *node2 = [RedlandNode nodeWithBlankID:nil];
	STAssertNotNil(node2, nil);
	STAssertFalse([node1 isEqual:node2], nil);
}

- (void)testResource
{
	RedlandURI *uri = [RedlandURI URIWithString:@"http://foo.com/"];
	
	RedlandNode *node = [RedlandNode nodeWithURI:uri];
	STAssertNotNil(node, nil);
	STAssertTrue([node isResource], nil);
	STAssertEqualObjects(uri, [node URIValue], nil);
}

- (void)testNodeEquality
{
	NSString *url1 = @"http://foo.com/";
	NSString *url2 = @"http://foo.com/#bar";
	NSString *url3 = @"http://foo.com/";
	
	RedlandNode *node1 = [RedlandNode nodeWithURIString:url1];
	RedlandNode *node2 = [RedlandNode nodeWithURIString:url2];
	RedlandNode *node3 = [RedlandNode nodeWithURIString:url3];
	STAssertFalse([node1 isEqual:node2], nil);
	STAssertEqualObjects(node1, node3, nil);
}

- (void)testLiteralInt
{
	RedlandNode *node = [RedlandNode nodeWithLiteralInt:12345];
	STAssertEquals(12345, [node intValue], nil);
	
	node = [RedlandNode nodeWithLiteral:@"12345" language:nil isXML:NO];
	STAssertThrowsSpecific([node intValue], RedlandException, nil);
}

- (void)testLiteralString
{
	NSString *string = @"Hello world";
	
	RedlandNode *node = [RedlandNode nodeWithLiteralString:string language:@"en"];
	STAssertNotNil(node, nil);
	STAssertEqualObjects(string, [node stringValue], nil);
	
	node = [RedlandNode nodeWithLiteral:string language:@"en" isXML:NO];
	STAssertThrowsSpecific([node stringValue], RedlandException, nil);
}

- (void)testLiteralBool
{
	RedlandNode *node = [RedlandNode nodeWithLiteralBool:TRUE];
	STAssertTrue([node boolValue], nil);
	
	node = [RedlandNode nodeWithLiteral:@"true" language:@"en" isXML:NO];
	STAssertThrowsSpecific([node boolValue], RedlandException, nil);
}

- (void)testLiteralFloatDouble
{
	RedlandNode *floatNode = [RedlandNode nodeWithLiteralFloat:M_PI];
	RedlandNode *doubleNode = [RedlandNode nodeWithLiteralDouble:M_PI];
	
	STAssertEqualsWithAccuracy((float)M_PI, [floatNode floatValue], 0.000001, nil);
	STAssertEqualsWithAccuracy((double)M_PI, [floatNode doubleValue], 0.000001, nil);
	STAssertThrowsSpecific([doubleNode floatValue], RedlandException, nil);
	STAssertEqualsWithAccuracy((double)M_PI, [doubleNode doubleValue], 0.0000000000001, nil);
}

- (void)testLiteralDateTime
{
	NSDate *date = [NSDate date];
	
	RedlandNode *node = [RedlandNode nodeWithLiteralDateTime:date];
	STAssertNotNil(node, nil);
	STAssertEqualsWithAccuracy((float)0.0f, (float)[date timeIntervalSinceDate:[node dateTimeValue]], 1.0f, nil);
	
	node = [RedlandNode nodeWithLiteralString:@"2004-09-16T20:36:18Z" language:nil];
	STAssertThrowsSpecific([node dateTimeValue], RedlandException, nil);
}

- (void)testArchiving
{
	RedlandNode *sourceNode = [RedlandNode nodeWithLiteralString:@"Hello world" language:@"en"];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sourceNode];
	STAssertNotNil(data, nil);
	RedlandNode *decodedNode = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	STAssertNotNil(decodedNode, nil);
	STAssertEqualObjects(sourceNode, decodedNode, nil);
}

- (void)testNodeValueConversion
{
	// The following test won't work because there seems to be no way to
	// distinguish a boolean NSNumber from an int NSNumber...
	//    UKObjectsEqual([RedlandNode nodeWithLiteralBool:YES],
	//                   [RedlandNode nodeWithObject:[NSNumber numberWithBool:YES]]);
	STAssertEqualObjects([RedlandNode nodeWithLiteralInt:12345], [RedlandNode nodeWithObject:[NSNumber numberWithInt:12345]], nil);
	STAssertEqualObjects([RedlandNode nodeWithLiteralFloat:1.2345f], [RedlandNode nodeWithObject:[NSNumber numberWithFloat:1.2345f]], nil);
	STAssertEqualObjects([RedlandNode nodeWithLiteralDouble:12.3456790], [RedlandNode nodeWithObject:[NSNumber numberWithDouble:12.3456790]], nil);
	STAssertEqualObjects([RedlandNode nodeWithLiteralString:@"foo" language:nil], [RedlandNode nodeWithObject:@"foo"], nil);
	STAssertEqualObjects([RedlandNode nodeWithURL:[NSURL URLWithString:@"http://foo"]], [RedlandNode nodeWithObject:[NSURL URLWithString:@"http://foo"]], nil);
	STAssertEqualObjects([RedlandNode nodeWithLiteralDateTime:[NSDate dateWithTimeIntervalSinceReferenceDate:0]], [RedlandNode nodeWithObject:[NSDate dateWithTimeIntervalSinceReferenceDate:0]], nil);
}

@end
