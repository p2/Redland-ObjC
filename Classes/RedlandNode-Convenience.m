//
//  RedlandNode-Convenience.m
//  Redland Objective-C Bindings
//  $Id: RedlandNode-Convenience.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandNode-Convenience.h"
#import "RedlandException.h"
#import "RedlandNamespace.h"
#import "RedlandURI.h"

@implementation RedlandNode (Convenience)

+ (RedlandNode *)nodeWithObject:(id)object
{
    NSParameterAssert(object);
    if ([object respondsToSelector:@selector(nodeValue)])
        return [object nodeValue];
    else
        @throw [RedlandException exceptionWithName:RedlandExceptionName
                                            reason:[NSString stringWithFormat:@"Cannot make node from object %@", object]
                                          userInfo:nil];
}

+ (RedlandNode *)nodeWithLiteralInt:(int)anInt
{
    return [RedlandNode nodeWithLiteral:[NSString stringWithFormat:@"%d", anInt]
                               language:nil
                                   type:[XMLSchemaNS URI:@"int"]];
}

+ (RedlandNode *)nodeWithLiteralBool:(BOOL)aBool
{
    return [RedlandNode nodeWithLiteral:aBool ? @"true" : @"false"
                               language:nil
                                   type:[XMLSchemaNS URI:@"boolean"]];
}

+ (RedlandNode *)nodeWithLiteralString:(NSString *)aString language:(NSString *)aLanguage
{
    return [RedlandNode nodeWithLiteral:aString
                               language:aLanguage
                                   type:[XMLSchemaNS URI:@"string"]];
}

+ (RedlandNode *)nodeWithLiteralFloat:(float)aFloat
{
    return [RedlandNode nodeWithLiteral:[NSString stringWithFormat:@"%f", aFloat]
                               language:nil
                                   type:[XMLSchemaNS URI:@"float"]];
}

+ (RedlandNode *)nodeWithLiteralDouble:(double)aDouble
{
    return [RedlandNode nodeWithLiteral:[NSString stringWithFormat:@"%f", aDouble]
                               language:nil
                                   type:[XMLSchemaNS URI:@"double"]];
}

+ (RedlandNode *)nodeWithLiteralDateTime:(NSDate *)aDate
{
    NSString *formattedDate = [aDate descriptionWithCalendarFormat:@"%Y-%m-%dT%H:%M:%SZ" 
                                                          timeZone:[NSTimeZone timeZoneWithName:@"UTC"]
                                                            locale:nil];
    return [RedlandNode nodeWithLiteral:formattedDate
                               language:nil
                                   type:[XMLSchemaNS URI:@"dateTime"]];
}

+ (RedlandNode *)nodeWithURL:(NSURL *)aURL
{
    return [self nodeWithURIString:[aURL absoluteString]];
}

- (int)intValue
{
    static RedlandURI *datatypeURI = nil;
    
    if (datatypeURI == nil)
        datatypeURI = [[XMLSchemaNS URI:@"int"] retain];
    if (![[self literalDataType] isEqual:datatypeURI]) {
        [RedlandException raise:RedlandExceptionName format:@"Cannot convert node %@ to int value", self];
        return 0;
    }
    else return [[self literalValue] intValue];
}

- (BOOL)boolValue
{
    static RedlandURI *datatypeURI = nil;
    NSString *stringValue;
    
    if (datatypeURI == nil)
        datatypeURI = [[XMLSchemaNS URI:@"boolean"] retain];
    if (![[self literalDataType] isEqual:datatypeURI]) {
        [RedlandException raise:RedlandExceptionName format:@"Cannot convert node %@ to bool value", self];
        return 0;
    }
    else {
        stringValue = [[self literalValue] lowercaseString];
        return [stringValue isEqualToString:@"true"] || [stringValue isEqualToString:@"1"];
    }
}

- (NSString *)stringValue
{
    static RedlandURI *datatypeURI = nil;
    
    if (datatypeURI == nil)
        datatypeURI = [[XMLSchemaNS URI:@"string"] retain];
    if (![[self literalDataType] isEqual:datatypeURI]) {
        [RedlandException raise:RedlandExceptionName format:@"Cannot convert node %@ to string value", self];
        return 0;
    }
    else return [self literalValue];
}

- (NSURL *)URLValue
{
    return [[self URIValue] URLValue];
}

- (NSString *)URIStringValue
{
    return [[self URIValue] stringValue];
}

- (NSCalendarDate *)dateTimeValue
{
    static RedlandURI *datatypeURI = nil;
    
    if (datatypeURI == nil)
        datatypeURI = [[XMLSchemaNS URI:@"dateTime"] retain];
    if (![[self literalDataType] isEqual:datatypeURI]) {
        [RedlandException raise:RedlandExceptionName format:@"Cannot convert node %@ to dateTime value", self];
        return 0;
    }
    else {
        NSCalendarDate *date;
        date = [NSCalendarDate dateWithString:[self literalValue] calendarFormat:@"%Y-%m-%dT%H:%M:%SZ"];
        // FIXME: The parsed date is always in the local timezone, but it should
        // be in the UTC timezone. Ugly workaround follows...
        date = [NSCalendarDate dateWithYear:[date yearOfCommonEra]
                                      month:[date monthOfYear]
                                        day:[date dayOfMonth]
                                       hour:[date hourOfDay]
                                     minute:[date minuteOfHour]
                                     second:[date secondOfMinute]
                                   timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        return date;
    }
}

- (float)floatValue
{
    static RedlandURI *datatypeURI = nil;
    
    if (datatypeURI == nil)
        datatypeURI = [[XMLSchemaNS URI:@"float"] retain];
    if (![[self literalDataType] isEqual:datatypeURI]) {
        [RedlandException raise:RedlandExceptionName format:@"Cannot convert node %@ to float value", self];
        return 0;
    }
    else return [[self literalValue] floatValue];
}

- (double)doubleValue
{
    static RedlandURI *floatDatatypeURI = nil;
    static RedlandURI *doubleDatatypeURI = nil;
    
    if (floatDatatypeURI == nil)
        floatDatatypeURI = [[XMLSchemaNS URI:@"float"] retain];
    if (doubleDatatypeURI == nil)
        doubleDatatypeURI = [[XMLSchemaNS URI:@"double"] retain];
    if (![[self literalDataType] isEqual:floatDatatypeURI] &&
        ![[self literalDataType] isEqual:doubleDatatypeURI]) {
        [RedlandException raise:RedlandExceptionName format:@"Cannot convert node %@ to double value", self];
        return 0;
    }
    else return [[self literalValue] doubleValue];
}

- (RedlandNode *)nodeValue
{
    return self;
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
    if ([self objCType] == @encode(double))
        return [RedlandNode nodeWithLiteralDouble:[self doubleValue]];
    else if ([self objCType] == @encode(float))
        return [RedlandNode nodeWithLiteralFloat:[self floatValue]];
    else if ([self objCType] == @encode(BOOL))
        return [RedlandNode nodeWithLiteralBool:[self boolValue]];
    else
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
