//
//  StorageTests.m
//  Redland Objective-C Bindings
//
//  Copyright 2004 Rene Puls <http://purl.org/net/kianga/>
//	Copyright 2012 Pascal Pfiffner <http://www.chip.org/>
//	Copyright 2014 Marcus Rohrmoser mobile Softare <http://blog.mro.name/>
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

#import "StorageTests.h"

#import "RedlandStorage.h"
#import "RedlandWorld.h"
#import <redland.h>

@implementation StorageTests

- (void)testSimple
{
    RedlandStorage *storage;
    
    storage = [RedlandStorage new];
    STAssertNotNil(storage, nil);
}


-(void)testSqlitePresence
{
    // List available storage factories.
    for(int counter = 0;;counter++) {
        const char *name = NULL;
        const char *label = NULL;
        if(0 != librdf_storage_enumerate([RedlandWorld defaultWrappedWorld], counter, &name, &label))
            break;
        if (0 == strcmp("sqlite", name)) {
            // how nice - found it.
            return;
        }
    }
    STFail(@"storage factory 'sqlite' not present.");
}

@end
