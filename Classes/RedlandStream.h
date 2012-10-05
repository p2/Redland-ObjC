//
//  RedlandStream.h
//  Redland Objective-C Bindings
//  $Id: RedlandStream.h 313 2004-11-03 19:00:40Z kianga $
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

@class RedlandStatement, RedlandNode, RedlandStreamEnumerator;


/**
 *  A RedlandStream represents a stream of statements.
 *
 *  Streams are used as return values from parsers and query functions in the Redland library. It is recommended that you use the statementEnumerator function
 *  to access the stream, as it provides a more natural Cocoa interface using an NSEnumerator subclass.
 */

@interface RedlandStream : RedlandWrappedObject

- (librdf_stream *)wrappedStream;

- (BOOL)next;
- (RedlandStatement *)object;
- (RedlandNode *)context;

- (RedlandStreamEnumerator *)statementEnumerator;


@end
