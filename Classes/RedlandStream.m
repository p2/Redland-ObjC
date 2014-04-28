//
//  RedlandStream.m
//  Redland Objective-C Bindings
//  $Id: RedlandStream.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandStream.h"
#import "RedlandStatement.h"
#import "RedlandNode.h"
#import "RedlandStreamEnumerator.h"

@implementation RedlandStream

- (void)dealloc
{
	if (isWrappedObjectOwner) {
		librdf_free_stream(wrappedObject);
	}
}



#pragma mark - Walking
/**
 *  Returns YES if there is a next statement.
	Note that the return value is the inverse of the corresponding C library function, which returns zero on success.
 */
- (BOOL)next
{
	return (0 == librdf_stream_next(wrappedObject));
}



#pragma mark - Accessors
/**
 *  Returns the underlying librdf_stream pointer of the receiver.
 */
- (librdf_stream *)wrappedStream
{
	return wrappedObject;
}

/**
 *  Returns the current object on the stream.
 */
- (RedlandStatement *)object
{
	librdf_statement *statement = librdf_stream_get_object(wrappedObject);
	if (!statement) {
		return nil;
	}
	
	statement = librdf_new_statement_from_statement(statement);
	return [[RedlandStatement alloc] initWithWrappedObject:statement];
}

/**
 *  Returns the context of the current object on the stream.
 */
- (RedlandNode *)context
{
	librdf_node *context = librdf_stream_get_context2(wrappedObject);
	if (context) {
		librdf_node *node = librdf_new_node_from_node(context);
		return [[RedlandNode alloc] initWithWrappedObject:node];
	}
	return nil;
}



#pragma mark - Utilities
/**
 *  Returns a RedlandStreamEnumerator for the receiver.
	It is recommended that you use this enumerator interface instead of accessing the stream directly.
 */
- (RedlandStreamEnumerator *)statementEnumerator
{
	return [[RedlandStreamEnumerator alloc] initWithRedlandStream:self];
}


@end
