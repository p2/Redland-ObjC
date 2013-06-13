//
//  RedlandNode-Convenience.m
//  Redland Objective-C Bindings
//  $Id: RedlandNode-Convenience.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandNode-Convenience.h"
#import "RedlandException.h"
#import "RedlandNamespace.h"
#import "RedlandURI.h"

@implementation RedlandNode (Convenience)


#pragma mark - Allocators
/**
 *  A node representing the type, i.e. "a" or "rdf:type" or "http://www.w3.org/1999/02/22-rdf-syntax-ns#type".
 */
+ (RedlandNode *)typeNode
{
	return [RedlandNode nodeWithURIString:@"http://www.w3.org/1999/02/22-rdf-syntax-ns#type"];
}

/**
 *  Creates and returns a RedlandNode by sending `nodeValue` to the given object.
 *  @warning Raises a RedlandException if the object does not respond to the `nodeValue` selector.
 */
+ (RedlandNode *)nodeWithObject:(id)object
{
	if ([object respondsToSelector:@selector(nodeValue)]) {
		return [object nodeValue];
	}
	@throw [RedlandException exceptionWithName:RedlandExceptionName
										reason:[NSString stringWithFormat:@"Cannot make node from object %@", object]
									  userInfo:nil];
}

/**
 *  Creates and returns a typed literal RedlandNode with the given int value and a datatype URI of <tt>http://www.w3.org/2001/XMLSchema#int</tt>.
 */
+ (RedlandNode *)nodeWithLiteralInt:(int)anInt
{
	return [RedlandNode nodeWithLiteral:[NSString stringWithFormat:@"%d", anInt]
							   language:nil
								   type:[XMLSchemaNS URI:@"int"]];
}

/**
 *  Creates and returns a typed literal RedlandNode with the given float value and a datatype URI of <tt>http://www.w3.org/2001/XMLSchema#float</tt>.
 */
+ (RedlandNode *)nodeWithLiteralFloat:(float)aFloat
{
	return [RedlandNode nodeWithLiteral:[NSString stringWithFormat:@"%f", aFloat]
							   language:nil
								   type:[XMLSchemaNS URI:@"float"]];
}

/**
 *  Creates and returns a typed literal RedlandNode with the given double value and a datatype URI of <tt>http://www.w3.org/2001/XMLSchema#double</tt>.
 */
+ (RedlandNode *)nodeWithLiteralDouble:(double)aDouble
{
	return [RedlandNode nodeWithLiteral:[NSString stringWithFormat:@"%.15f", aDouble]
							   language:nil
								   type:[XMLSchemaNS URI:@"double"]];
}

/**
 *  Creates and returns a typed literal RedlandNode with the given boolean value and a datatype URI of <tt>http://www.w3.org/2001/XMLSchema#boolean</tt>.
 */
+ (RedlandNode *)nodeWithLiteralBool:(BOOL)aBool
{
	return [RedlandNode nodeWithLiteral:aBool ? @"true" : @"false"
							   language:nil
								   type:[XMLSchemaNS URI:@"boolean"]];
}

/**
 *  Creates and returns a typed literal RedlandNode with the given string value and a datatype URI of <tt>http://www.w3.org/2001/XMLSchema#string</tt>.
 */
+ (RedlandNode *)nodeWithLiteralString:(NSString *)aString language:(NSString *)aLanguage
{
	return [RedlandNode nodeWithLiteral:aString
							   language:aLanguage
								   type:[XMLSchemaNS URI:@"string"]];
}

/**
 *  Creates and returns a typed literal RedlandNode with the given NSDate value and a datatype URI of <tt>http://www.w3.org/2001/XMLSchema#dateTime</tt>.
 */
+ (RedlandNode *)nodeWithLiteralDateTime:(NSDate *)aDate
{
	NSDateFormatter *df = [self dateTimeFormatter];
	NSString *formattedDate = [df stringFromDate:aDate];
	
	return [RedlandNode nodeWithLiteral:formattedDate
							   language:nil
								   type:[XMLSchemaNS URI:@"dateTime"]];
}

/**
 *  Creates and returns a RedlandNode of type resource with the given URL.
 */
+ (RedlandNode *)nodeWithURL:(NSURL *)aURL
{
	return [self nodeWithURIString:[aURL absoluteString]];
}



#pragma mark - Accessors
/**
 *  @return the literal integer value of the receiver.
 *  @warning Raises a RedlandException if the datatype URI is not <tt>http://www.w3.org/2001/XMLSchema#int</tt>. (Note: This method should probably allow other integer-compatible datatypes as well...)
 */
- (int)intValue
{
	static RedlandURI *datatypeURI = nil;
	
	if (datatypeURI == nil) {
		datatypeURI = [XMLSchemaNS URI:@"int"];
	}
	if (![[self literalDataType] isEqual:datatypeURI]) {
		[RedlandException raise:RedlandExceptionName format:@"Cannot convert node %@ to int value", self];
		return 0;
	}
	return [[self literalValue] intValue];
}

/**
 *  @return the literal float value of the receiver.
 *  @warning Raises a RedlandException if the datatype URI is not <tt>http://www.w3.org/2001/XMLSchema#float</tt>.
 */
- (float)floatValue
{
	static RedlandURI *datatypeURI = nil;
	
	if (datatypeURI == nil) {
		datatypeURI = [XMLSchemaNS URI:@"float"];
	}
	if (![[self literalDataType] isEqual:datatypeURI]) {
		[RedlandException raise:RedlandExceptionName format:@"Cannot convert node %@ to float value", self];
		return 0.f;
	}
	return [[self literalValue] floatValue];
}

/**
 *  @return the literal double value of the receiver.
 *  @warning Raises a RedlandException if the datatype URI is not <tt>http://www.w3.org/2001/XMLSchema#double</tt>.
 */
- (double)doubleValue
{
	static RedlandURI *floatDatatypeURI = nil;
	static RedlandURI *doubleDatatypeURI = nil;
	
	if (floatDatatypeURI == nil) {
		floatDatatypeURI = [XMLSchemaNS URI:@"float"];
	}
	if (doubleDatatypeURI == nil) {
		doubleDatatypeURI = [XMLSchemaNS URI:@"double"];
	}
	if (![[self literalDataType] isEqual:floatDatatypeURI]
		&&![[self literalDataType] isEqual:doubleDatatypeURI]) {
		[RedlandException raise:RedlandExceptionName format:@"Cannot convert node %@ to double value", self];
		return 0.0;
	}
	return [[self literalValue] doubleValue];
}

/**
 *  @return the literal boolean value of the receiver.
 *  @warning Raises a RedlandException if the datatype URI is not <tt>http://www.w3.org/2001/XMLSchema#boolean</tt>.
 */
- (BOOL)boolValue
{
	static RedlandURI *datatypeURI = nil;
	
	if (datatypeURI == nil) {
		datatypeURI = [XMLSchemaNS URI:@"boolean"];
	}
	if (![[self literalDataType] isEqual:datatypeURI]) {
		[RedlandException raise:RedlandExceptionName format:@"Cannot convert node %@ to bool value", self];
		return 0;
	}
	
	NSString *stringValue = [[self literalValue] lowercaseString];
	return [stringValue isEqualToString:@"true"] || [stringValue isEqualToString:@"1"];
}

/**
 *  If you just want the literal value, no matter what datatype, use <tt>literalValue</tt>.
 *  @warning Raises a RedlandException if the datatype URI is not <tt>http://www.w3.org/2001/XMLSchema#string</tt>.
 *  @return the literal string value of the receiver.
 */
- (NSString *)stringValue
{
	static RedlandURI *datatypeURI = nil;
	
	if (datatypeURI == nil) {
		datatypeURI = [XMLSchemaNS URI:@"string"];
	}
	if (![[self literalDataType] isEqual:datatypeURI]) {
		[RedlandException raise:RedlandExceptionName format:@"Cannot convert node %@ to string value", self];
		return 0;
	}
	return [self literalValue];
}

/**
 *  @return the URI of the receiver (which must be a resource node) as an NSURL.
 */
- (NSURL *)URLValue
{
	return [[self URIValue] URLValue];
}

/**
 *  @return the URI of the receiver (which must be a resource node) as a string value.
 */
- (NSString *)URIStringValue
{
	return [[self URIValue] stringValue];
}

/**
 *  @return the literal dateTime value of the receiver.
 *  @warning Raises a RedlandException if the datatype URI is not <tt>http://www.w3.org/2001/XMLSchema#dateTime</tt>.
 */
- (NSDate *)dateTimeValue
{
	static RedlandURI *datatypeURI = nil;
	
	if (datatypeURI == nil) {
		datatypeURI = [XMLSchemaNS URI:@"dateTime"];
	}
	if (![[self literalDataType] isEqual:datatypeURI]) {
		[RedlandException raise:RedlandExceptionName format:@"Cannot convert node %@ to dateTime value", self];
		return nil;
	}
	
	// create a date from string
	NSDateFormatter *df = [[self class] dateTimeFormatter];
	return [df dateFromString:[self literalValue]];
}


/**
 *  @return the receiver.
 */
- (RedlandNode *)nodeValue
{
	return self;
}



#pragma mark - Date and Time Utilities
/**
 *  @return NSDateFormatter that can convert dates into ISO date strings and vice versa
 */
+ (NSDateFormatter *)dateTimeFormatter
{
	static NSDateFormatter *dateTimeNodeFormatter = nil;
	if (!dateTimeNodeFormatter) {
		dateTimeNodeFormatter = [NSDateFormatter new];
		[dateTimeNodeFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		[dateTimeNodeFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	}
	
	return dateTimeNodeFormatter;
}


@end


@implementation NSURL (RedlandNodeConvenience)

- (RedlandNode *)nodeValue
{
	return [RedlandNode nodeWithURL:self];
}

@end


@implementation NSNumber (RedlandNodeConvenience)

- (RedlandNode *)nodeValue
{
	if (NULL != strstr([self objCType], @encode(double))) {
		return [RedlandNode nodeWithLiteralDouble:[self doubleValue]];
	}
	if (NULL != strstr([self objCType], @encode(float))) {
		return [RedlandNode nodeWithLiteralFloat:[self floatValue]];
	}
	if (NULL != strstr([self objCType], @encode(BOOL))) {
		return [RedlandNode nodeWithLiteralBool:[self boolValue]];
	}
	return [RedlandNode nodeWithLiteralInt:[self intValue]];
}

@end


@implementation NSString (RedlandNodeConvenience)

- (RedlandNode *)nodeValue
{
	return [RedlandNode nodeWithLiteralString:self language:nil];
}

@end


@implementation NSDate (RedlandNodeConvenience)

- (RedlandNode *)nodeValue
{
	return [RedlandNode nodeWithLiteralDateTime:self];
}

@end


@implementation RedlandURI (RedlandNodeConvenience)

- (RedlandNode *)nodeValue
{
	return [RedlandNode nodeWithURI:self];
}

@end
