//
//  RedlandIterator.h
//  Redland Objective-C Bindings
//  $Id: RedlandIterator.h 313 2004-11-03 19:00:40Z kianga $
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
 *  A direct wrapper around librdf_iterator.
 *
 *  Implementation of this class is subject to change. Do not use.
 */
@interface RedlandIterator : RedlandWrappedObject

- (librdf_iterator *)wrappedIterator;

- (void *)object;
- (void *)value;
- (void *)context;
- (void *)key;

- (BOOL)next;
- (BOOL)end;


@end
