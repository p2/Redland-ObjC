//
//  RedlandStreamEnumerator.m
//  Redland Objective-C Bindings
//  $Id: RedlandStreamEnumerator.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandStreamEnumerator.h"

#import "RedlandStream.h"
#import "RedlandStatement.h"

@implementation RedlandStreamEnumerator

- (id)initWithRedlandStream:(RedlandStream *)aStream 
{
    return [self initWithRedlandStream:aStream modifier:RedlandReturnStatements];
}

/**
 *  The designated initializer.
 *  @param aStream The stream to enumerate over
 *  @param aModifier The modifier that determines over which parts of the stream the receiver iterates
 */
- (id)initWithRedlandStream:(RedlandStream *)aStream modifier:(RedlandStreamEnumeratorModifier)aModifier
{
    if ((self = [super init])) {
        stream = aStream;
        firstIteration = YES;
        modifier = aModifier;
    }
    return self;
}

/**
 *  Returns the context of the current statement.
 */
- (RedlandNode *)currentContext
{
    NSAssert(firstIteration == NO, @"currentContext called before first object was fetched");
    return [stream context];
}

- (id)nextObject
{
    if (!firstIteration) {
        [stream next];
	}
    else {
        firstIteration = NO;
	}
    
    RedlandStatement *nextStatement = [stream object];
    if (nextStatement) {
        switch (modifier) {
            case RedlandReturnSubjects:
                return [nextStatement subject];
            case RedlandReturnPredicates:
                return [nextStatement predicate];
            case RedlandReturnObjects:
                return [nextStatement object];
            default:
            case RedlandReturnStatements:
                return [nextStatement copy];
        }
    }
    
	return nil;
}


@end
