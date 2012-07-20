//
//  RedlandStream.m
//  Redland Objective-C Bindings
//  $Id: RedlandStream.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandStream.h"
#import "RedlandStatement.h"
#import "RedlandNode.h"
#import "RedlandStreamEnumerator.h"

@implementation RedlandStream

- (void)dealloc
{
    if (isWrappedObjectOwner)
        librdf_free_stream(wrappedObject);
	[super dealloc];
}

- (librdf_stream *)wrappedStream
{
    return wrappedObject;
}

- (BOOL)next
{
    return librdf_stream_next(wrappedObject) == 0;
}

- (RedlandStatement *)object
{
    librdf_statement *statement;
    statement = librdf_stream_get_object(wrappedObject);
    if (statement != NULL)
        statement = librdf_new_statement_from_statement(statement);
    return [[[RedlandStatement alloc] initWithWrappedObject:statement] autorelease];
}

- (RedlandNode *)context
{
    librdf_node *context;
    context = librdf_stream_get_context(wrappedObject);
	if (context)
		context = librdf_new_node_from_node(context);
    return [[[RedlandNode alloc] initWithWrappedObject:context] autorelease];
}

- (void)print
{
    librdf_stream_print(wrappedObject, stderr);
}

- (RedlandStreamEnumerator *)statementEnumerator
{
    return [[[RedlandStreamEnumerator alloc] initWithRedlandStream:self] autorelease];
}

@end
