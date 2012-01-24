//
//  HWParser.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 1/12/12.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWParser : NSObject <NSXMLParserDelegate>
{
    NSMutableDictionary *question;
    NSMutableDictionary *quiz;
    
    NSString *currentElement;
    NSString *foundCharacters;
    
   // NSString *zipFileName;
}

@property (nonatomic, retain) NSMutableDictionary *quiz;
//@property (nonatomic, retain) NSString *zipFileName;

- (void) parseXml:(NSData *)xmlData;
//- (void) extractZipFile;

@end