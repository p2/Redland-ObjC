//
//  RedlandWorld.m
//  Redland Objective-C Bindings
//  $Id: RedlandWorld.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandWorld.h"
#import "RedlandNamespace.h"
#import "RedlandException.h"
#import "RedlandURI.h"
#import "RedlandNode.h"

static int redland_log_handler(void *user_data, librdf_log_message *message)
{
    NSCParameterAssert(user_data != NULL);
    NSCParameterAssert(message != NULL);
    return [(RedlandWorld *)user_data handleLogMessage:message];
}

@implementation RedlandWorld

#pragma mark Init and Cleanup

+ (void)initialize
{
    [RedlandNamespace initGlobalNamespaces];
}

+ (RedlandWorld *)defaultWorld
{
    static RedlandWorld *defaultInstance = nil;
    
    if (defaultInstance == nil) {
        librdf_world *world;
        
        world = librdf_new_world();
        NSAssert(world != NULL, @"Failed to initialize librdf_world");
        defaultInstance = [[RedlandWorld alloc] initWithWrappedObject:world];
        librdf_world_open(world);
        librdf_world_set_logger(world, defaultInstance, &redland_log_handler);
    }
    return defaultInstance;
}

- (id)initWithWrappedObject:(void *)object
{
    if (self = [super initWithWrappedObject:object]) {
        storedErrors = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc
{
    [storedErrors release];
    if (isWrappedObjectOwner)
        librdf_free_world(wrappedObject);
    [super dealloc];
}

#pragma mark Accessors

+ (librdf_world *)defaultWrappedWorld
{
    return [[self defaultWorld] wrappedWorld];
}

- (librdf_world *)wrappedWorld
{
    return wrappedObject;
}

- (BOOL)logsErrors
{
	return logsErrors;
}

- (void)setLogsErrors:(BOOL)flag
{
	logsErrors = flag;
}

#pragma mark Features

- (RedlandNode *)valueOfFeature:(id)featureURI
{
	librdf_node *feature_value;
	librdf_uri *feature_uri;
	NSParameterAssert(featureURI != nil);
	
	if ([featureURI isKindOfClass:[NSString class]])
		featureURI = [RedlandURI URIWithString:featureURI];
	NSAssert([featureURI isKindOfClass:[RedlandURI class]], @"featureURI has invalid class");
	
	feature_uri = [featureURI wrappedURI];
	feature_value = librdf_world_get_feature(wrappedObject, feature_uri);
	
	return [[[RedlandNode alloc] initWithWrappedObject:feature_value] autorelease];
}

- (void)setValue:(RedlandNode *)featureValue ofFeature:(id)featureURI
{
	int result;
	NSParameterAssert(featureURI != nil);
	
	if ([featureURI isKindOfClass:[NSString class]])
		featureURI = [RedlandURI URIWithString:featureURI];
	NSAssert([featureURI isKindOfClass:[RedlandURI class]], @"featureURI has invalid class");
	
	result = librdf_world_set_feature(wrappedObject, 
									  [featureURI wrappedURI], 
									  [featureValue wrappedNode]);
	if (result > 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"librdf_world_set_feature returned >0"
										  userInfo:nil];
	}
	else if (result < 0) {
		@throw [RedlandException exceptionWithName:RedlandExceptionName
											reason:@"No such feature"
										  userInfo:nil];
	}
}

#pragma mark Error Handling

// Adds an librdf_log_message to the internal storedErrors array.
// Errors are collected until -[RedlandWorld handleStoredErrors] is called,
// which then throws an exception with all collected errors.

- (int)handleLogMessage:(librdf_log_message *)aMessage
{
    NSDictionary *infoDict;

    NSParameterAssert(aMessage != NULL);
	    
    infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithUTF8String:aMessage->message], @"message",
        [NSNumber numberWithInt:aMessage->level], @"level",
        [NSNumber numberWithInt:aMessage->facility], @"facility",
        [NSValue valueWithPointer:aMessage->locator], @"locator",
        nil];
	if ([self logsErrors])
		NSLog(@"Redland Error: %@", infoDict);
    [storedErrors addObject:[NSError errorWithDomain:RedlandErrorDomain 
                                                code:aMessage->code 
                                            userInfo:infoDict]];
    [infoDict release];
    
    return 1;
}

// Checks if there are any collected errors, in which case it throws an 
// exception with the error array inside userInfo dictionary.

- (void)handleStoredErrors
{
    NSArray *errorArray;
    NSException *exception;
    
    if ([storedErrors count] == 0)
        return;
    
    errorArray = [[NSArray alloc] initWithArray:storedErrors];
    exception = [RedlandException exceptionWithName:RedlandExceptionName
                                             reason:@"Redland Exception"
                                           userInfo:[NSDictionary dictionaryWithObject:errorArray forKey:@"storedErrors"]];
    [errorArray release];
    [storedErrors removeAllObjects];
    [exception raise];
}

@end
