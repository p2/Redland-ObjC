//
//  RedlandModel-Convenience.m
//  Redland Objective-C Bindings
//  $Id: RedlandModel-Convenience.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandModel-Convenience.h"
#import "RedlandParser.h"
#import "RedlandStreamEnumerator.h"
#import "RedlandIteratorEnumerator.h"
#import "RedlandURI.h"
#import "RedlandNode.h"
#import "RedlandNode-Convenience.h"
#import "RedlandStatement.h"
#import "RedlandSerializer.h"
#import "RedlandNamespace.h"

@implementation RedlandModel (Convenience)

#pragma mark Finding Statements

- (RedlandStreamEnumerator *)enumeratorOfStatementsLike:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode modifier:(RedlandStreamEnumeratorModifier)modifier
{
    NSParameterAssert(aStatement != nil);
    RedlandStream *resultStream = [self streamOfStatementsLike:aStatement withContext:contextNode];
    return [[[RedlandStreamEnumerator alloc] initWithRedlandStream:resultStream modifier:modifier] autorelease];
}

- (RedlandStreamEnumerator *)enumeratorOfStatementsLike:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode
{
    NSParameterAssert(aStatement != nil);
    RedlandStream *resultStream = [self streamOfStatementsLike:aStatement withContext:contextNode];
    return [[[RedlandStreamEnumerator alloc] initWithRedlandStream:resultStream] autorelease];
}

- (RedlandStreamEnumerator *)enumeratorOfStatementsLike:(RedlandStatement *)aStatement
{
    NSParameterAssert(aStatement != nil);
    RedlandStream *resultStream = [self streamOfStatementsLike:aStatement];
    return [[[RedlandStreamEnumerator alloc] initWithRedlandStream:resultStream] autorelease];
}

#pragma mark Finding Sources

- (NSEnumerator *)enumeratorOfSourcesWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode context:(RedlandNode *)contextNode
{
    RedlandStatement *findStatement = [RedlandStatement statementWithSubject:nil
                                                                   predicate:arcNode
                                                                      object:targetNode];
    return [self enumeratorOfStatementsLike:findStatement withContext:contextNode modifier:RedlandReturnSubjects];
}

- (NSEnumerator *)enumeratorOfSourcesWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode
{
    RedlandIterator *iterator = [self iteratorOfSourcesWithArc:arcNode target:targetNode];
    return [[[RedlandIteratorEnumerator alloc] initWithRedlandIterator:iterator objectClass:[RedlandNode class]] autorelease];
}

#pragma mark Finding Arcs

- (NSEnumerator *)enumeratorOfArcsWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode context:(RedlandNode *)contextNode
{
    RedlandStatement *findStatement = [RedlandStatement statementWithSubject:sourceNode
                                                                   predicate:nil
                                                                      object:targetNode];
    return [self enumeratorOfStatementsLike:findStatement withContext:contextNode modifier:RedlandReturnPredicates];
}

- (NSEnumerator *)enumeratorOfArcsWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode
{
    RedlandIterator *iterator = [self iteratorOfArcsWithSource:sourceNode target:targetNode];
    return [[[RedlandIteratorEnumerator alloc] initWithRedlandIterator:iterator objectClass:[RedlandNode class]] autorelease];
}

#pragma mark Finding Targets

- (NSEnumerator *)enumeratorOfTargetsWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode context:(RedlandNode *)contextNode
{
    RedlandStatement *findStatement = [RedlandStatement statementWithSubject:sourceNode
                                                                   predicate:arcNode
                                                                      object:nil];
    return [self enumeratorOfStatementsLike:findStatement withContext:contextNode modifier:RedlandReturnObjects];
}

- (NSEnumerator *)enumeratorOfTargetsWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode
{
    RedlandIterator *iterator = [self iteratorOfTargetsWithSource:sourceNode arc:arcNode];
    return [[[RedlandIteratorEnumerator alloc] initWithRedlandIterator:iterator objectClass:[RedlandNode class]] autorelease];
}

#pragma mark Finding Arcs In

- (NSEnumerator *)enumeratorOfArcsIn:(RedlandNode *)targetNode context:(RedlandNode *)contextNode
{
    RedlandStatement *findStatement = [RedlandStatement statementWithSubject:nil
                                                                   predicate:nil
                                                                      object:targetNode];
    return [self enumeratorOfStatementsLike:findStatement withContext:contextNode modifier:RedlandReturnPredicates];
}

- (NSEnumerator *)enumeratorOfArcsIn:(RedlandNode *)targetNode
{
    RedlandIterator *iterator = [self iteratorOfArcsIn:targetNode];
    return [[[RedlandIteratorEnumerator alloc] initWithRedlandIterator:iterator objectClass:[RedlandNode class]] autorelease];
}

#pragma mark Finding Arcs Out

- (NSEnumerator *)enumeratorOfArcsOut:(RedlandNode *)targetNode context:(RedlandNode *)contextNode
{
    RedlandStatement *findStatement = [RedlandStatement statementWithSubject:targetNode
                                                                   predicate:nil
                                                                      object:nil];
    return [self enumeratorOfStatementsLike:findStatement withContext:contextNode modifier:RedlandReturnPredicates];
}

- (NSEnumerator *)enumeratorOfArcsOut:(RedlandNode *)sourceNode
{
    RedlandIterator *iterator = [self iteratorOfArcsOut:sourceNode];
    return [[[RedlandIteratorEnumerator alloc] initWithRedlandIterator:iterator objectClass:[RedlandNode class]] autorelease];
}

#pragma mark Misc

- (NSEnumerator *)contextEnumerator;
{
    RedlandIterator *iterator = [self contextIterator];
    return [[[RedlandIteratorEnumerator alloc] initWithRedlandIterator:iterator objectClass:[RedlandNode class]] autorelease];
}

- (RedlandStreamEnumerator *)statementEnumerator
{
    return [[[RedlandStreamEnumerator alloc] initWithRedlandStream:[self statementStream]] autorelease];
}

- (RedlandStreamEnumerator *)statementEnumeratorWithContext:(RedlandNode *)contextNode
{
    return [[[RedlandStreamEnumerator alloc] initWithRedlandStream:[self streamOfAllStatementsWithContext:contextNode]] autorelease];
}

//#pragma mark Collections and Containers
//
//- (NSArray *)itemsInContainerNode:(RedlandNode *)subjectNode
//{
//    NSParameterAssert(subjectNode != nil);
//    
//    NSEnumerator *statementEnum;
//    RedlandStatement *curStatement;
//    RedlandStatement *testStatement = [RedlandStatement statementWithSubject:subjectNode
//                                                                   predicate:nil
//                                                                      object:nil];
//    NSMutableArray *results = [NSMutableArray array];
//    
//    statementEnum = [self enumeratorOfStatementsLike:testStatement];
//    while (curStatement = [statementEnum nextObject]) {
//        if ([[curStatement predicate] ordinalValue] >= 0)
//            [results addObject:[curStatement object]];
//    }
//    
//    return [NSArray arrayWithArray:results];
//}
//
//- (NSEnumerator *)enumeratorOfCollectionNode:(RedlandNode *)collectionNode
//{
//    return [RedlandCollectionEnumerator enumeratorWithModel:self collectionNode:collectionNode];
//}
//
//- (NSArray *)contentsOfCollectionNode:(RedlandNode *)collectionNode
//{
//    return [[self enumeratorOfCollectionNode:collectionNode] allObjects];
//}
//
//- (NSEnumerator *)enumeratorOfContainerNode:(RedlandNode *)containerNode
//{
//    return [RedlandContainerEnumerator enumeratorWithModel:self containerNode:containerNode];
//}
//
//- (NSArray *)contentsOfContainerNode:(RedlandNode *)containerNode
//{
//    return [[self enumeratorOfContainerNode:containerNode] allObjects];
//}
//
//- (void)addCollectionNode:(RedlandNode *)collectionNode withContents:(NSArray *)nodeArray
//{
//    NSEnumerator *nodeEnumerator = [nodeArray objectEnumerator];
//    RedlandNode *currentNode, *nextCollectionNode;
//    BOOL first = YES;
//    static RedlandNode *RDFFirstNode = nil;
//    static RedlandNode *RDFRestNode = nil;
//    static RedlandNode *RDFNilNode = nil;
//    
//    if (!RDFFirstNode)
//        RDFFirstNode = [[RDFSyntaxNS node:@"first"] retain];
//    if (!RDFRestNode)
//        RDFRestNode = [[RDFSyntaxNS node:@"rest"] retain];
//    if (!RDFNilNode)
//        RDFNilNode = [[RDFSyntaxNS node:@"nil"] retain];
//    
//    while (currentNode = [nodeEnumerator nextObject]) {
//        if (!first) {
//            nextCollectionNode = [RedlandNode nodeWithBlankID:nil];
//            [self addStatement:[RedlandStatement statementWithSubject:collectionNode
//                                                            predicate:RDFRestNode
//                                                               object:nextCollectionNode]];
//            collectionNode = nextCollectionNode;
//        } 
//        else first = NO;
//        [self addStatement:[RedlandStatement statementWithSubject:collectionNode
//                                                        predicate:RDFFirstNode
//                                                           object:currentNode]];
//    }
//    [self addStatement:[RedlandStatement statementWithSubject:collectionNode
//                                                    predicate:RDFRestNode
//                                                       object:RDFNilNode]];
//}

@end
