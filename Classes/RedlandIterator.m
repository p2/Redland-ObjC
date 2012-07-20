//
//  RedlandIterator.m
//  Redland Objective-C Bindings
//  $Id: RedlandIterator.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandIterator.h"


@implementation RedlandIterator

- (void)dealloc
{
    if (isWrappedObjectOwner)
        librdf_free_iterator(wrappedObject);
    [super dealloc];
}

- (librdf_iterator *)wrappedIterator
{
	return wrappedObject;
}

- (void *)object
{
    return librdf_iterator_get_object(wrappedObject);
}

- (void *)value
{
    return librdf_iterator_get_value(wrappedObject);
}

- (void *)context
{
    return librdf_iterator_get_context(wrappedObject);
}

- (void *)key
{
    return librdf_iterator_get_key(wrappedObject);
}

- (BOOL)next
{
    return librdf_iterator_next(wrappedObject) == 0;
}

- (BOOL)end
{
    return librdf_iterator_end(wrappedObject);
}

@end
