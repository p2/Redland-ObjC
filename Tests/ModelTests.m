//
//  ModelTests.m
//  Redland Objective-C Bindings
//  $Id: ModelTests.m 4 2004-09-25 15:49:17Z kianga $
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

#import "ModelTests.h"

#import "RedlandModel-Convenience.h"
#import "RedlandNode-Convenience.h"
#import "RedlandStatement.h"
#import "RedlandStreamEnumerator.h"

@implementation ModelTests

- (void)testSimple
{
    RedlandNode *subject = [RedlandNode nodeWithBlankID:@"foo"];
    RedlandNode *predicate = [RedlandNode nodeWithURIString:@"foo:bar"];
    RedlandNode *object = [RedlandNode nodeWithLiteral:@"test"];
    RedlandNode *object2 = [RedlandNode nodeWithLiteral:@"another test"];
    
    RedlandModel *model = [RedlandModel new];
    STAssertNotNil(model, nil);
    
    RedlandStatement *testStatement = [RedlandStatement statementWithSubject:subject
																   predicate:predicate
																	  object:object];
	RedlandStatement *secondStatement = [RedlandStatement statementWithSubject:subject
																	 predicate:predicate
																		object:object2];
	RedlandStatement *likeStatement = [RedlandStatement statementWithSubject:subject
																   predicate:predicate
																	  object:nil];

    STAssertNoThrow([model addStatement:testStatement], nil);
    STAssertEquals(1, [model size], nil);
    STAssertTrue([model containsStatement:testStatement], nil);
    STAssertEqualObjects(subject, [model sourceWithArc:predicate target:object], nil);
    STAssertEqualObjects(predicate, [model arcWithSource:subject target:object], nil);
    STAssertEqualObjects(object, [model targetWithSource:subject arc:predicate], nil);
    STAssertTrue([model node:object hasIncomingArc:predicate], nil);
    STAssertTrue([model node:subject hasOutgoingArc:predicate], nil);
    STAssertNoThrow([model removeStatement:testStatement], nil);
    STAssertFalse([model containsStatement:testStatement], nil);
	
	STAssertNoThrow([model addStatement:testStatement], nil);
	STAssertNoThrow([model addStatement:secondStatement], nil);
    STAssertEquals(2, [model size], nil);
	STAssertNoThrow([model removeStatementsLike:likeStatement], nil);
    STAssertEquals(0, [model size], nil);
}

- (void)testSubmodel
{
	RedlandNode *content = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#Content"];
	
	RedlandStatement *main = [RedlandStatement statementWithSubject:[RedlandNode nodeWithBlankID:@"foo"]
														  predicate:[RedlandNode typeNode]
															 object:content];
	RedlandStatement *sub1 = [RedlandStatement statementWithSubject:content
														  predicate:[RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#encoding"]
															 object:[RedlandNode nodeWithLiteral:@"UTF-8"]];
	RedlandStatement *sub2 = [RedlandStatement statementWithSubject:content
														  predicate:[RedlandNode nodeWithURIString:@"http://purl.org/dc/terms/date"]
															 object:[RedlandNode nodeWithLiteral:@"2013-06-12"]];
	
	// create the model
	RedlandModel *model = [RedlandModel new];
	STAssertNoThrow([model addStatement:main], nil);
	STAssertNoThrow([model addStatement:sub1], nil);
	STAssertNoThrow([model addStatement:sub2], nil);
    STAssertEquals(3, [model size], nil);
	
	RedlandModel *submodel = [model submodelForSubject:content];
	STAssertEquals(2, [submodel size], nil);
	for (RedlandStatement *statement in [submodel statementEnumerator]) {
		STAssertTrue([model containsStatement:statement], nil);
	}
	
	// removing and re-adding
	STAssertTrue([model removeSubmodel:submodel], nil);
	STAssertEquals(1, [model size], nil);
	
	STAssertTrue([model addSubmodel:submodel], nil);
	STAssertEquals(3, [model size], nil);
}

- (void)testContextAddStatementBug
{
    RedlandNode *subject = [RedlandNode nodeWithBlankID:@"foo"];
    RedlandNode *predicate = [RedlandNode nodeWithURIString:@"foo:bar"];
    RedlandNode *object = [RedlandNode nodeWithLiteral:@"test"];
	RedlandStatement *statement;

	RedlandModel *model = [RedlandModel new];
    statement = [RedlandStatement statementWithSubject:subject
											 predicate:predicate
												object:object];
	STAssertNoThrow([model addStatement:statement withContext:nil], nil);
}


@end
