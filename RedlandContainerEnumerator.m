//
//  RedlandContainerEnumerator.m
//  Redland Objective-C Bindings
//  $Id: RedlandContainerEnumerator.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandContainerEnumerator.h"

#import "RedlandModel.h"
#import "RedlandModel-Convenience.h"
#import "RedlandNode.h"

static int CompareOrdinalNode(id firstNode, id secondNode, void *context)
{
    int firstOrdinalValue = [firstNode ordinalValue];
    int secondOrdinalValue = [firstNode ordinalValue];
    
    if (firstOrdinalValue < secondOrdinalValue)
        return NSOrderedAscending;
    else if (firstOrdinalValue > secondOrdinalValue)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

@implementation RedlandContainerEnumerator

+ (id)enumeratorWithModel:(RedlandModel *)aModel containerNode:(RedlandNode *)aContainerNode
{
    return [[[self alloc] initWithModel:aModel containerNode:aContainerNode] autorelease];
}

- (id)initWithModel:(RedlandModel *)aModel containerNode:(RedlandNode *)aContainerNode
{
    NSArray *sortedArcs;
    if (self = [super init]) {
        model = [aModel retain];
        containerNode = [aContainerNode retain];
        sortedArcs = [[model arcsOut:aContainerNode] sortedArrayUsingFunction:&CompareOrdinalNode context:NULL];
        arcEnumerator = [[sortedArcs objectEnumerator] retain];
    }
    return self;
}

- (void)dealloc
{
    [model release];
    [arcEnumerator release];
    [super dealloc];
}

- (id)nextObject
{
    RedlandNode *nextArc;
    
    do {
        nextArc = [arcEnumerator nextObject];
    } while (nextArc && ([nextArc ordinalValue] == -1));
    
    if (nextArc)
        return [model targetWithSource:containerNode arc:nextArc];
    else 
        return nil;
}

@end
