//
//  RedlandURI.h
//  Redland Objective-C Bindings
//  $Id: RedlandURI.h 313 2004-11-03 19:00:40Z kianga $
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
 *  A RedlandURI provides simple URI functionality like storage and comparison.
 *
 *  This class wraps librdf_uri objects. As of this version, only the most basic librdf_uri functions of the Redland library are represented in these bindings.
 *  It is recommended to use Cocoa's NSURL class whenever possible. Instances of the RedlandURI class conform to the NSCopying and NSCoding protocols.
 */
@interface RedlandURI : RedlandWrappedObject <NSCopying, NSCoding> 

+ (RedlandURI *)URIWithString:(NSString *)aString;
+ (RedlandURI *)URIWithURL:(NSURL *)aURL;

- (id)initWithString:(NSString *)aString;
- (id)initWithURL:(NSURL *)aURL;

- (librdf_uri *)wrappedURI;
- (NSString *)stringValue;
- (NSURL *)URLValue;

- (BOOL)isEqualToURI:(RedlandURI *)otherURI;


@end
