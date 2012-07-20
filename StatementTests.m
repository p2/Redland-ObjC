//
//  StatementTests.m
//  Redland Objective-C Bindings
//  $Id: StatementTests.m 4 2004-09-25 15:49:17Z kianga $
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

#import "StatementTests.h"
#import "RedlandStatement.h"
#import "RedlandNode-Convenience.h"

@implementation StatementTests

- (void)testSimple
{
    RedlandStatement *statement;
    RedlandNode *subject = [RedlandNode nodeWithBlankID:@"foo"];
    RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://foo/"];
    RedlandNode *object = [RedlandNode nodeWithLiteralString:@"blah" language:@"en"];
    
    statement = [RedlandStatement statementWithSubject:subject
                                             predicate:predicate
                                                object:object];
    STAssertNotNil(statement, nil);
    STAssertTrue([statement isComplete], nil);
    STAssertEqualObjects(subject, [statement subject], nil);
    STAssertEqualObjects(predicate, [statement predicate], nil);
    STAssertEqualObjects(object, [statement object], nil);
    STAssertEqualObjects(statement, statement, nil);
    
    statement = [RedlandStatement statementWithSubject:subject
                                             predicate:predicate
                                                object:nil];
    STAssertNotNil(statement, nil);
    STAssertFalse([statement isComplete], nil);
}

- (void)testEquality
{
    RedlandStatement *statement1, *statement2;
    RedlandNode *subject = [RedlandNode nodeWithBlankID:@"foo"];
    RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://foo/"];
    RedlandNode *object1 = [RedlandNode nodeWithLiteralString:@"blah" language:@"en"];
    RedlandNode *object2 = [RedlandNode nodeWithLiteralString:@"blah2" language:@"en"];
    
    statement1 = [RedlandStatement statementWithSubject:subject
                                              predicate:predicate
                                                 object:object1];
    statement2 = [RedlandStatement statementWithSubject:subject
                                              predicate:predicate
                                                 object:object2];
    STAssertFalse([statement1 isEqual:statement2], nil);
    STAssertFalse([statement1 matchesPartialStatement:statement2], nil);
    statement2 = [RedlandStatement statementWithSubject:subject
                                              predicate:predicate
                                                 object:object1];
    STAssertEqualObjects(statement1, statement2, nil);
    statement1 = [RedlandStatement statementWithSubject:subject
                                              predicate:predicate
                                                 object:nil];
    STAssertTrue([statement2 matchesPartialStatement:statement1], nil);
}

- (void)testArchiving
{
    RedlandStatement *sourceStatement;
    RedlandStatement *decodedStatement;
    NSData *data;
    
    sourceStatement = [RedlandStatement 
        statementWithSubject:[RedlandNode nodeWithBlankID:@"foo"]
                   predicate:[RedlandNode nodeWithURIString:@"http://foo/"]
                      object:[RedlandNode nodeWithLiteralString:@"hello world" language:@"en"]];
    data = [NSArchiver archivedDataWithRootObject:sourceStatement];
    STAssertNotNil(data, nil);
    decodedStatement = [NSUnarchiver unarchiveObjectWithData:data];
    STAssertNotNil(decodedStatement, nil);
    STAssertEqualObjects(sourceStatement, decodedStatement, nil);
}

@end
