//
//  RedlandQuery.h
//  Redland Objective-C Bindings
//  $Id: RedlandQuery.h 1116 2005-08-23 16:07:35Z kianga $
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

#import <Foundation/Foundation.h>
#import <redland.h>
#import "RedlandWrappedObject.h"

extern NSString * const RedlandRDQLLanguageName;				///< The name of the RDQL query language (no longer supported as of Jan 2013!)
extern NSString * const RedlandSPARQLLanguageName;				///< The name of the SPARQL query language

@class RedlandURI, RedlandQueryResults, RedlandModel;


/**
 *  This class provides query language support for RDF models.
 */
@interface RedlandQuery : RedlandWrappedObject

@property (nonatomic, assign) int limit;
@property (nonatomic, assign) int offset;

+ (id)queryWithLanguageName:(NSString *)langName queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;
+ (id)queryWithLanguageName:(NSString *)langName languageURI:(RedlandURI *)uri queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;

- (id)initWithLanguageName:(NSString *)langName queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;
- (id)initWithLanguageName:(NSString *)langName languageURI:(RedlandURI *)uri queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;

- (librdf_query *)wrappedQuery;

- (RedlandQueryResults *)executeOnModel:(RedlandModel *)aModel;


@end
