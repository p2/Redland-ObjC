//
//  RedlandWorld.h
//  Redland Objective-C Bindings
//  $Id: RedlandWorld.h 313 2004-11-03 19:00:40Z kianga $
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

@class RedlandNode;


/**
 *  Global context for all Redland functions.
 *
 *  Wraps librdf_world objects. This framework takes care of creating a RedlandWorld instance for you. There is currently no way to create an instance manually
 *  in this version of the framework, and all operations currently use the default instance.
 */
@interface RedlandWorld : RedlandWrappedObject

/// If YES, the receiver will log all Redland errors to the console (in addition to generating exceptions, where appropriate). NO by default.
@property (nonatomic, assign) BOOL logsErrors;

+ (RedlandWorld *)defaultWorld;
+ (librdf_world *)defaultWrappedWorld;

- (librdf_world *)wrappedWorld;

- (int)handleLogMessage:(librdf_log_message *)aMessage;
- (void)handleStoredErrors;

- (RedlandNode *)valueOfFeature:(id)featureURI;
- (void)setValue:(RedlandNode *)featureValue ofFeature:(id)featureURI;


@end
