//
//  RedlandWrappedObject.h
//  Redland Objective-C Bindings
//  $Id: RedlandWrappedObject.h 307 2004-11-02 11:24:18Z kianga $
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

#import <Foundation/Foundation.h>


/**
 *  The abstract base class for all wrapped Redland objects.
 *
 *  Every object in this framework which maps directly to one of the underlying librdf pseudoclasses is implemented as a subclass of RedlandWrappedObject.
 */
@interface RedlandWrappedObject : NSObject {
    void *wrappedObject;									//< The redland lib C struct that's being wrapped by instances of this class
    BOOL isWrappedObjectOwner;								//< Whether the instance is the owner of and thus must free the wrapped object
}


- (id)initWithWrappedObject:(void *)object;
- (id)initWithWrappedObject:(void *)object owner:(BOOL)ownerFlag;


@end
