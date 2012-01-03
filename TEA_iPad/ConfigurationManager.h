//
//  ConfigurationManager.h
//  tea
//
//  Created by Oguz Demir on 8/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ConfigurationManager : NSObject {
@private
    
}

+ (id) getConfigurationValueForKey:(NSString*)key;
+ (void) setConfigurationValue:(id)aValue forKey:(id)aKey;
+ (BOOL) containsValueForKey:(id)aKey;

@end
