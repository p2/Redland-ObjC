//
//  RedlandWrappedObject.h
//  Redland Objective-C Bindings
//  $Id: RedlandWrappedObject.h 307 2004-11-02 11:24:18Z kianga $
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

/*!
	@header RedlandWrappedObject.h
	Defines the RedlandWrappedObject class.
*/

/*!
	@class RedlandWrappedObject
	@abstract The abstract base class for all wrapped Redland objects.
	@discussion Every object in this framework which maps directly to one of the underlying librdf pseudoclasses is implemented as a subclass of RedlandWrappedObject.
*/

@interface RedlandWrappedObject : NSObject {
    void *wrappedObject;
    BOOL isWrappedObjectOwner;
}

/*!
	@method initWithWrappedObject:
	@abstract Initialises the receiver to use the given pointer as its underlying wrapped object. The receiver is considered the owner of the object.
	@param object The pointer to the librdf object
*/
- (id)initWithWrappedObject:(void *)object;

/*!
	@method initWithWrappedObject:owner:
	@abstract Initialises the receiver to use the given pointer as its underlying wrapped object.
	@param object The pointer to the librdf object
	@param ownerFlag If TRUE, the receiver considers itself the owner of the underlying librdf object and will possibly free it when the receiver is deallocated.
*/
- (id)initWithWrappedObject:(void *)object owner:(BOOL)ownerFlag;
@end
