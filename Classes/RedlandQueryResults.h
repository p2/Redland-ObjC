//
//  RedlandQueryResults.h
//  Redland Objective-C Bindings
//  $Id: RedlandQueryResults.h 654 2005-02-06 19:06:48Z kianga $
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

/**
 *  @header RedlandQueryResults.h
	Defines the RedlandQueryResults class
*/

#import <Foundation/Foundation.h>
#import <redland.h>
#import "RedlandWrappedObject.h"

@class RedlandNode, RedlandStream, RedlandQueryResultsEnumerator, RedlandURI;


/**
 *  This class represents results from the execution of a RedlandQuery.
 *
 *  @warning Query results work almost like an enumerator. You can go through the results by invoking <tt>next</tt> and get the bindings for each result
 *  through the various methods defined below. For simplicity, it is recommended that you use the <tt>resultEnumerator</tt> method to get a standard Cocoa
 *  NSEnumerator of the results.
 */
@interface RedlandQueryResults : RedlandWrappedObject {
}

- (librdf_query_results *)wrappedQueryResults;

- (int)count;
- (BOOL)next;
- (BOOL)finished;

- (NSDictionary *)bindings;
- (int)countOfBindings;
- (RedlandNode *)valueOfBinding:(NSString *)aName;
- (RedlandNode *)valueOfBindingAtIndex:(int)offset;
- (NSString *)nameOfBindingAtIndex:(int)offset;

- (RedlandStream *)resultStream;
- (RedlandQueryResultsEnumerator *)resultEnumerator;

- (NSString *)stringRepresentationWithFormat:(RedlandURI *)formatURI baseURI:(RedlandURI *)baseURI;
- (NSString *)stringRepresentationWithName:(NSString *)name baseURI:(RedlandURI *)baseURI;
- (NSString *)stringRepresentationWithMimeType:(NSString *)MimeType baseURI:(RedlandURI *)baseURI;

- (BOOL)isBindings;
- (BOOL)isBoolean;
- (BOOL)isGraph;
- (int)getBoolean;


@end
