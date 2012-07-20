//
//  RedlandNode.h
//  Redland Objective-C Bindings
//  $Id: RedlandNode.h 313 2004-11-03 19:00:40Z kianga $
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
	@header RedlandNode.h
	Defines the RedlandNode class.
*/

#import <Foundation/Foundation.h>
#import <Redland/redland.h>
#import "RedlandWrappedObject.h"

@class RedlandURI;

/*!
	@class RedlandNode
	@abstract A RedlandNode represents a single node in an RDF graph.
	@discussion Wraps librdf_node objects. A node can be of three different types:
 
		* Resource: A node representing a resource which is identified by a URI.
		* Blank: A node which represents an anonymous resource. The node is identified by a blank node ID.
		* Literal: A node representing a literal value in form of a string.
*/
@interface RedlandNode : RedlandWrappedObject <NSCopying, NSCoding> {
}

+ (id)nodeWithLiteral:(NSString *)aString language:(NSString *)aLanguage type:(RedlandURI *)typeURI;

/*! 
	@method initWithLiteral:language:type:
	@abstract Initializes a new RedlandNode containing a literal, with an optional language and a datatype URI.
	@param aString The literal string
	@param aLanguage The language of the literal string (may be nil)
	@param typeURI The datatype URI
*/
- (id)initWithLiteral:(NSString *)aString language:(NSString *)aLanguage type:(RedlandURI *)typeURI;

/*!
	@method nodeWithLiteral:
	@abstract Returns an autoreleased literal RedlandNode with the given string value. No language or datatype are specified.
	@param aString The literal string
*/
+ (id)nodeWithLiteral:(NSString *)aString;

/*!
    @method nodeWithLiteral:language:isXML:
    @abstract Returns an autoreleased RedlandNode containing a literal with an an optional language and XML flag.
	@param aString The literal string
	@param aLanguage The language of the literal string (may be nil)
	@param xmlFlag If TRUE, the node is marked as containing well-formed XML data. 
 */
+ (id)nodeWithLiteral:(NSString *)aString language:(NSString *)aLanguage isXML:(BOOL)xmlFlag;

/*! 
	@method initWithLiteral:language:isXML:
	@abstract Initializes a new RedlandNode containing a literal with an optional language and XML flag.
	@param aString The literal string
	@param aLanguage The language of the literal string (may be nil)
	@param xmlFlag If TRUE, the node is marked as containing well-formed XML data. 
*/
- (id)initWithLiteral:(NSString *)aString language:(NSString *)aLanguage isXML:(BOOL)xmlFlag;

/*!
    @method nodeWithURIString:
    @abstract Returns an autoreleased node representing a resource with the given URI.
	@param aString The URI as a string value.
*/
+ (id)nodeWithURIString:(NSString *)aString;

/*!
	@method initWithURIString:
	@abstract Initializes a new RedlandNode representing a resource with the given URI.
	@param aString The URI as a string value.
*/
- (id)initWithURIString:(NSString *)aString;

/*!
    @method nodeWithURI:
    @abstract Returns an autoreleased RedlandNode representing a resource with the given URI.
*/
+ (id)nodeWithURI:(RedlandURI *)aURI;

/*!
	@method initWithURI:
	@abstract Initializes a RedlandNode representing a resource with the given URI.
	@param aURI The URI as a RedlandURI.
*/
- (id)initWithURI:(RedlandURI *)aURI;

/*!
    @method nodeWithBlankID:
    @abstract Returns an autoreleased RedlandNode with the specified node ID.
*/
+ (id)nodeWithBlankID:(NSString *)anID;

/*! 
	@method initWithBlankID:
	@abstract Initializes a blank RedlandNode with the specified node ID.
	@param anID The blank node ID. If nil, a new ID is generated.
*/
- (id)initWithBlankID:(NSString *)anID;

/*!
	@method wrappedNode
	@abstract Returns the underlying librdf_node object of the receiver.
*/
- (librdf_node *)wrappedNode;

/*! 
	@method type
	@abstract Returns the node type of the receiver.
	@result Possible values include LIBRDF_NODE_TYPE_RESOURCE, LIBRDF_NODE_TYPE_LITERAL, and LIBRDF_NODE_TYPE_BLANK.
*/
- (librdf_node_type)type;

/*! 
	@method isLiteral
	@abstract Returns YES if the receiver is a literal node.
*/
- (BOOL)isLiteral;

/*! 
	@method isResource
	@abstract Returns YES if the receiver is a resource (i.e. if it has a URI)
*/
- (BOOL)isResource;

/*!
	@method isBlank
	@abstract Returns YES if the receiver is a blank node.
*/
- (BOOL)isBlank;

/*! 
	@method isXML
	@abstract Returns YES if the receiver is a literal node and contains well-formed XML data.
*/
- (BOOL)isXML;

/*!
	@method literalDataType
	@abstract Returns the literal datatype URI of the receiver (literal nodes only).
*/
- (RedlandURI *)literalDataType;

/*! 
	@method literalValue
	@abstract Returns the literal value of the receiver (literal nodes only). 
*/
- (NSString *)literalValue;

/*! 
	@method literalLanguage
	@abstract Returns the XML language of the receiver (literal nodes only). 
*/
- (NSString *)literalLanguage;

/*! 
	@method URIValue
	@abstract Returns the resource of the receiver as an RedlandURI object (resource nodes only).
*/
- (RedlandURI *)URIValue;

/*! 
	@method blankID
	@abstract Returns the blank node ID of the receiver (blank nodes only).
*/
- (NSString *)blankID;

/*! 
	@method ordinalValue
	@abstract Returns the ordinal value of the reciever (for rdf:li nodes).
*/
- (int)ordinalValue;

/*! 
	@method isEqualToNode:
	@abstract Returns YES if the receiver is equal to otherNode. 
	@param otherNode The node to compare the receiver to
*/
- (BOOL)isEqualToNode:(RedlandNode *)otherNode;

@end
