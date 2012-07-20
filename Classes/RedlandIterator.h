//
//  RedlandIterator.h
//  Redland Objective-C Bindings
//  $Id: RedlandIterator.h 313 2004-11-03 19:00:40Z kianga $
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
	@header RedlandIterator.h
	Defines the RedlandIterator class.
*/

#import <Foundation/Foundation.h>
#import <Redland/redland.h>
#import "RedlandWrappedObject.h"

/*!
	@class RedlandIterator
	@abstract A direct wrapper around librdf_iterator.
	@discussion Implementation of this class is subject to change. Do not use.
*/

@interface RedlandIterator : RedlandWrappedObject {
}
/*! Returns the underlying librdf_iterator pointer of the receiver. */
- (librdf_iterator *)wrappedIterator;
/*! librdf_iterator_get_object */
- (void *)object;
/*! librdf_iterator_get_value */
- (void *)value;
/*! librdf_iterator_get_context */
- (void *)context;
/*! librdf_iterator_get_key */
- (void *)key;
/*! 
	@method next
	@abstract librdf_iterator_next
	@result Returns YES if there is a next object.
	@discussion Note that the return value is the inverse of the underlying C function.
*/
- (BOOL)next;
/*! librdf_iterator_end */
- (BOOL)end;
@end
