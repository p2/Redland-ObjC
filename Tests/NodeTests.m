//
//  NodeTests.m
//  Redland Objective-C Bindings
//  $Id: NodeTests.m 4 2004-09-25 15:49:17Z kianga $
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

#import "NodeTests.h"
#import "RedlandNode.h"
#import "RedlandNode-Convenience.h"
#import "RedlandURI.h"
#import "RedlandException.h"

@implementation NodeTests

- (void)testLiteral
{
    RedlandNode *node;
    NSString *string = @"Hello world";
    NSString *language = @"en";
    RedlandURI *typeURI = [RedlandURI URIWithString:@"http://foo/"];

    node = [RedlandNode nodeWithLiteral:string language:language type:typeURI];
    STAssertNotNil(node, nil);
    STAssertTrue([node isLiteral], nil);
    STAssertEqualObjects(string, [node literalValue], nil);
    STAssertEqualObjects(language, [node literalLanguage], nil);
    STAssertEqualObjects(typeURI, [node literalDataType], nil);
    STAssertFalse([node isXML], nil);
}

- (void)testLiteralXML
{
    RedlandNode *node;
    NSString *string = @"<hello>world</hello>";
    NSString *language = @"en";
    
    node = [RedlandNode nodeWithLiteral:string language:language isXML:YES];
    STAssertNotNil(node, nil);
    STAssertTrue([node isLiteral], nil);
    STAssertEqualObjects(string, [node literalValue], nil);
    STAssertEqualObjects(language, [node literalLanguage], nil);
    STAssertTrue([node isXML], nil);
}

- (void)testBlank
{
    RedlandNode *node;
    NSString *string = @"myBlankId";
    
    node = [RedlandNode nodeWithBlankID:string];
    STAssertNotNil(node, nil);
    STAssertTrue([node isBlank], nil);
    STAssertEqualObjects(string, [node blankID], nil);
}

- (void)testBlankRandom
{
    RedlandNode *node1, *node2;
    
    node1 = [RedlandNode nodeWithBlankID:nil];
    STAssertNotNil(node1, nil);
    node2 = [RedlandNode nodeWithBlankID:nil];
    STAssertNotNil(node2, nil);
    STAssertFalse([node1 isEqual:node2], nil);
}

- (void)testResource
{
    RedlandNode *node;
    RedlandURI *uri = [RedlandURI URIWithString:@"http://foo.com/"];
    
    node = [RedlandNode nodeWithURI:uri];
    STAssertNotNil(node, nil);
    STAssertTrue([node isResource], nil);
    STAssertEqualObjects(uri, [node URIValue], nil);
}

- (void)testNodeEquality
{
    RedlandNode *node1, *node2, *node3;
    NSString *url1 = @"http://foo.com/";
    NSString *url2 = @"http://foo.com/#bar";
    NSString *url3 = @"http://foo.com/";
    
    node1 = [RedlandNode nodeWithURIString:url1];
    node2 = [RedlandNode nodeWithURIString:url2];
    node3 = [RedlandNode nodeWithURIString:url3];
    STAssertFalse([node1 isEqual:node2], nil);
    STAssertEqualObjects(node1, node3, nil);
}

- (void)testLiteralInt
{
    RedlandNode *node;
    
    node = [RedlandNode nodeWithLiteralInt:12345];
	STAssertEquals(12345, [node intValue], nil);
    
    node = [RedlandNode nodeWithLiteral:@"12345" language:nil isXML:NO];
    STAssertThrowsSpecific([node intValue], RedlandException, nil);
}

- (void)testLiteralString
{
    RedlandNode *node;
    NSString *string = @"Hello world";
    
    node = [RedlandNode nodeWithLiteralString:string language:@"en"];
    STAssertEqualObjects(string, [node stringValue], nil);
    
    node = [RedlandNode nodeWithLiteral:string language:@"en" isXML:NO];
    STAssertThrowsSpecific([node stringValue], RedlandException, nil);
}

- (void)testLiteralBool
{
    RedlandNode *node;
    
    node = [RedlandNode nodeWithLiteralBool:TRUE];
    STAssertTrue([node boolValue], nil);
    
    node = [RedlandNode nodeWithLiteral:@"true" language:@"en" isXML:NO];
    STAssertThrowsSpecific([node boolValue], RedlandException, nil);
}

- (void)testLiteralFloatDouble
{
    RedlandNode *floatNode, *doubleNode;
    
    floatNode = [RedlandNode nodeWithLiteralFloat:M_PI];
    doubleNode = [RedlandNode nodeWithLiteralDouble:M_PI];
    
    STAssertEqualsWithAccuracy((float)M_PI, [floatNode floatValue], 0.1, nil);
    STAssertEqualsWithAccuracy((double)M_PI, [floatNode doubleValue], 0.1, nil);
    STAssertThrowsSpecific((float)[doubleNode floatValue], RedlandException, nil);
    STAssertEqualsWithAccuracy((double)M_PI, [doubleNode doubleValue], 0.1, nil);
}

- (void)testLiteralDateTime
{
    NSDate *date = [NSDate date];
    RedlandNode *node;
    
    node = [RedlandNode nodeWithLiteralDateTime:date];
    STAssertNotNil(node, nil);
    STAssertEqualsWithAccuracy((float)0.0f, (float)[date timeIntervalSinceDate:[node dateTimeValue]], 1.0f, nil);
    
    node = [RedlandNode nodeWithLiteralString:@"2004-09-16T20:36:18Z" language:nil];
    STAssertThrowsSpecific([node dateTimeValue], RedlandException, nil);
}

- (void)testArchiving
{
    RedlandNode *sourceNode;
    RedlandNode *decodedNode;
    NSData *data;
    
    sourceNode = [RedlandNode nodeWithLiteralString:@"Hello world" language:@"en"];
    data = [NSArchiver archivedDataWithRootObject:sourceNode];
    STAssertNotNil(data, nil);
    decodedNode = [NSUnarchiver unarchiveObjectWithData:data];
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
    STAssertEqualObjects([RedlandNode nodeWithLiteralString:@"foo" language:nil], [RedlandNode nodeWithObject:@"foo"], nil);
    STAssertEqualObjects([RedlandNode nodeWithURL:[NSURL URLWithString:@"http://foo"]], [RedlandNode nodeWithObject:[NSURL URLWithString:@"http://foo"]], nil);
    STAssertEqualObjects([RedlandNode nodeWithLiteralDateTime:[NSDate dateWithTimeIntervalSinceReferenceDate:0]], [RedlandNode nodeWithObject:[NSDate dateWithTimeIntervalSinceReferenceDate:0]], nil);
}

@end
