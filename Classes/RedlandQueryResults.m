//
//  RedlandQueryResults.m
//  Redland Objective-C Bindings
//  $Id: RedlandQueryResults.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandQueryResults.h"
#import "RedlandStream.h"
#import "RedlandNode.h"
#import "RedlandQueryResultsEnumerator.h"
#import "RedlandURI.h"

/*! SPARQL Variable Binding Results XML Format (see http://www.w3.org/TR/2004/WD-rdf-sparql-XMLres-20041221/) */
RedlandURI * RedlandSPARQLVariableBindingResultsXMLFormat = nil;

@implementation RedlandQueryResults

+ (void)initialize
{
	if (RedlandSPARQLVariableBindingResultsXMLFormat == nil) {
		RedlandSPARQLVariableBindingResultsXMLFormat = [[RedlandURI alloc] initWithString:@"http://www.w3.org/TR/2004/WD-rdf-sparql-XMLres-20041221/"];
	}
}

- (void)dealloc
{
    if (isWrappedObjectOwner) {
        librdf_free_query_results(wrappedObject);
	}
}

/*!
	@return Returns the underlying librdf_query_results object of the receiver.
 */
- (librdf_query_results *)wrappedQueryResults
{
	return wrappedObject;
}



#pragma mark - Advancing
/*!
	@return Returns the number of bindings so far
 */
- (int)count
{
    return librdf_query_results_get_count(wrappedObject);
}

/*!
	Advances to the next result.
	@return Returns YES if there is a next result, otherwise NO.
 */
- (BOOL)next
{
    return librdf_query_results_next(wrappedObject) == 0;
}

/*!
	@return Returns YES if the query results are exhausted.
 */
- (BOOL)finished
{
    return librdf_query_results_finished(wrappedObject);
}



#pragma mark - Values
/*!
 @return Returns the current value of the binding with the given name.
 */
- (RedlandNode *)valueOfBinding:(NSString *)aName
{
	NSParameterAssert(aName != nil);
    librdf_node *value = librdf_query_results_get_binding_value_by_name(wrappedObject, [aName UTF8String]);
	if (value) {
		value = librdf_new_node_from_node(value);
	}
    return [[RedlandNode alloc] initWithWrappedObject:value];
}

/*!
	@return Returns the current value of the binding at the given index.
 */
- (RedlandNode *)valueOfBindingAtIndex:(int)offset
{
    librdf_node * = librdf_query_results_get_binding_value(wrappedObject, offset);
	if (value) {
		value = librdf_new_node_from_node(value);
	}
    return [[RedlandNode alloc] initWithWrappedObject:value];
}

/*!
	@return Returns the name of the binding at the given index.
 */
- (NSString *)nameOfBindingAtIndex:(int)offset
{
    char const *name = librdf_query_results_get_binding_name(wrappedObject, offset);
    return [[NSString alloc] initWithUTF8String:name];
}

/*!
	@return Returns the number of bindings of the receiver.
 */
- (int)countOfBindings
{
    return librdf_query_results_get_bindings_count(wrappedObject);
}

/*!
	@return Returns an RDF graph of the results.
	@attention The return value is only meaningful if this is an RDF graph query result.
 */
- (RedlandStream *)resultStream
{
	librdf_stream *stream = librdf_query_results_as_stream(wrappedObject);
	return [[RedlandStream alloc] initWithWrappedObject:stream];
}

/*!
	@return Returns a dictionary of the current result bindings.
 */
- (NSDictionary *)bindings
{
    const char **names = NULL;  
    librdf_node **values;
    NSMutableDictionary *bindings = [NSMutableDictionary new];
    int bindingsCount = [self countOfBindings];
    int i = 0;
    
    values = malloc(sizeof(librdf_node *) * bindingsCount);
    librdf_query_results_get_bindings(wrappedObject, &names, values);
    for (; i<bindingsCount; i++) {
        librdf_node *node;
        id object = [NSNull null];
        if (values[i]) {
            node = librdf_new_node_from_node(values[i]);
            object = [[RedlandNode alloc] initWithWrappedObject:node];
        }
        [bindings setObject:object forKey:[NSString stringWithUTF8String:names[i]]];
    }
    free(values);
    return bindings;
}

/*!
	@return Returns an enumerator over the query results.
	@attention This is the recommended way to evaluate query results.
 */
- (RedlandQueryResultsEnumerator *)resultEnumerator
{
    return [[RedlandQueryResultsEnumerator alloc] initWithResults:self];
}

/*!
	Turns query results into a string in the specified format.
 */
- (NSString *)stringRepresentationWithFormat:(RedlandURI *)formatURI baseURI:(RedlandURI *)baseURI
{
	NSParameterAssert(formatURI != nil);
	
	size_t output_size;
	unsigned char *output = librdf_query_results_to_counted_string(wrappedObject, [formatURI wrappedURI], [baseURI wrappedURI], &output_size);
	if (output != NULL) {
		return [[NSString alloc] initWithBytesNoCopy:output length:output_size encoding:NSUTF8StringEncoding freeWhenDone:YES];
	}
	
	return nil;
}

/*!
	@return Returns YES if the query results are in variable bindings format.
 */
- (BOOL)isBindings
{
	return librdf_query_results_is_bindings(wrappedObject) != 0;
}

/*!
	@return Returns YES if the query results are in boolean format.
 */
- (BOOL)isBoolean
{
	return librdf_query_results_is_boolean(wrappedObject) != 0;
}

/*!
	@return Returns YES if the query results are in graph format.
 */
- (BOOL)isGraph
{
	return librdf_query_results_is_graph(wrappedObject) != 0;
}

/*!
	Get boolean query result.
	@result Returns > 0 if true, 0 if false, < 0 on error or finished
	@attention The return value is only meaningful if this is a boolean query result.
 */
- (int)getBoolean
{
	return librdf_query_results_get_boolean(wrappedObject);
}


@end
