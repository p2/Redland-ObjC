//
//  RedlandQueryResults.m
//  Redland Objective-C Bindings
//  $Id: RedlandQueryResults.m 4 2004-09-25 15:49:17Z kianga $
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
    if (isWrappedObjectOwner)
        librdf_free_query_results(wrappedObject);
    [super dealloc];
}

- (librdf_query_results *)wrappedQueryResults
{
	return wrappedObject;
}

- (int)count
{
    return librdf_query_results_get_count(wrappedObject);
}

- (BOOL)next
{
    return librdf_query_results_next(wrappedObject) == 0;
}

- (BOOL)finished
{
    return librdf_query_results_finished(wrappedObject);
}

- (RedlandNode *)valueOfBindingAtIndex:(int)offset
{
    librdf_node *value;
    value = librdf_query_results_get_binding_value(wrappedObject, offset);
	if (value)
		value = librdf_new_node_from_node(value);
    return [[[RedlandNode alloc] initWithWrappedObject:value] autorelease];
}

- (NSString *)nameOfBindingAtIndex:(int)offset
{
    char const *name;
    name = librdf_query_results_get_binding_name(wrappedObject, offset);
    return [[[NSString alloc] initWithUTF8String:name] autorelease];
}

- (RedlandNode *)valueOfBinding:(NSString *)aName
{
    librdf_node *value;
	NSParameterAssert(aName != nil);
    value = librdf_query_results_get_binding_value_by_name(wrappedObject, [aName UTF8String]);
	if (value)
		value = librdf_new_node_from_node(value);
    return [[[RedlandNode alloc] initWithWrappedObject:value] autorelease];
}

- (int)countOfBindings
{
    return librdf_query_results_get_bindings_count(wrappedObject);
}

- (RedlandStream *)stream
{
    librdf_stream *stream;
    stream = librdf_query_results_as_stream(wrappedObject);
    return [[[RedlandStream alloc] initWithWrappedObject:stream] autorelease];
}

- (NSDictionary *)bindings
{
    const char **names = NULL;  
    librdf_node **values;
    NSMutableDictionary *bindings = [NSMutableDictionary new];
    int bindingsCount = [self countOfBindings];
    int i;
    
    values = malloc(sizeof(librdf_node *) * bindingsCount);
    librdf_query_results_get_bindings(wrappedObject, &names, values);
    for (i=0; i<bindingsCount; i++) {
        librdf_node *node;
        id object = [NSNull null];
        if (values[i]) {
            node = librdf_new_node_from_node(values[i]);
            object = [[[RedlandNode alloc] initWithWrappedObject:node] autorelease];
        }
        [bindings setObject:object forKey:[NSString stringWithUTF8String:names[i]]];
    }
    free(values);
    return bindings;
}

- (RedlandQueryResultsEnumerator *)resultEnumerator
{
    return [[[RedlandQueryResultsEnumerator alloc] initWithResults:self] autorelease];
}

- (NSString *)stringRepresentationWithFormat:(RedlandURI *)formatURI baseURI:(RedlandURI *)baseURI
{
	unsigned char *output;
	size_t output_size; 

	NSParameterAssert(formatURI != nil);
	
	output = librdf_query_results_to_counted_string(wrappedObject, [formatURI wrappedURI], [baseURI wrappedURI], &output_size);
	if (output != NULL) {
		return [[[NSString alloc] initWithBytesNoCopy:output length:output_size encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
	}
	else {
		return nil;
	}
}

- (BOOL)isBindings
{
	return librdf_query_results_is_bindings(wrappedObject) != 0;
}

- (BOOL)isBoolean
{
	return librdf_query_results_is_boolean(wrappedObject) != 0;
}

- (BOOL)isGraph
{
	return librdf_query_results_is_graph(wrappedObject) != 0;
}

- (int)getBoolean
{
	return librdf_query_results_get_boolean(wrappedObject);
}

- (RedlandStream *)resultStream
{
	librdf_stream *stream;
	
	stream = librdf_query_results_as_stream(wrappedObject);
	return [[[RedlandStream alloc] initWithWrappedObject:stream owner:NO] autorelease];
}

@end
