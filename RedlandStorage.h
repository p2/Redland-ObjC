//
//  RedlandStorage.h
//  Redland Objective-C Bindings
//  $Id: RedlandStorage.h 313 2004-11-03 19:00:40Z kianga $
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
@header RedlandStorage.h
	Defines the RedlandStorage class
 */

#import <Foundation/Foundation.h>
#import <Redland/redland.h>
#import "RedlandWrappedObject.h"

/*!
	@class RedlandStorage
	@abstract This class provides storage for RDF models either in memory or persistant storage.
	@discussion The interface of this class is currently incomplete, as most methods are simply duplicates of the RedlandModel methods. If direct manipulation of the storage is necessary, you can use the standard C API on the underlying librdf_storage instead.
*/
@interface RedlandStorage : RedlandWrappedObject {
}
/*!
	@method storage
	@abstract Creates and returns an autoreleased in-memory, context-enabled hash storage.
 */
+ (RedlandStorage *)storage;

/*!
    @method init
    @abstract Initializes a new in-memory, context-enabled hash storage.
*/
- (id)init;

/*!
	@method wrappedStorage
	@abstract Returns the underlying librdf_storage pointer of the receiver.
*/
- (librdf_storage *)wrappedStorage;

/*!
	@method initWithFactoryName:identifier:options:
	@abstract Initialises a new RedlandStorage.
	@param factoryName Name of the storage factory
	@param anIdentifier Storage identifier (may be used as a file name)
	@param options Storage options (see the Redland C documentation for possible values)
*/
- (id)initWithFactoryName:(NSString *)factoryName
               identifier:(NSString *)anIdentifier 
                  options:(NSString *)options;

@end
