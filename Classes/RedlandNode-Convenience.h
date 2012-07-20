//
//  RedlandNode-Convenience.h
//  Redland Objective-C Bindings
//  $Id: RedlandNode-Convenience.h 307 2004-11-02 11:24:18Z kianga $
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
	@header RedlandNode-Convenience.h
	Defines convenience methods for the RedlandNode class.
*/

#import <Foundation/Foundation.h>
#import "RedlandNode.h"
#import "RedlandURI.h"

/*!
	@category RedlandNode(Convenience)
	@abstract Defines various convenience methods for RedlandNode objects.
*/
@interface RedlandNode (Convenience)

/*!
	@method nodeWithURL:
	@abstract Creates and returns a RedlandNode of type resource with the given URL.
*/
+ (RedlandNode *)nodeWithURL:(NSURL *)aURL;

/*!
	@method nodeWithLiteralInt:
	@abstract Creates and returns a typed literal RedlandNode with the given int value and a datatype URI of <tt>http://www.w3.org/2001/XMLSchema#int</tt>.
*/
+ (RedlandNode *)nodeWithLiteralInt:(int)anInt;

/*!
	@method nodeWithLiteralBool:
	@abstract Creates and returns a typed literal RedlandNode with the given boolean value and a datatype URI of <tt>http://www.w3.org/2001/XMLSchema#boolean</tt>.
*/
+ (RedlandNode *)nodeWithLiteralBool:(BOOL)aBool;

/*!
	@method nodeWithLiteralString:
	@abstract Creates and returns a typed literal RedlandNode with the given string value and a datatype URI of <tt>http://www.w3.org/2001/XMLSchema#string</tt>.
*/
+ (RedlandNode *)nodeWithLiteralString:(NSString *)aString language:(NSString *)aLanguage;

/*!
	@method nodeWithLiteralFloat:
	@abstract Creates and returns a typed literal RedlandNode with the given float value and a datatype URI of <tt>http://www.w3.org/2001/XMLSchema#float</tt>.
*/
+ (RedlandNode *)nodeWithLiteralFloat:(float)aFloat;

/*!
	@method nodeWithLiteralDouble:
	@abstract Creates and returns a typed literal RedlandNode with the given double value and a datatype URI of <tt>http://www.w3.org/2001/XMLSchema#double</tt>.
*/
+ (RedlandNode *)nodeWithLiteralDouble:(double)aDouble;

/*!
	@method nodeWithLiteralDateTime:
	@abstract Creates and returns a typed literal RedlandNode with the given NSDate value and a datatype URI of <tt>http://www.w3.org/2001/XMLSchema#dateTime</tt>.
*/
+ (RedlandNode *)nodeWithLiteralDateTime:(NSDate *)aDate;

/*!
	@method nodeWithObject:
	@abstract Creates and returns a RedlandNode by sending <tt>nodeValue</tt> to the given object.
	@discussion Raises a RedlandException if the object does not respond to the <tt>nodeValue</tt> selector.
*/
+ (RedlandNode *)nodeWithObject:(id)object;

/*!
	@method intValue
	@abstract Returns the literal integer value of the receiver.
	@discussion Raises a RedlandException if the datatype URI is not <tt>http://www.w3.org/2001/XMLSchema#int</tt>. (Note: This method should probably allow other integer-compatible datatypes as well...)
*/
- (int)intValue;

/*!
	@method floatValue
	@abstract Returns the literal float value of the receiver.
	@discussion Raises a RedlandException if the datatype URI is not <tt>http://www.w3.org/2001/XMLSchema#float</tt>.
*/
- (float)floatValue;

/*!
	@method doubleValue
	@abstract Returns the literal double value of the receiver.
	@discussion Raises a RedlandException if the datatype URI is not <tt>http://www.w3.org/2001/XMLSchema#double</tt>.
*/
- (double)doubleValue;

/*!
	@method boolValue
	@abstract Returns the literal boolean value of the receiver.
	@discussion Raises a RedlandException if the datatype URI is not <tt>http://www.w3.org/2001/XMLSchema#boolean</tt>.
*/
- (BOOL)boolValue;

/*!
	@method URIStringValue
	@abstract Returns the URI of the receiver (which must be a resource node) as a string value.
*/
- (NSString *)URIStringValue;

/*!
	@method URLValue
	@abstract Returns the URI of the receiver (which must be a resource node) as an NSURL.
*/
- (NSURL *)URLValue;

/*!
	@method stringValue
	@abstract Returns the literal string value of the receiver.
	@discussion Raises a RedlandException if the datatype URI is not <tt>http://www.w3.org/2001/XMLSchema#string</tt>. If you just want the literal value, no matter what datatype, user <tt>literalValue</tt>.
*/
- (NSString *)stringValue;

/*!
	@method dateTimeValue
	@abstract Returns the literal dateTime value of the receiver.
	@discussion Raises a RedlandException if the datatype URI is not <tt>http://www.w3.org/2001/XMLSchema#dateTime</tt>.
*/
- (NSCalendarDate *)dateTimeValue;

/*!
	@method nodeValue
	@abstract Returns the receiver.
*/
- (RedlandNode *)nodeValue;
@end

@interface NSURL (RedlandNodeConvenience)
- (RedlandNode *)nodeValue;
@end

@interface NSNumber (RedlandNodeConvenience)
- (RedlandNode *)nodeValue;
@end

@interface NSString (RedlandNodeConvenience)
- (RedlandNode *)nodeValue;
@end

@interface NSDate (RedlandNodeConvenience)
- (RedlandNode *)nodeValue;
@end

@interface RedlandURI (RedlandNodeConvenience)
- (RedlandNode *)nodeValue;
@end
