//
//  NamespaceTests.m
//  Redland Objective-C Bindings
//  $Id: NamespaceTests.m 4 2004-09-25 15:49:17Z kianga $
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

#import "NamespaceTests.h"
#import "RedlandNamespace.h"
#import "RedlandURI.h"
#import "RedlandWorld.h"

@implementation NamespaceTests

- (void)testPredefined
{
	[RedlandWorld defaultWorld]; // make sure that global instances are initialized
    STAssertNotNil(XMLSchemaNS, nil);
	STAssertNotNil(RDFSyntaxNS, nil);
	STAssertNotNil(RDFSchemaNS, nil);
	STAssertNotNil(DublinCoreNS, nil);
}

- (void)testURI
{
    RedlandNamespace *schemaNS;
    RedlandURI *uri;
    
    schemaNS = [[RedlandNamespace alloc] initWithPrefix:@"http://www.w3.org/2001/XMLSchema#"
                                           shortName:@"xmlschema"];
    uri = [RedlandURI URIWithString:@"http://www.w3.org/2001/XMLSchema#int"];
    STAssertEqualObjects(uri, [schemaNS URI:@"int"], nil);
	[schemaNS release];
}

- (void)testRegistration
{
	[RedlandWorld defaultWorld]; // make sure that global instances are initialized
	STAssertNoThrow([RDFSyntaxNS registerInstance], nil);
	STAssertThrows([RDFSyntaxNS registerInstance], nil);
	STAssertEquals(RDFSyntaxNS, [RedlandNamespace namespaceWithShortName:@"rdf"], nil);
	[RDFSyntaxNS unregisterInstance];
	STAssertNil([RedlandNamespace namespaceWithShortName:@"rdf"], nil);
}

- (void)testAutoUnregister
{
	RedlandNamespace *schemaNS;
    schemaNS = [[RedlandNamespace alloc] initWithPrefix:@"http://www.w3.org/2001/XMLSchema#"
											  shortName:@"xmlschema"];
	[schemaNS registerInstance];
	[schemaNS release];
	STAssertNil([RedlandNamespace namespaceWithShortName:@"xmlschema"], nil);
}

@end
