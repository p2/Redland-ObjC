//
//  WorldTests.m
//  Redland Objective-C Bindings
//  $Id: WorldTests.m 4 2004-09-25 15:49:17Z kianga $
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

#import "WorldTests.h"
#import "RedlandWorld.h"

@implementation WorldTests

- (void)testDefaultWorld
{
    STAssertEquals([RedlandWorld defaultWorld], [RedlandWorld defaultWorld], nil);
    STAssertTrue([RedlandWorld defaultWrappedWorld] != NULL, nil);
    STAssertEquals([RedlandWorld defaultWrappedWorld], [RedlandWorld defaultWrappedWorld], nil);
}

@end
