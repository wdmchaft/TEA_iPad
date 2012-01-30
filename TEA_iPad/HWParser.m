//
//  HWParser.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 1/12/12.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import "HWParser.h"


@implementation HWParser

@synthesize quiz;

- (id) init {
    self = [super init];
    if (self) {
        currentElement = @"";
        foundCharacters = @"";
        
            }
    return self;
}






- (void) parseXml:(NSData *)xmlData
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
	[parser setDelegate:self];
    
	[parser parse];
	[parser release];
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
    currentElement = elementName;
    
    if ([elementName isEqualToString:@"quiz"]) {
        quiz = [[NSMutableDictionary alloc] init];
        [quiz setObject:[attributeDict objectForKey:@"guid"] forKey:@"guid"];
        [quiz setObject:[attributeDict objectForKey:@"totalTime"] forKey:@"totalTime"];
        [quiz setObject:[attributeDict objectForKey:@"finished"] forKey:@"finishedTime"];
        [quiz setObject:[[[NSMutableArray alloc]init] autorelease] forKey:@"questions"];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if([currentElement isEqualToString:@"question"])
    {
        question = [[[NSMutableDictionary alloc] init] autorelease];

    }
    else if ([currentElement isEqualToString:@"index"] || [currentElement isEqualToString:@"text"] || [currentElement isEqualToString:@"type"]|| [currentElement isEqualToString:@"number"]|| [currentElement isEqualToString:@"imageURL"]|| [currentElement isEqualToString:@"correctAnswer"]|| [currentElement isEqualToString:@"answer"]|| [currentElement isEqualToString:@"optionCount"]|| [currentElement isEqualToString:@"elapsedTime"])
    {
        foundCharacters = [foundCharacters stringByAppendingFormat:string];
    }

}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([currentElement isEqualToString:@"index"])
    {
        [question setObject:foundCharacters forKey:@"index"];
    }
    else if([currentElement isEqualToString:@"text"])
    {
        [question setObject:foundCharacters forKey:@"text"];
    }
    else if([currentElement isEqualToString:@"type"])
    {
        [question setObject:foundCharacters forKey:@"type"];
    }
    else if([currentElement isEqualToString:@"number"])
    {
        [question setObject:foundCharacters forKey:@"number"];
    }
    else if([currentElement isEqualToString:@"imageURL"])
    {
        [question setObject:foundCharacters forKey:@"imageURL"];
    }
    else if([currentElement isEqualToString:@"correctAnswer"])
    {
        [question setObject:foundCharacters forKey:@"correctAnswer"];
    }
    else if([currentElement isEqualToString:@"answer"])
    {
        [question setObject:foundCharacters forKey:@"answer"];
    }
    else if([currentElement isEqualToString:@"optionCount"])
    {
        [question setObject:foundCharacters forKey:@"optionCount"];
    }
    else if([currentElement isEqualToString:@"elapsedTime"])
    {
        [question setObject:foundCharacters forKey:@"elapsedTime"];
    }
    
    
    if ([elementName isEqualToString:@"question"]){
        [[quiz objectForKey:@"questions"] addObject:question];
    }
    
    foundCharacters = @"";
    currentElement = @"";
}

- (void)dealloc {
    [question release];
    [super dealloc];
}

@end
