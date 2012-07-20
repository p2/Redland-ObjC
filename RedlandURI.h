//
//  RedlandURI.h
//  Redland Objective-C Bindings
//  $Id: RedlandURI.h 313 2004-11-03 19:00:40Z kianga $
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
#import <Redland/redland.h>
#import "RedlandWrappedObject.h"

/*!
	@header RedlandURI.h
	Defines the RedlandURI class.
*/

/*!
	@class RedlandURI
	@abstract A RedlandURI provides simple URI functionality like storage and comparison.
	@discussion This class wraps librdf_uri objects. As of this version, only the most basic librdf_uri functions of the Redland library are represented in these bindings. It is recommended to use Cocoa's NSURL class whenever possible. Instances of the RedlandURI class conform to the NSCopying and NSCoding protocols.
*/
@interface RedlandURI : RedlandWrappedObject <NSCopying, NSCoding> {
}

/*! Returns a new RedlandURI instance initialized from an NSString. */
+ (RedlandURI *)URIWithString:(NSString *)aString;
/*! Returns a new RedlandURI instance initialized from the absoluteString
    of the given NSURL. */
+ (RedlandURI *)URIWithURL:(NSURL *)aURL;
/*! Initializes the receiver from an NSString. */
- (id)initWithString:(NSString *)aString;
/*! Initializes the receiver with the absolute string of a URL. */
- (id)initWithURL:(NSURL *)aURL;
/*! Returns the underlying librdf_uri pointer of the receiver. */
- (librdf_uri *)wrappedURI;
/*! Returns the URI of the receiver as an NSString. */
- (NSString *)stringValue;
/*! Returns the URI of the receiver as an NSURL. */
- (NSURL *)URLValue;
/*! Returns YES if otherURI is equal to the receiver. */
- (BOOL)isEqualToURI:(RedlandURI *)otherURI;
/*! Overridden to return [self isEqualToURI:otherObject] if otherObject is also
    a kind of RedlandURI; in all other cases, NO is returned. */
- (BOOL)isEqual:(id)otherObject;
@end
