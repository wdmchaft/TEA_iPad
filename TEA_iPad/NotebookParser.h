//
//  NotebookParser.h
//  TEA_iPad
//
//  Created by Oguz Demir on 6/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notebook.h"

@interface NotebookParser : NSObject <NSXMLParserDelegate> 
{
    Notebook *notebook;
    int pageCount;
    
    NSString *currentElement;
}

- (Notebook*) getNotebookWithXMLString:(NSString*) pXml;
- (void) getNotebookWithXMLData:(NSData*) pXmlData;

@property (nonatomic, assign)  Notebook *notebook;

@end
