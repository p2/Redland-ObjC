//
//  RedlandWorld.m
//  Redland Objective-C Bindings
//  $Id: RedlandWorld.m 4 2004-09-25 15:49:17Z kianga $
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

#import "RedlandWorld.h"
#import "RedlandNamespace.h"
#import "RedlandException.h"
#import "RedlandURI.h"
#import "RedlandNode.h"

static int redland_log_handler(void *user_data, librdf_log_message *message)
{
    if (user_data && [(__bridge id)user_data isKindOfClass:[RedlandWorld class]]) {
		return [(__bridge RedlandWorld *)user_data handleLogMessage:message];
	}
	DLog(@"Redland logged without providing the user object. Letting default world handle it.");
	return [[RedlandWorld defaultWorld] handleLogMessage:message];
}


@interface RedlandWorld ()

@property (nonatomic, copy) NSError *lastError;							//< Most recent error
@property (nonatomic, strong) NSMutableArray *storedErrors;				//< All so far unhandled errors

@end


@implementation RedlandWorld

@synthesize logsErrors;
@synthesize lastError, storedErrors = _storedErrors;


#pragma mark - Init and Cleanup

+ (void)initialize
{
    [RedlandNamespace initGlobalNamespaces];
}

/**
 *  Returns the default RedlandWorld instance.
 */
+ (RedlandWorld *)defaultWorld
{
    static RedlandWorld *defaultInstance = nil;
    
    if (defaultInstance == nil) {
        librdf_world *world = librdf_new_world();
        NSAssert(NULL != world, @"Failed to initialize librdf_world");
		
        defaultInstance = [[RedlandWorld alloc] initWithWrappedObject:world];
		defaultInstance.logsErrors = YES;
		
        librdf_world_open(world);
        librdf_world_set_logger(world, (__bridge void *)(defaultInstance), &redland_log_handler);
    }
    return defaultInstance;
}

- (void)dealloc
{
    if (isWrappedObjectOwner) {
        librdf_free_world(wrappedObject);
	}
}



#pragma mark - Accessors
/**
 *  Returns the underlying librdf_world pointer of the default RedlandWorld instance.
 */
+ (librdf_world *)defaultWrappedWorld
{
    return [[self defaultWorld] wrappedWorld];
}

/**
 *  Returns the underlying librdf_world pointer of the receiver.
 */
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



#pragma mark - Features
/**
 *  Returns the value of the world feature identified by featureURI.
 *  @param featureURI An NSString or a RedlandURI instance
 */
- (RedlandNode *)valueOfFeature:(id)featureURI
{
	librdf_node *feature_value;
	librdf_uri *feature_uri;
	NSParameterAssert(featureURI != nil);
	
	if ([featureURI isKindOfClass:[NSString class]]) {
		featureURI = [RedlandURI URIWithString:featureURI];
	}
	NSAssert([featureURI isKindOfClass:[RedlandURI class]], @"featureURI has invalid class");
	
	feature_uri = [featureURI wrappedURI];
	feature_value = librdf_world_get_feature(wrappedObject, feature_uri);
	
	return [[RedlandNode alloc] initWithWrappedObject:feature_value];
}

/**
 *  Sets the world feature identified by featureURI to a new value.
 *  @param featureValue A RedlandNode representing the new value
 *  @param featureURI An NSString or a RedlandURI instance
 *  @warning Raises a RedlandException is no such feature exists.
 */
- (void)setValue:(RedlandNode *)featureValue ofFeature:(id)featureURI
{
	int result;
	NSParameterAssert(featureURI != nil);
	
	if ([featureURI isKindOfClass:[NSString class]]) {
		featureURI = [RedlandURI URIWithString:featureURI];
	}
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



#pragma mark - Error Handling
/**
 *  Adds an librdf_log_message to the internal storedErrors array.
 *  Errors are collected until -[RedlandWorld handleStoredErrors] is called, which then throws an exception with all collected errors.
 *  
 *  @param aMessage A librdf_log_message pointer.
 *  @warning Behavior of this method is subject to change. Do not use.
 */
- (int)handleLogMessage:(librdf_log_message *)aMessage
{
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
							  [NSString stringWithUTF8String:aMessage->message], @"message",
							  [NSNumber numberWithInt:aMessage->level], @"level",
							  [NSNumber numberWithInt:aMessage->facility], @"facility",
							  [NSValue valueWithPointer:aMessage->locator], @"locator",
							  nil];
	if ([self logsErrors]) {
		NSLog(@"Redland Error %d: %@", aMessage->code, infoDict);
	}
    [self.storedErrors addObject:[NSError errorWithDomain:RedlandErrorDomain
                                                code:aMessage->code 
                                            userInfo:infoDict]];
    
    return 1;
}

/**
 *  Checks if there are any collected errors, in which case it throws an exception with the error array inside userInfo dictionary.
 *  @warning Behavior of this method is subject to change. Do not use.
 */
- (void)handleStoredErrors
{
    NSArray *errorArray;
    NSException *exception;
    
    if (0 == [_storedErrors count]) {
        return;
	}
    
    errorArray = [[NSArray alloc] initWithArray:_storedErrors];
    exception = [RedlandException exceptionWithName:RedlandExceptionName
                                             reason:@"Redland Exception"
                                           userInfo:@{ @"storedErrors": errorArray }];
    [_storedErrors removeAllObjects];
    [exception raise];
}



#pragma mark - KVC
- (NSMutableArray *)storedErrors
{
	if (!_storedErrors) {
		self.storedErrors = [NSMutableArray new];
	}
	return _storedErrors;
}


@end
