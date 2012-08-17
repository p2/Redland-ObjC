//
//  RedlandNamespace.h
//  Redland Objective-C Bindings
//  $Id: RedlandNamespace.h 307 2004-11-02 11:24:18Z kianga $
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

#import <Foundation/Foundation.h>
#import "RedlandSerializer.h"

@class RedlandNode, RedlandURI, RedlandNamespace;

/*! A global RedlandNamespace instance representing the RDF syntax namespace <tt>http://www.w3.org/1999/02/22-rdf-syntax-ns#</tt> with the short name "rdf". */
extern RedlandNamespace *RedlandRDFSyntaxNS;
extern RedlandNamespace *RDFSyntaxNS;

/*! A global RedlandNamespace instance representing the RDF Schema namespace <tt>http://www.w3.org/2000/01/rdf-schema#</tt> with the short name "rdfs". */
extern RedlandNamespace *RedlandRDFSchemaNS;
extern RedlandNamespace *RDFSchemaNS;

/*! A global RedlandNamespace instance representing the XML Schema namespace <tt>http://www.w3.org/2001/XMLSchema#</tt> with the short name "xmlschema". */
extern RedlandNamespace *RedlandXMLSchemaNS;
extern RedlandNamespace *XMLSchemaNS;

/*! A global RedlandNamespace instance representing the Dublin Core metadata namespace <tt>http://purl.org/dc/elements/1.1/</tt> with the short name "dc". */
extern RedlandNamespace *RedlandDublinCoreNS;
extern RedlandNamespace *DublinCoreNS;


/**
 *  Convenience class for generating namespaced nodes, URIs, and strings.
 *
 *  Instances of RedlandNamespace are helper objects which make it very easy to create RedlandNodes, RedlandURIs, NSStrings, or NSURLs with a common namespace
 *  prefix. Please note that this class is still experimental and its API is subject to change.
 */
@interface RedlandNamespace : NSObject <NSCopying>

@property (nonatomic, copy) NSString *prefix;						///< The namespace prefix of the receiver
@property (nonatomic, copy) NSString *shortName;					///< The shortName of the receiver


+ (void)initGlobalNamespaces;

+ (RedlandNamespace *)namespaceWithShortName:(NSString *)shortName;
- (id)initWithPrefix:(NSString *)aPrefix shortName:(NSString *)shortName;

- (void)registerInstance;
- (void)unregisterInstance;

- (RedlandNode *)node:(NSString *)suffix;
- (RedlandURI *)URI:(NSString *)suffix;
- (NSURL *)URL:(NSString *)suffix;
- (NSString *)string:(NSString *)suffix;

- (BOOL)containsURIString:(NSString *)uriString;
- (BOOL)containsNode:(RedlandNode *)aNode;
- (BOOL)containsURI:(RedlandURI *)aURI;

- (NSString *)localNameOfURIString:(NSString *)aString;
- (NSString *)localNameOfNode:(RedlandNode *)aNode;
- (NSString *)localNameOfURI:(RedlandURI *)aURI;


@end


/**
 *  A category to add convenience methods to the Redland serializer.
 */
@interface RedlandSerializer (NamespaceConvenience)

- (void)addNamespace:(RedlandNamespace *)aNamespace;

@end
