//
//  RedlandNode.h
//  Redland Objective-C Bindings
//  $Id: RedlandNode.h 313 2004-11-03 19:00:40Z kianga $
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
#import <redland.h>
#import "RedlandWrappedObject.h"

@class RedlandURI;


/**
 *  A RedlandNode represents a single node in an RDF graph.
 *
 *  The different node types are:
 *  
 *  - Resource: A node representing a resource which is identified by a URI.
 *  - Blank: A node which represents an anonymous resource. The node is identified by a blank node ID.
 *  - Literal: A node representing a literal value in form of a string.
 *
 */
@interface RedlandNode : RedlandWrappedObject <NSCopying, NSCoding>

+ (id)nodeWithLiteral:(NSString *)aString;
+ (id)nodeWithLiteral:(NSString *)aString language:(NSString *)aLanguage type:(RedlandURI *)typeURI;
- (id)initWithLiteral:(NSString *)aString language:(NSString *)aLanguage type:(RedlandURI *)typeURI;

+ (id)nodeWithLiteral:(NSString *)aString language:(NSString *)aLanguage isXML:(BOOL)xmlFlag;
- (id)initWithLiteral:(NSString *)aString language:(NSString *)aLanguage isXML:(BOOL)xmlFlag;

+ (id)nodeWithURIString:(NSString *)aString;
- (id)initWithURIString:(NSString *)aString;

+ (id)nodeWithURI:(RedlandURI *)aURI;
- (id)initWithURI:(RedlandURI *)aURI;

+ (id)nodeWithBlankID:(NSString *)anID;
- (id)initWithBlankID:(NSString *)anID;

- (librdf_node *)wrappedNode;
- (librdf_node_type)type;

- (BOOL)isLiteral;
- (BOOL)isResource;
- (BOOL)isBlank;
- (BOOL)isXML;

- (RedlandURI *)literalDataType;
- (NSString *)literalValue;
- (NSString *)literalLanguage;
- (RedlandURI *)URIValue;
- (NSString *)blankID;
- (int)ordinalValue;

- (BOOL)isEqualToNode:(RedlandNode *)otherNode;


@end
