//
//  RedlandURI.m
//  Redland Objective-C Bindings
//  $Id: RedlandURI.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandURI.h"
#import "RedlandWorld.h"

@implementation RedlandURI

#pragma mark Init and Cleanup

+ (RedlandURI *)URIWithString:(NSString *)aString
{
	NSParameterAssert(aString != nil);
    return [[[self alloc] initWithString:aString] autorelease];
}

+ (RedlandURI *)URIWithURL:(NSURL *)aURL
{
	NSParameterAssert(aURL != nil);
	return [[[self alloc] initWithURL:aURL] autorelease];
}

- (id)initWithString:(NSString *)aString // designated initializer
{
    librdf_uri *new_uri;
    NSParameterAssert(aString != nil);

    new_uri = librdf_new_uri([RedlandWorld defaultWrappedWorld],
                             (unsigned char *)[aString UTF8String]);
	if (new_uri != NULL) {
		if ([self initWithWrappedObject:new_uri] == nil)
			librdf_free_uri(new_uri);
	}
    return self;
        
}

- (id)initWithURL:(NSURL *)aURL
{
	NSParameterAssert(aURL != nil);
	return [self initWithString:[aURL absoluteString]];
}

- (void)dealloc
{
    if (isWrappedObjectOwner)
        librdf_free_uri(wrappedObject);
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)aZone
{
    librdf_uri *copy = librdf_new_uri_from_uri(wrappedObject);
    return [[isa alloc] initWithWrappedObject:copy];
}

#pragma mark Archiving

- (id)initWithCoder:(NSCoder *)coder
{
    NSString *uriString;
    librdf_uri *uri;
	NSParameterAssert(coder != nil);
	
    if ([coder allowsKeyedCoding]) {
        uriString = [[coder decodeObjectForKey:@"URI"] retain];
    }
    else {
        uriString = [[coder decodeObject] retain];
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

#pragma mark Accessors

- (NSString *)description
{
    return [self stringValue];
}

- (librdf_uri *)wrappedURI
{
    return wrappedObject;
}

- (NSString *)stringValue
{
    size_t length;
    unsigned char *string_value = librdf_uri_as_counted_string(wrappedObject, &length);
    return [[[NSString alloc] initWithBytes:string_value length:length encoding:NSUTF8StringEncoding] autorelease];
}

- (NSURL *)URLValue
{
    return [NSURL URLWithString:[self stringValue]];
}

- (unsigned)hash
{
    return (unsigned)wrappedObject;
}

- (BOOL)isEqualToURI:(RedlandURI *)otherURI
{
    NSParameterAssert(otherURI != nil);
    return librdf_uri_equals(wrappedObject, [otherURI wrappedURI]);
}

- (BOOL)isEqual:(id)otherObject
{
    if ([otherObject isKindOfClass:isa])
        return [self isEqualToURI:otherObject];
    else
        return NO;
}

@end
