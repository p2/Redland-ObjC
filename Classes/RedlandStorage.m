//
//  RedlandStorage.m
//  Redland Objective-C Bindings
//  $Id: RedlandStorage.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandStorage.h"
#import "RedlandWorld.h"

@implementation RedlandStorage

/**
 *  Initializes a new in-memory, context-enabled hash storage.
 */
- (id)init
{
	return [self initWithFactoryName:@"hashes" identifier:nil options:@"hash-type='memory', contexts='yes'"];
}

/**
 *  The designated initializer, initialises a new RedlandStorage.
 *  @param factoryName Name of the storage factory
 *  @param anIdentifier Storage identifier (may be used as a file name)
 *  @param someOptions Storage options (see the Redland C documentation for possible values)
 */
- (id)initWithFactoryName:(NSString *)factoryName identifier:(NSString *)anIdentifier options:(NSString *)someOptions
{
	NSParameterAssert(factoryName != nil);
	
	char *identifier = NULL;
	char *options = NULL;
	
	// This strdup madness is necessary because librdf_new_storage wants non-const strings as its parameters:
	char *factory_name = strdup([factoryName UTF8String]);
	if (anIdentifier) {
		identifier = strdup([anIdentifier UTF8String]);
	}
	if (someOptions) {
		options = strdup([someOptions UTF8String]);
	}
	librdf_storage *newStorage = librdf_new_storage([RedlandWorld defaultWrappedWorld],
													factory_name,
													identifier,
													options);
	free(factory_name);
	free(identifier);
	free(options);
	
	self = [super initWithWrappedObject:newStorage];
	return self;
}

- (void)dealloc
{
	if (isWrappedObjectOwner && (wrappedObject != NULL)) {
		librdf_free_storage(wrappedObject);
	}
}

/**
 *  Returns the underlying librdf_storage pointer of the receiver.
 */
- (librdf_storage *)wrappedStorage
{
	return wrappedObject;
}


@end
