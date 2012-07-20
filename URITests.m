//
//  URITests.m
//  Redland Objective-C Bindings
//  $Id: URITests.m 4 2004-09-25 15:49:17Z kianga $
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

#import "URITests.h"
#import "RedlandURI.h"

@implementation URITest

- (void)testStringInit
{
    RedlandURI *myURI;
    NSString *testString = @"http://www.example.com/";
    myURI = [[RedlandURI alloc] initWithString:testString];
    STAssertNotNil(myURI, nil);
    STAssertEqualObjects(testString, [myURI stringValue], nil);
    [myURI release];
}

- (void)testURLInit
{
    RedlandURI *myURI;
    NSURL *testURL = [NSURL URLWithString:@"http://www.example.com/"];
    myURI = [RedlandURI URIWithURL:testURL];
    STAssertNotNil(myURI, nil);
    STAssertEqualObjects(testURL, [myURI URLValue], nil);
    STAssertEqualObjects([testURL absoluteString], [myURI stringValue], nil);
}

- (void)testComparing
{
    NSString *firstString = @"http://www.example.com/1";
    NSString *secondString = @"http://www.example.com/2";
    RedlandURI *firstURI, *secondURI, *firstCopyURI;
    firstURI = [RedlandURI URIWithString:firstString];
    secondURI = [RedlandURI URIWithString:secondString];
    firstCopyURI = [RedlandURI URIWithString:firstString];
    STAssertEqualObjects(firstURI, firstURI, nil);
    STAssertFalse([firstURI isEqual:secondURI], nil);
    STAssertEqualObjects(firstURI, firstCopyURI, nil);
}

- (void)testCopying
{
    RedlandURI *testURI = [RedlandURI URIWithString:@"http://www.foo.com/bar#test"];
    RedlandURI *copyURI = [[testURI copy] autorelease];
    STAssertEqualObjects(testURI, copyURI, nil);
}

@end
