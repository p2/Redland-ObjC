//
//  RedlandQuery.h
//  Redland Objective-C Bindings
//  $Id: RedlandQuery.h 1116 2005-08-23 16:07:35Z kianga $
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

/*!
	@header RedlandQuery.h
	Defines the RedlandQuery class.
*/

#import <Foundation/Foundation.h>
#import <Redland/redland.h>
#import "RedlandWrappedObject.h"

/*! The name of the RDQL query language. */
extern NSString * const RedlandRDQLLanguageName;

/*! The name of the SPARQL query language. */
extern NSString * const RedlandSPARQLLanguageName;

@class RedlandURI, RedlandQueryResults, RedlandModel;

/*!
	@class RedlandQuery
	@abstract This class provides query language support for RDF models.
*/
@interface RedlandQuery : RedlandWrappedObject {
}

/*!
    @method queryWithLanguageName:queryString:baseURI:
    @abstract Returns an autoreleased RedlandQuery initialized using initWithLanguageName:queryString:.
*/
+ (id)queryWithLanguageName:(NSString *)langName queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;

/*!
	@method initWithLanguageName:queryString:baseURI:
	@abstract Initializes a RedlandQuery with the given language name and query string.
	@param langName The only supported language name is currently the constant <tt>RedlandRDQLLanguageName</tt>.
	@param queryString The query string in the given language
*/
- (id)initWithLanguageName:(NSString *)langName queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;

/*!
    @method queryWithLanguageName:languageURI:queryString:baseURI:
    @abstract Returns an autoreleased RedlandQuery initialized using initWithLanguageName:languageURI:queryString:.
*/
+ (id)queryWithLanguageName:(NSString *)langName languageURI:(RedlandURI *)uri queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;

/*!
	@method initWithLanguageName:languageURI:queryString:baseURI:
	@abstract Initializes a RedlandQuery with the given language name or URI and query string.
	@param langName The only supported language name is currently the constant <tt>RedlandRDQLLanguageName</tt>.
	@param uri The URI identifying the requested query language
	@param queryString The query string in the given language
*/
- (id)initWithLanguageName:(NSString *)langName languageURI:(RedlandURI *)uri queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;

/*!
	@method wrappedQuery
	@abstract Returns the underlying librdf_query object of the receiver.
*/
- (librdf_query *)wrappedQuery;

/*!
	@method executeOnModel:
	@abstract Run the query on the given model.
	@result A RedlandQueryResults object
*/
- (RedlandQueryResults *)executeOnModel:(RedlandModel *)aModel;

/*!
    @method limit
    @abstract Get the query-specified limit on results.
    @result integer >=0 if a limit is given, otherwise <0
*/
- (int)limit;

/*!
    @method setLimit
    @abstract Set the query-specified limit on results. This is the limit given in the query on the number of results allowed.
    @param newLimit the limit on results, >=0 to set a limit, <0 to have no limit
*/
- (void)setLimit:(int)newLimit;

/*!
    @method offset
    @abstract Get the query-specified offset on results. This is the offset given in the query on the number of results allowed.
    @result integer >=0 if a offset is given, otherwise <0
*/
- (int)offset;

/*!
    @method setOffset:
    @abstract Set the query-specified offset on results. This is the offset given in the query on the number of results allowed.
    @param newOffset offset for results, >=0 to set an offset, <0 to have no offset
*/
- (void)setOffset:(int)newOffset;
@end
