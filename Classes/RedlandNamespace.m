//
//  RedlandNamespace.m
//  Redland Objective-C Bindings
//  $Id: RedlandNamespace.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandNamespace.h"
#import "RedlandNode.h"
#import "RedlandNode-Convenience.h"
#import "RedlandURI.h"

RedlandNamespace *RedlandRDFSyntaxNS = nil;
RedlandNamespace *RDFSyntaxNS = nil;
RedlandNamespace *RedlandRDFSchemaNS = nil;
RedlandNamespace *RDFSchemaNS = nil;
RedlandNamespace *RedlandXMLSchemaNS = nil;
RedlandNamespace *XMLSchemaNS = nil;
RedlandNamespace *RedlandDublinCoreNS = nil;
RedlandNamespace *DublinCoreNS = nil;

static NSMutableDictionary *GlobalNamespaceDict = nil;

@implementation RedlandNamespace

@synthesize prefix = _prefix;
@synthesize shortName = _shortName;

+ (void)initGlobalNamespaces
{
    if (RedlandRDFSyntaxNS == nil) {
        RedlandRDFSyntaxNS = RDFSyntaxNS = [[self alloc] initWithPrefix:@"http://www.w3.org/1999/02/22-rdf-syntax-ns#" shortName:@"rdf"];
	}
    if (RedlandRDFSchemaNS == nil) {
        RedlandRDFSchemaNS = RDFSchemaNS = [[self alloc] initWithPrefix:@"http://www.w3.org/2000/01/rdf-schema#" shortName:@"rdfs"];
	}
    if (RedlandXMLSchemaNS == nil) {
        RedlandXMLSchemaNS = XMLSchemaNS = [[self alloc] initWithPrefix:@"http://www.w3.org/2001/XMLSchema#" shortName:@"xmlschema"];
	}
    if (RedlandDublinCoreNS == nil) {
        RedlandDublinCoreNS = DublinCoreNS = [[self alloc] initWithPrefix:@"http://purl.org/dc/elements/1.1/" shortName:@"dc"];
	}
}

+ (void)initialize
{
	if (GlobalNamespaceDict == nil) {
		GlobalNamespaceDict = [NSMutableDictionary new];
	}
}

+ (RedlandNamespace *)namespaceWithShortName:(NSString *)aName
{
	return [GlobalNamespaceDict objectForKey:aName];
}

- (id)initWithPrefix:(NSString *)aPrefix shortName:(NSString *)aName
{
    NSParameterAssert(aPrefix != nil);
    NSParameterAssert(aName != nil);
    
    if ((self = [super init])) {
        self.prefix = aPrefix;
        self.shortName = aName;
    }
    return self;
}

- (void)dealloc
{
	[self unregisterInstance];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[isa allocWithZone:aZone] initWithPrefix:_prefix shortName:_shortName];
}

- (NSUInteger)hash
{
    return [_prefix hash] ^ [_shortName hash];
}

- (void)registerInstance
{
	NSAssert1([RedlandNamespace namespaceWithShortName:_shortName] == nil, @"Namespace with short name %@ already registered", _shortName);
	[GlobalNamespaceDict setObject:self forKey:_shortName];
}

- (void)unregisterInstance
{
	if (self == [RedlandNamespace namespaceWithShortName:_shortName]) {
		[GlobalNamespaceDict removeObjectForKey:_shortName];
	}
}

- (RedlandNode *)node:(NSString *)suffix
{
    NSParameterAssert(suffix != nil);
    return [RedlandNode nodeWithURIString:[self string:suffix]];
}

- (RedlandURI *)URI:(NSString *)suffix
{
    NSParameterAssert(suffix != nil);
    return [RedlandURI URIWithString:[self string:suffix]];
}

- (NSURL *)URL:(NSString *)suffix
{
    NSParameterAssert(suffix != nil);
    return [NSURL URLWithString:[self string:suffix]];
}

- (NSString *)string:(NSString *)suffix
{
    NSParameterAssert(suffix != nil);
    return [_prefix stringByAppendingString:suffix];
}

- (BOOL)containsURIString:(NSString *)qName
{
    NSParameterAssert(qName != nil);
    return [qName hasPrefix:_prefix];
}

- (BOOL)containsNode:(RedlandNode *)node
{
    NSParameterAssert(node != nil);
    return [self containsURIString:[node URIStringValue]];
}

- (BOOL)containsURI:(RedlandURI *)aURI
{
    NSParameterAssert(aURI != nil);
    return [self containsURIString:[aURI stringValue]];
}

- (NSString *)localNameOfURIString:(NSString *)qName
{
    NSParameterAssert(qName != nil);
    if ([self containsURIString:qName])
        return [qName substringFromIndex:[_prefix length]];
    else
        return nil;
}

- (NSString *)localNameOfNode:(RedlandNode *)aNode
{
    NSParameterAssert(aNode != nil);
    return [self localNameOfURIString:[aNode URIStringValue]];
}

- (NSString *)localNameOfURI:(RedlandURI *)aURI
{
    NSParameterAssert(aURI != nil);
    return [self localNameOfURIString:[aURI stringValue]];
}

@end

@implementation RedlandSerializer (NamespaceConvenience)

- (void)addNamespace:(RedlandNamespace *)aNamespace
{
	[self setPrefix:[aNamespace shortName] 
	forNamespaceURI:[RedlandURI URIWithString:[aNamespace prefix]]];
}

@end
