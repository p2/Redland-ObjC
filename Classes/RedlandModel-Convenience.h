//
//  RedlandModel-Convenience.h
//  Redland Objective-C Bindings
//  $Id: RedlandModel-Convenience.h 307 2004-11-02 11:24:18Z kianga $
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


#import "RedlandModel.h"

@class RedlandNode, RedlandStatement, RedlandStreamEnumerator;


@interface RedlandModel (Convenience)

- (RedlandStreamEnumerator *)enumeratorOfStatementsLike:(RedlandStatement *)aStatement;
- (RedlandStreamEnumerator *)enumeratorOfStatementsLike:(RedlandStatement *)aStatement withContext:(RedlandNode *)contextNode;

- (RedlandStreamEnumerator *)statementEnumerator;
- (RedlandStreamEnumerator *)statementEnumeratorWithContext:(RedlandNode *)contextNode;

- (NSEnumerator *)enumeratorOfSourcesWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode;
- (NSEnumerator *)enumeratorOfSourcesWithArc:(RedlandNode *)arcNode target:(RedlandNode *)targetNode context:(RedlandNode *)contextNode;

- (NSEnumerator *)enumeratorOfArcsWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode;
- (NSEnumerator *)enumeratorOfArcsWithSource:(RedlandNode *)sourceNode target:(RedlandNode *)targetNode context:(RedlandNode *)contextNode;

- (NSEnumerator *)enumeratorOfTargetsWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode;
- (NSEnumerator *)enumeratorOfTargetsWithSource:(RedlandNode *)sourceNode arc:(RedlandNode *)arcNode context:(RedlandNode *)contextNode;

- (NSEnumerator *)enumeratorOfArcsIn:(RedlandNode *)targetNode;
- (NSEnumerator *)enumeratorOfArcsIn:(RedlandNode *)targetNode context:(RedlandNode *)contextNode;

- (NSEnumerator *)enumeratorOfArcsOut:(RedlandNode *)sourceNode;
- (NSEnumerator *)enumeratorOfArcsOut:(RedlandNode *)sourceNode context:(RedlandNode *)contextNode;

- (NSEnumerator *)contextEnumerator;


@end
