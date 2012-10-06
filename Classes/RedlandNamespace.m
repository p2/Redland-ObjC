//
//  RedlandNamespace.m
//  Redland Objective-C Bindings
//  $Id: RedlandNamespace.m 4 2004-09-25 15:49:17Z kianga $
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


#pragma mark -
/**
 *  Initialises the global variables for various predefined namespaces.
 *  @warning There is no need to call this method directly. It is automatically invoked during initialization of the RedlandWorld class.
 */
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

/**
 *  Initialises the receiver with a given URI prefix and short name.
 *  @param aPrefix The URI prefix string which will be prepended to objects created by the new instance, e.g. <tt>http://purl.org/dc/elements/1.1/</tt>
 *  @param aName The short name for this namespace, e.g. <tt>dc</tt>
 *  @return The newly initialised instance
 *  @warning The shortName is currently not used, but may be used later to provide automatic shortening of URIs.
 */
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
    return [[[self class] allocWithZone:aZone] initWithPrefix:_prefix shortName:_shortName];
}

- (NSUInteger)hash
{
    return [_prefix hash] ^ [_shortName hash];
}



#pragma mark - Registration
/**
 *  Returns a pre-registered instance with the given short name.
 *  @warning This method allows you to retrieve previously registered namespace instances by their short name. For example, if you call
 *  [RDFSyntaxNS registerInstance], you can then get this instance by calling: [RedlandNamespace namespaceWithShortName:\@"rdf"].
 *  @warning Under ARC, this method returns a strong reference.
 */
+ (RedlandNamespace *)namespaceWithShortName:(NSString *)aName
{
	return [[GlobalNamespaceDict objectForKey:aName] nonretainedObjectValue];
}

/**
 *  Registers the current instance so it can be retrieved by calling [RedlandNamespace namespaceWithShortName:].
 *  @warning Raises an exception if there is already an instance registered for the receiver's shortName. The receiver automatically unregisters itself when it is deallocated.
 */
- (void)registerInstance
{
	NSAssert1([GlobalNamespaceDict objectForKey:_shortName] == nil, @"Namespace with short name %@ already registered", _shortName);
	
	NSValue *nonretained = [NSValue valueWithNonretainedObject:self];
	[GlobalNamespaceDict setObject:nonretained forKey:_shortName];
}

/**
 *  Removes the registration done by [RedlandNamespace registerInstance].
 *  @warning Does nothing if the receiver is not registered.
 *  @warning Because "+namespaceWithShortName:" returns a strong reference under ARC, we have to query "GlobalNamespaceDict" directly instead since
 *  this method is called from within "dealloc".
 */
- (void)unregisterInstance
{
	NSValue *existing = [GlobalNamespaceDict objectForKey:_shortName];
	if (self == [existing nonretainedObjectValue]) {
		[GlobalNamespaceDict removeObjectForKey:_shortName];
	}
}



#pragma mark - Factory Methods
/**
 *  Returns a new RedlandNode of type resource whose URI value is the given suffix appended to the receiver's namespace.
 *  @param suffix The string to append to the receiver's namespace prefix
 *  @return The created RedlandNode instance
 */
- (RedlandNode *)node:(NSString *)suffix
{
    NSParameterAssert(suffix != nil);
    return [RedlandNode nodeWithURIString:[self string:suffix]];
}

/**
 *  Returns a new RedlandURI by appending the given suffix to the receiver's namespace.
 *  @param suffix The string to append to the receiver's namespace prefix
 *  @return The created RedlandURI instance
 */
- (RedlandURI *)URI:(NSString *)suffix
{
    NSParameterAssert(suffix != nil);
    return [RedlandURI URIWithString:[self string:suffix]];
}

/**
 *  Returns a new NSURL by appending the given suffix to the receiver's namespace.
 *  @param suffix The string to append to the receiver's namespace prefix
 *  @return The created NSURL instance
 */
- (NSURL *)URL:(NSString *)suffix
{
    NSParameterAssert(suffix != nil);
    return [NSURL URLWithString:[self string:suffix]];
}

/**
 *  Returns a new NSString by appending the given suffix to the receiver's namespace.
 *  @param suffix The string to append to the receiver's namespace prefix
 *  @return The created NSString instance
 */
- (NSString *)string:(NSString *)suffix
{
    NSParameterAssert(suffix != nil);
    return [_prefix stringByAppendingString:suffix];
}



#pragma mark - Property Checks
/**
 *  Returns YES if the given NSString begins with the same prefix as the receiver.
 *  @return YES if the prefixes are equal, otherwise NO.
 */
- (BOOL)containsURIString:(NSString *)qName
{
    NSParameterAssert(qName != nil);
    return [qName hasPrefix:_prefix];
}

/**
 *  Returns YES if the resource URI of the given RedlandNode begins with the same prefix as the receiver.
 *  @return YES if the node is a resource node and the prefixes are equal, otherwise NO.
 */
- (BOOL)containsNode:(RedlandNode *)node
{
    NSParameterAssert(node != nil);
    return [self containsURIString:[node URIStringValue]];
}

/**
 *  Returns YES if the given RedlandURI begins with the same prefix as the receiver.
 *  @return YES if the prefixes are equal, otherwise NO.
 */
- (BOOL)containsURI:(RedlandURI *)aURI
{
    NSParameterAssert(aURI != nil);
    return [self containsURIString:[aURI stringValue]];
}



#pragma mark - Properties
/**
 *  Returns the local name of the given string in the receiver's namespace.
 *  @param qName A URI string
 *  @return A string generated by stripping the receiver's namespace prefix from the beginning of aString. If the string does not begin with the same prefix as
 *  the receiver, nil is returned.
 */
- (NSString *)localNameOfURIString:(NSString *)qName
{
    NSParameterAssert(qName != nil);
    if ([self containsURIString:qName])
        return [qName substringFromIndex:[_prefix length]];
    else
        return nil;
}

/**
 *  Returns the local name of the given RedlandNode in the receiver's namespace.
 *  @param aNode A RedlandNode of type resource
 *  @return A string generated by stripping the receiver's namespace prefix from the beginning of aNode's resource URI. If the node's resource URI does not
 *  begin with the same prefix as the receiver, or if the node is not of type resource, nil is returned.
 */
- (NSString *)localNameOfNode:(RedlandNode *)aNode
{
    NSParameterAssert(aNode != nil);
    return [self localNameOfURIString:[aNode URIStringValue]];
}

/**
 *  Returns the local name of the given RedlandURI in the receiver's namespace.
 *  @param aURI A RedlandURI
 *  @return A string generated by stripping the receiver's namespace prefix from the beginning of aURI. If the URI does not begin with the same prefix as the
 *  receiver, nil is returned.
 */
- (NSString *)localNameOfURI:(RedlandURI *)aURI
{
    NSParameterAssert(aURI != nil);
    return [self localNameOfURIString:[aURI stringValue]];
}

@end


@implementation RedlandSerializer (NamespaceConvenience)

/**
 *  Adds the URI-to-prefix mapping of the specified namespace to the receiver.
 */
- (void)addNamespace:(RedlandNamespace *)aNamespace
{
	[self setPrefix:[aNamespace shortName] 
	forNamespaceURI:[RedlandURI URIWithString:[aNamespace prefix]]];
}


@end
