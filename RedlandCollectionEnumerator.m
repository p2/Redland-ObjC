//
//  RedlandCollectionEnumerator.m
//  Redland Objective-C Bindings
//  $Id: RedlandCollectionEnumerator.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandCollectionEnumerator.h"

#import "RedlandNode.h"
#import "RedlandModel.h"
#import "RedlandNamespace.h"

@implementation RedlandCollectionEnumerator

+ (id)enumeratorWithModel:(RedlandModel *)aModel collectionNode:(RedlandNode *)collectionNode
{
    return [[[self alloc] initWithModel:aModel collectionNode:collectionNode] autorelease];
}

- (id)initWithModel:(RedlandModel *)aModel collectionNode:(RedlandNode *)collectionNode
{
    if (self = [super init]) {
        model = [aModel retain];
        currentNode = [collectionNode retain];
    }
    return self;
}

- (void)dealloc
{
    [model release];
    [currentNode release];
    [super dealloc];
}

- (id)nextObject
{
    RedlandNode *value;
    static RedlandNode *RDFFirstNode = nil;
    static RedlandNode *RDFRestNode = nil;
    static RedlandNode *RDFNilNode = nil;
    
    if (!RDFFirstNode)
        RDFFirstNode = [[RDFSyntaxNS node:@"first"] retain];
    if (!RDFRestNode)
        RDFRestNode = [[RDFSyntaxNS node:@"rest"] retain];
    if (!RDFNilNode)
        RDFNilNode = [[RDFSyntaxNS node:@"nil"] retain];
    
    if (currentNode) {
        value = [model targetWithSource:currentNode arc:RDFFirstNode];
        currentNode = [model targetWithSource:currentNode arc:RDFRestNode];
        if ([currentNode isEqualToNode:RDFNilNode])
            currentNode = nil;
        return value;
    }
    else return nil;
}

@end
