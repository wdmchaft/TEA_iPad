//
//  TEA_iPadAppDelegate.m
//  TEA_iPad
//
//  Created by Oguz Demir on 8/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "TEA_iPadAppDelegate.h"
#import "MediaPlayer.h"
#import "LocalDatabase.h"
#import "Quiz.h"
#import "BonjourService.h"
#import "BonjourSessionInfoHandler.h"
#import "BonjourQuizHandler.h"
#import "BonjourQuizAnswerHandler.h"
#import "BonjourImageHandler.h"
#import "BonjourVideoHandler.h"
#import "BonjourDocumentHandler.h"
#import "BonjourAudioHandler.h"
#import "BonjourQuizPauseHandler.h"
#import "BonjourQuizContinueHandler.h"
#import "BonjourQuizExtraTimeHandler.h"
#import "BonjourQuizFinishHandler.h"
#import "BonjourParametersHandler.h"
#import "BonjourUpdateSessionHandler.h"
#import "Reachability.h"
#import "BonjourStudentLockHandler.h"
#import "LocationService.h"
#import "ConfigurationManager.h"
#include <SystemConfiguration/SystemConfiguration.h>
#import "DeviceLog.h"

@implementation TEA_iPadAppDelegate




@synthesize window=_window, bonjourBrowser, session, state, connectedHost, guestEnterNumber;
@synthesize currentQuizWindow;
@synthesize viewController=_viewController, bonjourBrowserThread, selectedItemView, notificationArray;
@synthesize duration, bgDuration, backgroundTime, currentTime, appGuid;

void PrintReachabilityFlags(
                            const char *                hostname, 
                            SCNetworkConnectionFlags    flags, 
                            const char *                comment,
                            TEA_iPadAppDelegate *appDelegateObject
                            )
// Prints a line that records a reachability transition. 
// This includes the current time, the new state of the 
// reachability flags (from the flags parameter), and the 
// name of the host (from the hostname parameter).
{
    
    
    if((flags & kSCNetworkFlagsConnectionRequired))
    {
        NSLog(@"Connection required...");
    }
    else
    {
        NSLog(@"Has connection...");
        [appDelegateObject restartBonjourBrowser];
    }
}

void MyReachabilityCallback(
                            SCNetworkReachabilityRef    target,
                            SCNetworkConnectionFlags    flags,
                            void *                      info
                            )
// This routine is a System Configuration framework callback that 
// indicates that the reachability of a given host has changed.  
// It's call from the runloop.  target is the host whose reachability 
// has changed, the flags indicate the new reachability status, and 
// info is the context parameter that we passed in when we registered 
// the callback.  In this case, info is a pointer to the host name.
// 
// Our response to this notification is simply to print a line 
// recording the transition.
{
    assert(target != NULL);
    assert(info   != NULL);
    
    PrintReachabilityFlags( (const char *) info, flags, NULL, info );
}

- (void) stopBonjourBrowser
{

/*      
    @synchronized([bonjourBrowser bonjourServers])
    {
        [[bonjourBrowser bonjourServers] removeAllObjects];
    }

    [bonjourBrowser.netServiceBrowser stop];
    [bonjourBrowser.services removeAllObjects];
    
    //[bonjourBrowser release];
    //bonjourBrowser = nil;
    
    //CFRunLoopStop([[NSRunLoop currentRunLoop] getCFRunLoop]);
    */
    [bonjourBrowser stopBrowse];
    
    self.state = kAppStateIdle;
    
    NSLog(@"Bonjur service stoped...");
}

- (void) startBonjourBrowser
{
     [self.viewController.globalSyncView setHidden:YES];
    
    NSLog(@"bonjour browser started!!!! ");
    
    if(!bonjourBrowser)
    {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        bonjourBrowser = [[BonjourBrowser alloc] init];
        
        [bonjourBrowser startBrowse];
        [[NSRunLoop currentRunLoop] run];
        [pool release];
    }
    

   
}

- (void) restartBonjourBrowser
{
     
    [self stopBonjourBrowser];
    sleep(2);
    [bonjourBrowser startBrowse];
    
    //[self performSelectorInBackground:@selector(startBonjourBrowser) withObject:nil];
    //[self startBonjourBrowser];
    NSLog(@"Bonjour service restarted...");
}



- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    if(![curReach currentReachabilityStatus])
    {
        self.state = kAppStateIdle;
    }
    else
    {
        [self restartBonjourBrowser];
    }
}


- (void) screenDidConnect:(NSNotification *)aNotification{
    [blackScreen setMessage:@"Bu uygulama monitör bağlantısı ile çalışmaz..."];
    [self.viewController.view addSubview:blackScreen];

}


- (void) screenDidDisconnect:(NSNotification *)aNotification{
    if( [UIScreen screens].count == 1)
    {
        [blackScreen removeFromSuperview];
    }
}

- (void) screenModeDidChange:(NSNotification *)aNotification{

}


void handleException(NSException *exception) 
{
      
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSString *iPadAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *iPadOSVersion = [[UIDevice currentDevice] systemVersion];
    NSString *subject = [NSString stringWithFormat:@"[iPad ERROR] %@ - %@ - %@", [appDelegate getDeviceUniqueIdentifier],  iPadAppVersion, iPadOSVersion];
    NSString *body =  [NSString stringWithFormat:@"%@ \n\n%@", exception.reason, [exception.callStackSymbols description]]; 
    

    NSString *downloadURL = [NSString stringWithFormat: @"subject=%@&body=%@&", subject, body];
    NSData *postData = [downloadURL dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    

    
    NSString *postURL = [ConfigurationManager getConfigurationValueForKey:@"EXCEPTION_POST_URL"];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:postURL]]];

    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    
    // send e-mail
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

#if !TARGET_IPHONE_SIMULATOR
    NSString *filePath = @"/Applications/Cydia.app";
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cihaz Kullanılamaz!" message:@"Cihazınız JailBreak edildiği için uygulama çalışmayacaktır." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }

#endif

    
    if ([[ConfigurationManager getConfigurationValueForKey:@"EXCEPTION_ENABLED"] intValue]){
        NSSetUncaughtExceptionHandler(&handleException);
    }


    
    application.idleTimerDisabled = YES;
    guestEnterNumber = 0;
    
    BonjourMessageHandlerManager *handlerManager = [BonjourMessageHandlerManager sharedInstance];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourSessionInfoHandler alloc] init] autorelease]];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourQuizHandler alloc] init] autorelease]];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourQuizAnswerHandler alloc] init] autorelease]];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourImageHandler alloc] init] autorelease]];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourVideoHandler alloc] init] autorelease]];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourDocumentHandler alloc] init] autorelease]];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourAudioHandler alloc] init] autorelease]];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourStudentLockHandler alloc] init] autorelease]];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourQuizPauseHandler alloc] init] autorelease]];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourQuizContinueHandler alloc] init] autorelease]];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourQuizExtraTimeHandler alloc] init] autorelease]];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourQuizFinishHandler alloc] init] autorelease]];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourParametersHandler alloc]init] autorelease]];
    [handlerManager.bonjourMessageHandlers addObject:[[[BonjourUpdateSessionHandler alloc]init] autorelease]];
     
    self.state = kAppStateIdle;
    
    Session *tSession = [[Session alloc] init];
    self.session = tSession;
    [tSession release];
   
    self.window.rootViewController = self.viewController;
    [[self viewController] release];
    
    [self.window makeKeyAndVisible];

    


}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.viewController calendarButtonClicked:nil];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
    
    
    NSString *alertTitle = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"New Notification", NULL), [[userInfo objectForKey:@"aps"] valueForKey:@"alert"]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", NULL) message:alertTitle delegate:self cancelButtonTitle:NSLocalizedString(@"OK", NULL) otherButtonTitles:nil];
    [alert show];
    [alert release];


}

- (void) setState:(int)aState
{
    state = aState;
    
    if (aState == kAppStateLogon) 
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        self.viewController.logonGlow.alpha = 1.0;
        [UIView commitAnimations];   
        
        
        NSLog(@"logged in host is %@", connectedHost);
        
        [bonjourBrowser.netServiceBrowser stop];
        
        NSMutableArray *clientsToRemove = [[NSMutableArray alloc] init];
        
        
        @synchronized([bonjourBrowser bonjourServers])
        {
            for(BonjourClient *client in [bonjourBrowser bonjourServers])
            {
                if(! [[client hostName] isEqualToString:connectedHost])
                {
                    [clientsToRemove addObject:client];
                    NSLog(@"Removing host %@", client.hostName);
                }
            }
            
            for(BonjourClient *client in clientsToRemove)
            {
                [bonjourBrowser.services removeObject:client.netService];
                [[bonjourBrowser bonjourServers] removeObject:client];
            }
        }
        
        
        
        [clientsToRemove release];
        
        [self.viewController.guestEnterButton setHidden:YES];
    }
    else
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        self.viewController.logonGlow.alpha = 0.0;
        [UIView commitAnimations]; 
        
        [self.viewController.guestEnterButton setHidden:NO];
        
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{    
    NSLog(@"App is not active");
    self.backgroundTime = [NSDate date];
  
   /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if( !exitingApp && state == kAppStateLogon )
    {
        BonjourMessage *notificationMessage = [[[BonjourMessage alloc] init] autorelease];
        notificationMessage.messageType = kMessageTypeNotificaiton;
        
        NSMutableDictionary *userData = [[[NSMutableDictionary alloc] init] autorelease];
        [userData setValue:[NSNumber numberWithInt:kNotificationCodeAppInBg] forKey:@"NotificationCode"];
        notificationMessage.userData = userData;
        [bonjourBrowser sendBonjourMessageToAllClients:notificationMessage];

    }
    

}


- (void)applicationWillEnterForeground:(UIApplication *)application
{

    if( state == kAppStateLogon )
    {
        BonjourMessage *notificationMessage = [[[BonjourMessage alloc] init] autorelease];
        notificationMessage.messageType = kMessageTypeNotificaiton;
        
        NSMutableDictionary *userData = [[[NSMutableDictionary alloc] init] autorelease];
        [userData setValue:[NSNumber numberWithInt:kNotificationCodeAppInFg] forKey:@"NotificationCode"];
        notificationMessage.userData = userData;
        [bonjourBrowser sendBonjourMessageToAllClients:notificationMessage];
        
      //  [DeviceLog deviceLog:@"appMovedForeground" withLecture:nil withContentType:nil];
    }

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
       
    NSLog(@"App did enter active mode");
    if (self.backgroundTime) {
        bgDuration = [[NSDate date] timeIntervalSinceDate:self.backgroundTime] + bgDuration;
    }

    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    

    
    NSLog(@"App will be terminated");
    exitingApp = YES;
    
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url) {  return NO; }
    
    NSString *URLString = [url absoluteString];
    [[NSUserDefaults standardUserDefaults] setObject:URLString forKey:@"url"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

- (NSString *) getDeviceUniqueIdentifier
{
    #if TARGET_IPHONE_SIMULATOR
        return @"11111-22222-33333-44444-55555";
//        return @"ertan-simulator";
    #else
        return [[UIDevice currentDevice] uniqueIdentifier];
    #endif  
}

- (NSString *) getDeviceName
{
#if TARGET_IPHONE_SIMULATOR
    return @"Device Simulator...";
#else
    return [[UIDevice currentDevice] name];
#endif  
}

- (void) showQuizWindow:(Quiz*) quizView
{
    self.currentQuizWindow = quizView;
    quizView.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.viewController presentModalViewController:quizView animated:YES];
    
}

- (void)dealloc
{
    [backgroundTime release];
    [currentTime release];
    [notificationArray release];
    
    if(bonjourBrowserThread)
    {
        [bonjourBrowserThread cancel];
        [bonjourBrowserThread release];
    }
    [selectedItemView release];
    [connectedHost release];
    [session release];
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
