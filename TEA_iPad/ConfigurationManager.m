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

+ (void) getSettings
{
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]];
    
    NSString *configFileURL = [tmpDict valueForKey:@"ConfigFileURL"];
    if([configFileURL isEqualToString:@"local"])
    {
        if([[tmpDict valueForKey:@"ConfigurationMode"] isEqualToString:@"dev"])
        {
            settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config_dev" ofType:@"plist"]];
        }
        else
        {
            settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config_prod" ofType:@"plist"]];
        }
    }
    else
    {
        NSURL *configUrl = nil;
        if([[tmpDict valueForKey:@"ConfigurationMode"] isEqualToString:@"dev"])
        {
            configUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/config_dev.plist", configFileURL]];
        }
        else
        {
            configUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/config_prod.plist", configFileURL]];
        }
        
        settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfURL:configUrl];
    }
    
    [tmpDict release];
    
}

+ (id) getConfigurationValueForKey:(NSString*)key
{
    if(!settingsDictionary)
    {
        [ConfigurationManager getSettings];
    }
    return [settingsDictionary objectForKey:key];
}


+ (void) setConfigurationValue:(id)aValue forKey:(id)aKey
{
    if(!settingsDictionary)
    {
        [ConfigurationManager getSettings];
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
