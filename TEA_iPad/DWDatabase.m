//
//  DWDatabase.m
//  QuizPro
//
//  Created by Oguz Demir on 26/1/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWDatabase.h"


@implementation DWDatabase

NSDictionary *respResponse;

+ (NSArray*) getResultFromURL:(NSURL*)pURL withSQL:(NSString*)pSQL
{
    
    
	NSString *post = [@"_sql=" stringByAppendingString:pSQL];
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length] ];
	
	//NSLog([[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]);
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSError *error = nil;

    
	[request setURL: pURL];
	[request setTimeoutInterval:10000];
    [request setHTTPMethod:@"POST"];
	[request setValue:postLength  forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"text/html; charset=UTF-8"  forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];

	
	NSHTTPURLResponse *response;
   
	NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
   //	NSLog([[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding ]);
	respResponse = [[response allHeaderFields] retain];

	NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:receivedData error:&error];
	
	NSArray *rows = [[dictionary objectForKey:@"rows"] retain];
	return [rows autorelease];
}

@end
