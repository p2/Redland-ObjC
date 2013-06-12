//
//  RedlandNode-Convenience.h
//  Redland Objective-C Bindings
//  $Id: RedlandNode-Convenience.h 307 2004-11-02 11:24:18Z kianga $
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
#import "RedlandNode.h"
#import "RedlandURI.h"


/**
 *  Defines various convenience methods for RedlandNode objects.
 */
@interface RedlandNode (Convenience)

+ (RedlandNode *)typeNode;
+ (RedlandNode *)nodeWithURL:(NSURL *)aURL;
+ (RedlandNode *)nodeWithLiteralInt:(int)anInt;
+ (RedlandNode *)nodeWithLiteralFloat:(float)aFloat;
+ (RedlandNode *)nodeWithLiteralDouble:(double)aDouble;
+ (RedlandNode *)nodeWithLiteralBool:(BOOL)aBool;
+ (RedlandNode *)nodeWithLiteralString:(NSString *)aString language:(NSString *)aLanguage;
+ (RedlandNode *)nodeWithLiteralDateTime:(NSDate *)aDate;
+ (RedlandNode *)nodeWithObject:(id)object;

- (int)intValue;
- (float)floatValue;
- (double)doubleValue;

- (BOOL)boolValue;

- (NSString *)stringValue;
- (NSString *)URIStringValue;
- (NSURL *)URLValue;
- (NSDate *)dateTimeValue;

- (RedlandNode *)nodeValue;

+ (NSDateFormatter *)dateTimeFormatter;


@end


/**
 *  Convenience method for NSURL
 */
@interface NSURL (RedlandNodeConvenience)

- (RedlandNode *)nodeValue;

@end


/**
 *  Convenience method for NSNumber
 */
@interface NSNumber (RedlandNodeConvenience)

- (RedlandNode *)nodeValue;

@end


/**
 *  Convenience method for NSString
 */
@interface NSString (RedlandNodeConvenience)

- (RedlandNode *)nodeValue;

@end


/**
 *  Convenience method for NSDate
 */
@interface NSDate (RedlandNodeConvenience)

- (RedlandNode *)nodeValue;

@end


/**
 *  Convenience method for RedlandURI
 */
@interface RedlandURI (RedlandNodeConvenience)

- (RedlandNode *)nodeValue;

@end
