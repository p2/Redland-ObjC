//
//  RedlandURI.m
//  Redland Objective-C Bindings
//  $Id: RedlandURI.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandURI.h"
#import "RedlandWorld.h"

@implementation RedlandURI

#pragma mark - Init and Cleanup
/**
 *  Convenience allocator.
 *  @param aString An URI-string
 *  @return a new RedlandURI instance initialized from an NSString.
 */
+ (RedlandURI *)URIWithString:(NSString *)aString
{
	return [[self alloc] initWithString:aString];
}

/**
 *  Convenience allocator.
 *  @param aURL The URL to use as an NSURL object
 *  @return a new RedlandURI instance initialized from the absoluteString of the given NSURL.
 */
+ (RedlandURI *)URIWithURL:(NSURL *)aURL
{
	return [[self alloc] initWithURL:aURL];
}


/**
 *  Initializes the receiver from an NSString; the designated initializer.
 *  @param aString An URI-string
 */
- (id)initWithString:(NSString *)aString
{
	NSParameterAssert(aString != nil);
	
	librdf_uri *new_uri = librdf_new_uri([RedlandWorld defaultWrappedWorld],
										 (unsigned char *)[aString UTF8String]);
	if (!new_uri) {
		return nil;
	}
	
	self = [self initWithWrappedObject:new_uri];
	if (!self) {
		librdf_free_uri(new_uri);
	}
	return self;
	
}

/**
 *  Initializes the receiver with the absolute string of a URL.
 *  @param aURL An URL
 */
- (id)initWithURL:(NSURL *)aURL
{
	NSParameterAssert(aURL != nil);
	return [self initWithString:[aURL absoluteString]];
}

- (void)dealloc
{
	if (isWrappedObjectOwner) {
		librdf_free_uri(wrappedObject);
	}
}

- (id)copyWithZone:(NSZone *)aZone
{
	librdf_uri *copy = librdf_new_uri_from_uri(wrappedObject);
	return [[[self class] alloc] initWithWrappedObject:copy];
}



#pragma mark - Archiving
- (id)initWithCoder:(NSCoder *)coder
{
	NSString *uriString;
	librdf_uri *uri;
	NSParameterAssert(coder != nil);
	
	if ([coder allowsKeyedCoding]) {
		uriString = [coder decodeObjectForKey:@"URI"];
	}
	else {
		uriString = [coder decodeObject];
	}
	uri = librdf_new_uri([RedlandWorld defaultWrappedWorld],
						 (unsigned char *)[uriString UTF8String]);
	self = [super initWithWrappedObject:uri];
	if (self == nil) {
		librdf_free_uri(uri);
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	NSParameterAssert(coder != nil);
	if ([coder allowsKeyedCoding]) {
		[coder encodeObject:[self stringValue] forKey:@"URI"];
	}
	else {
		[coder encodeObject:[self stringValue]];
	}
}



#pragma mark - Accessors
- (NSString *)description
{
	return [self stringValue];
}

/**
 *  Returns the underlying librdf_uri pointer of the receiver.
 */
- (librdf_uri *)wrappedURI
{
	return wrappedObject;
}

/**
 *  Returns the URI of the receiver as an NSString.
 */
- (NSString *)stringValue
{
	size_t length;
	unsigned char *string_value = librdf_uri_as_counted_string(wrappedObject, &length);
	return [[NSString alloc] initWithBytes:string_value length:length encoding:NSUTF8StringEncoding];
}

/**
 *  Returns the URI of the receiver as an NSURL.
 */
- (NSURL *)URLValue
{
	return [NSURL URLWithString:[self stringValue]];
}

- (NSUInteger)hash
{
	return (NSUInteger)wrappedObject;
}

/**
 *  Returns YES if otherURI is equal to the receiver.
 *  @param otherURI The other instance to compare to
 */
- (BOOL)isEqualToURI:(RedlandURI *)otherURI
{
	if (!otherURI) {
		return NO;
	}
	if (self == otherURI) {
		return YES;
	}
	return librdf_uri_equals(wrappedObject, [otherURI wrappedURI]);
}

/**
 *  Overridden to return `isEqualToURI:` if otherObject is also a kind of RedlandURI; in all other cases, NO is returned.
 *  @param otherObject The object to compare against
 */
- (BOOL)isEqual:(id)otherObject
{
	if ([otherObject isKindOfClass:[self class]]) {
		return [self isEqualToURI:otherObject];
	}
	return NO;
}


@end
