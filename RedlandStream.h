//
//  RedlandStream.h
//  Redland Objective-C Bindings
//  $Id: RedlandStream.h 313 2004-11-03 19:00:40Z kianga $
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

#import <Foundation/Foundation.h>
#import <Redland/redland.h>
#import "RedlandWrappedObject.h"

/*!
	@header RedlandStream.h
	Defines the RedlandStream class.
*/

@class RedlandStatement, RedlandNode, RedlandStreamEnumerator;

/*!
	@class RedlandStream
	@abstract A RedlandStream represents a stream of statements. Streams are used as return values from parsers and query functions in the Redland library. It is recommended that you use the statementEnumerator function to access the stream, as it provides a more natural Cocoa interface using an NSEnumerator subclass.
*/

@interface RedlandStream : RedlandWrappedObject {
}

/*!
	@method wrappedStream
	@abstract Returns the underlying librdf_stream pointer of the receiver.
*/
- (librdf_stream *)wrappedStream;

/*!	
	@method next
	@abstract Returns YES if there is a next statement.
	@discussion Note that the return value is the inverse of the corresponding C library function, which returns zero on success.
*/
- (BOOL)next;

/*!
	@method object
	@abstract Returns the current object on the stream.
*/

- (RedlandStatement *)object;

/*!
	@method context
	@abstract Returns the context of the current object on the stream.
*/
- (RedlandNode *)context;

/*!
	@method print
	@abstract Prints out the stream to standard error.
	@discussion For debugging purposes.
*/
- (void)print;

/*!
	@method statementEnumerator
	@abstract Returns a RedlandStreamEnumerator for the receiver.
	@discussion It is recommended that you use this enumerator interface instead of accessing the stream directly.
*/
- (RedlandStreamEnumerator *)statementEnumerator;
@end
