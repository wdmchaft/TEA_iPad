//
//  BonjourDeviceInfoHandler.m
//  tea
//
//  Created by Oguz Demir on 15/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "BonjourService.h"
#import "BonjourParametersHandler.h"
#import "TEA_iPadAppDelegate.h"
#import "ConfigurationManager.h"

@implementation BonjourParametersHandler

- (id) init
{
    self = [super init];
    if(self)
    {
        handlerMessageType = kMessageTypeSendParameters;
        //app_configuration = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) handleMessage:(BonjourMessage *)aMessage
{
    NSAutoreleasePool *arPool = [[NSAutoreleasePool alloc] init];
    
    // Set classroom parameters into configuration manager.
    [ConfigurationManager setConfigurationValue:aMessage.userData forKey:@"ClassroomParameters"];
    
    // Get TEA iPad's current version
    NSString *iPadVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] substringToIndex:3];
    NSString *iPadAppIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] ;
    
    // Check version
    NSDictionary *classroomParameters = [ConfigurationManager getConfigurationValueForKey:@"ClassroomParameters"];
    
    
    UIAlertView *alert;
    NSString *appVersion = [classroomParameters objectForKey:@"version"];
    
    NSString *forbidenIdentifier = [classroomParameters objectForKey:@"forbidenIdentifier"];

    
    CGFloat iPadVersionF = [iPadVersion doubleValue];
    CGFloat appVersionF = [appVersion doubleValue];
    
    
    if ([forbidenIdentifier isEqualToString:iPadAppIdentifier]) 
    {
        NSString *alertMessage = [NSString stringWithFormat:@"Bu uygulama sürümü geçersizdir. Lütfen okulunuzun yerel sunucusu üzerinden yüklediğiniz sürümü kullanınız...", appVersion];
        alert = [[UIAlertView alloc] initWithTitle:@"UYARI" message:alertMessage delegate:self cancelButtonTitle:@"Tamam" otherButtonTitles:nil] ;
        alert.tag = 0;
        [alert show];
        
    }
    else 
    {
        if (appVersionF > iPadVersionF) {
            NSString *alertMessage = [NSString stringWithFormat:@"Uygulama versiyonu ile iPad'inize yüklü olan version uyumsuz! Lütfen güncel versiyonu (%@) indirin", appVersion];
            
            alert = [[UIAlertView alloc] initWithTitle:@"UYARI" message:alertMessage delegate:self cancelButtonTitle:@"Tamam" otherButtonTitles:@"Yükle", nil] ;
            alert.tag = 1;            
            [alert show];
            
        }
    }

    [arPool release];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    TEA_iPadAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary *classroomParameters = [ConfigurationManager getConfigurationValueForKey:@"ClassroomParameters"];
    
    if(alertView.tag == 1)
    {
        if (buttonIndex == 1)
        {
            //cancel clicked ...do your action
            [appDelegate stopBonjourBrowser];
            NSString *stringURL = [classroomParameters objectForKey:@"appURL"];
            NSLog(@"%@ descriptioon", [classroomParameters description]);
            NSURL *url = [[ [ NSURL alloc ] initWithString: stringURL ] autorelease];
            [[UIApplication sharedApplication] openURL:url];
        }
        else if (buttonIndex == 0)
        {
            //reset clicked
            [appDelegate stopBonjourBrowser];
        }
    }
    else {
        exit(0);
    }
    
    
    
}

- (void)dealloc 
{
    [super dealloc];
}
@end
