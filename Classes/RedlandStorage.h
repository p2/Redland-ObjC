//
//  RedlandStorage.h
//  Redland Objective-C Bindings
//  $Id: RedlandStorage.h 313 2004-11-03 19:00:40Z kianga $
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
#import <redland.h>
#import "RedlandWrappedObject.h"

/**
 *  This class provides storage for RDF models either in memory or persistent storage.
 *
 *  The interface of this class is currently incomplete, as most methods are simply duplicates of the RedlandModel methods. If direct manipulation of the
 *  storage is necessary, you can use the standard C API on the underlying librdf_storage instead.
 */
@interface RedlandStorage : RedlandWrappedObject

- (id)initWithFactoryName:(NSString *)factoryName identifier:(NSString *)anIdentifier options:(NSString *)options;

- (librdf_storage *)wrappedStorage;


@end
