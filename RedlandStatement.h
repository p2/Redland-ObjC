//
//  RedlandStatement.h
//  Redland Objective-C Bindings
//  $Id: RedlandStatement.h 313 2004-11-03 19:00:40Z kianga $
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
	@header RedlandStatement.h
	Defines the RedlandStatement class.
*/

#import <Foundation/Foundation.h>
#import <Redland/redland.h>
#import "RedlandWrappedObject.h"

@class RedlandNode;

/*! 
	@class RedlandStatement
	@abstract A RedlandStatement represents a single statement or assertion in an RDF graph.
	@discussion Each statement consists of a subject, a predicate and an object, which are all of the class RedlandNode. Wraps librdf_statement. Instances of RedlandStatement conform to the NSCopying and NSCoding protocols.
*/
@interface RedlandStatement : RedlandWrappedObject <NSCopying, NSCoding> {
}

/*! @method statementWithSubject:predicate:object:
    @abstract Convenience method which returns an autoreleased statement initialized using initWithSubject:predicate:object:.
*/
+ (RedlandStatement *)statementWithSubject:(id)subject predicate:(id)predicate object:(id)object;


/*! @method initWithSubject:predicate:object:
	@abstract Initializes a new RedlandStatement.
	@param subject An object representing the subject or source of the statement.
	@param predicate An object representing the predicate or arc of the statement.
	@param object An object representing the object or target of the statement.
	@discussion Each parameter can be either be nil, of type RedlandNode, or of any other class that responds to the selector <tt>nodeValue</tt>. The Redland Objective-C framework provides additional <tt>nodeValue</tt> methods for the core Cocoa classes NSString, NSNumber, NSURL, and NSDate.
*/
- (id)initWithSubject:(id)subjectNode predicate:(id)predicateNode object:(id)objectNode;

/*!
	@method wrappedStatement
	@abstract Returns the underlying librdf_statement pointer of the receiver.
*/
- (librdf_statement *)wrappedStatement;

/*! 
	@method subject
	@abstract Returns the subject of the receiver (may be nil).
*/
- (RedlandNode *)subject;

/*! 
	@method predicate
	@abstract Returns the predicate of the receiver (may be nil).
*/
- (RedlandNode *)predicate;

/*! 
	@method object
	@abstract Returns the object of the receiver (may be nil).
*/
- (RedlandNode *)object;

/*! 
	@method print
	@abstract Prints a description of the receiver to standard error.
	@discussion For debugging purposes.
*/
- (void)print;

/*! 
	@method matchesPartialStatement:
	@abstract Returns YES if the receiver matches aStatement.
	@param aStatement The statement to compare the receiver to.
	@discussion All parts of aStatement which are non-nil must be equal to their counterparts in the receiver.
*/
- (BOOL)matchesPartialStatement:(RedlandStatement *)aStatement;

/*! 
	@method isComplete
	@abstract Returns YES if the receiver has all non-nil subject, predicate, and object parts. 
*/
- (BOOL)isComplete;
@end
