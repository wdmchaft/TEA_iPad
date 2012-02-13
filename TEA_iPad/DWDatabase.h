//
//  DWDatabase.h
//  QuizPro
//
//  Created by Oguz Demir on 26/1/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"

@interface DWDatabase : NSObject {

}

+ (NSArray*) getResultFromURL:(NSURL*)pURL withSQL:(NSString*)pSQL;


@end
