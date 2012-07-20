//
//  RedlandNamespace.h
//  Redland Objective-C Bindings
//  $Id: RedlandNamespace.h 307 2004-11-02 11:24:18Z kianga $
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

/*!
	@header RedlandNamespace.h
	Defines the RedlandNamespace class and global variables for some predefined namespaces.
*/

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

/*!
	@class RedlandNamespace
	@abstract Convenience class for generating namespaced nodes, URIs, and strings
	@discussion Instances of RedlandNamespace are helper objects which make it very easy to create RedlandNodes, RedlandURIs, NSStrings, or NSURLs with a common namespace prefix. Please note that this class is still experimental and its API is subject to change.
*/
@interface RedlandNamespace : NSObject <NSCopying> {
    NSString *prefix;
    NSString *shortName;
}

/*!
	@method initGlobalNamespaces
	@abstract Initialises the global variables for various predefined namespaces.
	@discussion There is no need to call this method directly. It is automatically invoked during initialization of the RedlandWorld class.
*/
+ (void)initGlobalNamespaces;

/*!
    @method namespaceWithShortName:
    @abstract Returns a pre-registered instance with the given short name.
    @discussion This method allows you to retrieve previously registered namespace instances by their short name. For example, if you call [RDFSyntaxNS registerInstance], you can then get this instance by calling: [RedlandNamespace namespaceWithShortName:\@"rdf"].
*/
+ (RedlandNamespace *)namespaceWithShortName:(NSString *)shortName;

/*!
	@method initWithPrefix:shortName:
	@abstract Initialises the receiver with a given URI prefix and short name.
	@param aPrefix The URI prefix string which will be prepended to objects created by the new instance, e.g. <tt>http://purl.org/dc/elements/1.1/</tt>
	@param shortName The short name for this namespace, e.g. <tt>dc</tt>
	@result The newly initialised instance
	@discussion The shortName is currently not used, but may be used later to provide automatic shortening of URIs.
*/ 
- (id)initWithPrefix:(NSString *)aPrefix shortName:(NSString *)shortName;

/*!
    @method registerInstance
    @abstract Registers the current instance so it can be retrieved by calling [RedlandNamespace namespaceWithShortName:].
    @discussion Raises an exception if there is already an instance registered for the receiver's shortName. The receiver automatically unregisters itself when it is deallocated.
*/
- (void)registerInstance;

/*!
    @method unregisterInstance
    @abstract Removes the registration done by [RedlandNamespace registerInstance].
    @discussion Does nothing if the receiver is not registered.
*/
- (void)unregisterInstance;

/*!
	@method node:
	@abstract Returns a new RedlandNode of type resource whose URI value is the given suffix appended to the receiver's namespace.
	@param suffix The string to append to the receiver's namespace prefix
	@result The created RedlandNode instance
*/
- (RedlandNode *)node:(NSString *)suffix;

/*!
	@method URI:
	@abstract Returns a new RedlandURI by appending the given suffix to the receiver's namespace.
	@param suffix The string to append to the receiver's namespace prefix
	@result The created RedlandURI instance
*/
- (RedlandURI *)URI:(NSString *)suffix;

/*!
	@method URL:
	@abstract Returns a new NSURL by appending the given suffix to the receiver's namespace.
	@param suffix The string to append to the receiver's namespace prefix
	@result The created NSURL instance
*/
- (NSURL *)URL:(NSString *)suffix;

/*!
	@method string:
	@abstract Returns a new NSString by appending the given suffix to the receiver's namespace.
	@param suffix The string to append to the receiver's namespace prefix
	@result The created NSString instance
*/
- (NSString *)string:(NSString *)suffix;

/*!
	@method containsURIString:
	@abstract Returns YES if the given NSString begins with the same prefix as the receiver.
	@result YES if the prefixes are equal, otherwise NO.
*/
- (BOOL)containsURIString:(NSString *)uriString;

/*!
	@method containsNode:
	@abstract Returns YES if the resource URI of the given RedlandNode begins with the same prefix as the receiver.
	@result YES if the node is a resource node and the prefixes are equal, otherwise NO.
*/
- (BOOL)containsNode:(RedlandNode *)aNode;

/*!
	@method containsURI:
	@abstract Returns YES if the given RedlandURI begins with the same prefix as the receiver.
	@result YES if the prefixes are equal, otherwise NO.
*/
- (BOOL)containsURI:(RedlandURI *)aURI;

/*!
	@method localNameOfURIString:
	@abstract Returns the local name of the given string in the receiver's namespace.
	@param aString A URI string
	@result A string generated by stripping the receiver's namespace prefix from the beginning of aString. If the string does not begin with the same prefix as the receiver, nil is returned.
*/
- (NSString *)localNameOfURIString:(NSString *)aString;

/*!
	@method localNameOfNode:
	@abstract Returns the local name of the given RedlandNode in the receiver's namespace.
	@param aNode A RedlandNode of type resource
	@result A string generated by stripping the receiver's namespace prefix from the beginning of aNode's resource URI. If the node's resource URI does not begin with the same prefix as the receiver, or if the node is not of type resource, nil is returned.
*/
- (NSString *)localNameOfNode:(RedlandNode *)aNode;

/*!
	@method localNameOfURI:
	@abstract Returns the local name of the given RedlandURI in the receiver's namespace.
	@param aURI A RedlandURI
	@result A string generated by stripping the receiver's namespace prefix from the beginning of aURI. If the URI does not begin with the same prefix as the receiver, nil is returned.
*/
- (NSString *)localNameOfURI:(RedlandURI *)aURI;

/*! 
	@method shortName
	@abstract Returns the shortName of the receiver.
*/
- (NSString *)shortName;

/*!
	@method prefix
	@abstract Returns the namespace prefix of the receiver.
*/
- (NSString *)prefix;
@end

@interface RedlandSerializer (NamespaceConvenience)
/*!
    @method addNamespace:
    @abstract Adds the URI-to-prefix mapping of the specified namespace to the receiver.
*/
- (void)addNamespace:(RedlandNamespace *)aNamespace;
@end
