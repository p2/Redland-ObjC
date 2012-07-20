//
//  RedlandQuery.m
//  Redland Objective-C Bindings
//  $Id: RedlandQuery.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandQuery.h"
#import "RedlandWorld.h"
#import "RedlandURI.h"
#import "RedlandQueryResults.h"
#import "RedlandModel.h"

NSString * const RedlandRDQLLanguageName = @"rdql";
NSString * const RedlandSPARQLLanguageName = @"sparql";

@implementation RedlandQuery

#pragma mark Init and Cleanup

+ (id)queryWithLanguageName:(NSString *)langName queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;
{
	return [[[self alloc] initWithLanguageName:langName queryString:queryString baseURI:baseURI] autorelease];
}

+ (id)queryWithLanguageName:(NSString *)langName languageURI:(RedlandURI *)langURI queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;
{
	return [[[self alloc] initWithLanguageName:langName languageURI:langURI queryString:queryString baseURI:baseURI] autorelease];
}

- (id)initWithLanguageName:(NSString *)langName queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;
{
	NSParameterAssert(langName != nil);
	NSParameterAssert(queryString != nil);
    return [self initWithLanguageName:langName languageURI:nil queryString:queryString baseURI:baseURI];
}

- (id)initWithLanguageName:(NSString *)langName languageURI:(RedlandURI *)langURI queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;
{
    librdf_query *newQuery;
	NSParameterAssert(langName != nil || langURI != nil);
	NSParameterAssert(queryString != nil);
    newQuery = librdf_new_query([RedlandWorld defaultWrappedWorld],
                                [langName UTF8String],
                                [langURI wrappedURI],
                                (unsigned char *)[queryString UTF8String],
								[baseURI wrappedURI]);
    [[RedlandWorld defaultWorld] handleStoredErrors];
    return [self initWithWrappedObject:newQuery];
}

- (void)dealloc
{
    if (isWrappedObjectOwner)
        librdf_free_query(wrappedObject);
    [super dealloc];
}

- (librdf_query *)wrappedQuery
{
	return wrappedObject;
}

- (RedlandQueryResults *)executeOnModel:(RedlandModel *)aModel
{
    librdf_query_results *results;
	NSParameterAssert(aModel != nil);
    results = librdf_query_execute(wrappedObject, [aModel wrappedModel]);
    [[RedlandWorld defaultWorld] handleStoredErrors];
    return [[[RedlandQueryResults alloc] initWithWrappedObject:results] autorelease];
}

- (int)limit
{
	return librdf_query_get_limit(wrappedObject);
}

- (void)setLimit:(int)newLimit
{
	librdf_query_set_limit(wrappedObject, newLimit);
}

- (int)offset
{
	return librdf_query_get_offset(wrappedObject);
}

- (void)setOffset:(int)newOffset
{
	librdf_query_set_offset(wrappedObject, newOffset);
}

@end
