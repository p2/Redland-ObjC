//
//  RedlandQueryResults.h
//  Redland Objective-C Bindings
//  $Id: RedlandQueryResults.h 654 2005-02-06 19:06:48Z kianga $
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
	@header RedlandQueryResults.h
	Defines the RedlandQueryResults class
*/

#import <Foundation/Foundation.h>
#import <Redland/redland.h>
#import "RedlandWrappedObject.h"

@class RedlandNode, RedlandStream, RedlandQueryResultsEnumerator, RedlandURI;

/*!
	@class RedlandQueryResults
	@abstract This class represents results from the execution of a RedlandQuery.
	@discussion Query results work almost like an enumerator. You can go through the results by invoking <tt>next</tt> and get the bindings for each result through the various methods defined below. For simplicity, it is recommended that you use the <tt>resultEnumerator</tt> method to get a standard Cocoa NSEnumerator of the results.
*/
@interface RedlandQueryResults : RedlandWrappedObject {
}

/*!
	@method wrappedQueryResults
	@abstract Returns the underlying librdf_query_results object of the receiver.
*/
- (librdf_query_results *)wrappedQueryResults;

/*!
	@method count
	@abstract Returns the number of bindings so far
*/
- (int)count;

/*!
	@method next
	@abstract Advances to the next result.
	@result Returns YES if there is a next result, otherwise NO.
*/
- (BOOL)next;

/*!
	@method finished
	@abstract Returns YES if the query results are exhausted.
*/
- (BOOL)finished;

/*!
	@method bindings
	@abstract Returns a dictionary of the current result bindings.
*/
- (NSDictionary *)bindings;

/*!
	@method valueOfBindingAtIndex:
	@abstract Returns the current value of the binding at the given index.
*/
- (RedlandNode *)valueOfBindingAtIndex:(int)offset;

/*!
	@method nameOfBindingAtIndex:
	@abstract Returns the name of the binding at the given index.
*/
- (NSString *)nameOfBindingAtIndex:(int)offset;

/*!
	@method valueOfBinding:
	@abstract Returns the current value of the binding with the given name.
*/
- (RedlandNode *)valueOfBinding:(NSString *)aName;

/*!
	@method countOfBindings:
	@abstract Returns the number of bindings of the receiver.
*/
- (int)countOfBindings;

/*!
	@method stream
	@abstract Returns a stream of the query results.
*/
- (RedlandStream *)stream;

/*!
	@method resultEnumerator
	@abstract Returns an enumerator over the query results.
	@discussion This is the recommended way to evaluate query results.
*/
- (RedlandQueryResultsEnumerator *)resultEnumerator;

/*!
    @method stringRepresentationWithFormat:baseURI:
    @abstract Turns query results into a string in the specified format.
*/
- (NSString *)stringRepresentationWithFormat:(RedlandURI *)formatURI baseURI:(RedlandURI *)baseURI;

/*!
    @method isBindings
    @abstract Returns TRUE if the query results are in variable bindings format.
*/
- (BOOL)isBindings;

/*!
    @method isBoolean
    @abstract Returns TRUE if the query results are in boolean format.
*/
- (BOOL)isBoolean;

/*!
    @method isGraph
    @abstract Returns TRUE if the query results are in graph format.
*/
- (BOOL)isGraph;

/*!
	@method getBoolean;
    @abstract Get boolean query result.
    @result Returns >0 if true, 0 if false, <0 on error or finished
    @discussion The return value is only meaningful if this is a boolean query result.
*/
- (int)getBoolean;

/*! 
    @method resultStream:
    @abstract Returns an RDF graph of the results.
    @discussion The return value is only meaningful if this is an RDF graph query result.
*/
- (RedlandStream *)resultStream;
@end
