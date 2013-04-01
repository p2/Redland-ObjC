//
//  RedlandWrappedObject.m
//  Redland Objective-C Bindings
//  $Id: RedlandWrappedObject.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandWrappedObject.h"


@implementation RedlandWrappedObject

/**
 *  The designated initializer.
 *
 *  Initialises the receiver to use the given pointer as its underlying wrapped object. The receiver is considered the owner of the object.
 *  @param object The pointer to the librdf object
 */
- (id)initWithWrappedObject:(void *)object
{
    return [self initWithWrappedObject:object owner:YES];
}


/**
 *  Initialises the receiver to use the given pointer as its underlying wrapped object.
 *  @param object The pointer to the librdf object
 *  @param ownerFlag If TRUE, the receiver considers itself the owner of the underlying librdf object and will possibly free it when the receiver is deallocated.
 */
- (id)initWithWrappedObject:(void *)object owner:(BOOL)ownerFlag
{
    if (NULL == object) {
		NSLog(@"initWithWrappedObject: Cannot wrap NULL object!");
        return nil;
    }
    else if ((self = [super init])) {
        wrappedObject = object;
        isWrappedObjectOwner = ownerFlag;
    }
    return self;
}



#pragma mark - Utilities
- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ <%p> wrapping %p", NSStringFromClass([self class]), self, wrappedObject];
}


@end
