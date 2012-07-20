//
//  RedlandIteratorEnumerator.m
//  Redland Objective-C Bindings
//  $Id: RedlandIteratorEnumerator.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandIteratorEnumerator.h"

#import "RedlandIterator.h"
#import "RedlandNode.h"
#import "RedlandURI.h"

@implementation RedlandIteratorEnumerator

- (id)initWithRedlandIterator:(RedlandIterator *)anIterator objectClass:(Class)aClass
{
    NSParameterAssert([aClass conformsToProtocol:@protocol(NSCopying)]);
    NSParameterAssert(anIterator != nil);
    self = [super init];
    if (self) {
        iterator = [anIterator retain];
        firstIteration = YES;
        objectClass = aClass;
    }
    return self;
}

- (void)dealloc
{
    [iterator release];
    [super dealloc];
}

- (id)nextObject
{
    if (!firstIteration)
        [iterator next];
    else 
        firstIteration = NO;
    
    void *object = [iterator object];
    
    if ([objectClass isSubclassOfClass:[RedlandNode class]]) {
		if (object)
			object = librdf_new_node_from_node(object);
        return [[[objectClass alloc] initWithWrappedObject:object] autorelease];
    }
    else if ([objectClass isSubclassOfClass:[RedlandURI class]]) {
		if (object)
			object = librdf_new_uri_from_uri(object);
        return [[[objectClass alloc] initWithWrappedObject:object] autorelease];
    }
    else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Inhandled object class %@ in RedlandIteratorEnumerator", objectClass]
                                     userInfo:nil];
    }
}

@end
