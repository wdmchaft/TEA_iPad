//
//  ConfigurationManager.m
//  tea
//
//  Created by Oguz Demir on 8/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "ConfigurationManager.h"


@implementation ConfigurationManager

static NSMutableDictionary *settingsDictionary;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

+ (id) getConfigurationValueForKey:(NSString*)key
{
    if(!settingsDictionary)
    {
        settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]];
    }
    return [settingsDictionary objectForKey:key];
}


+ (void) setConfigurationValue:(id)aValue forKey:(id)aKey
{
    if(!settingsDictionary)
    {
        settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]];
    }
    [settingsDictionary setValue:aValue forKey:aKey];
    
}

+ (BOOL) containsValueForKey:(id)aKey
{
    if(settingsDictionary)
    {
        if([settingsDictionary objectForKey:aKey])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return NO;
}

@end
