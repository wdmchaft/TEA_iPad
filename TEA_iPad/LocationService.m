//
//  LocationService.m
//  TEA_iPad
//
//  Created by Oguz Demir on 17/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "LocationService.h"
#import "TEA_iPadAppDelegate.h"
#import "DWDatabase.h"
#import "Reachability.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation LocationService

- (NSString*) getBSSID
{
    runningOperation = YES;
    NSString *bssid;
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) 
    {
        info = (NSDictionary*)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        bssid = [info valueForKey:@"BSSID"];
        //NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        if (info && [info count]) {
            break;
        }
        // [info release];
    }
    [info autorelease];
    [ifs release];
    runningOperation = NO;
    
    //simulator returns false for BSSID
#if TARGET_IPHONE_SIMULATOR
    bssid = @"0";
#endif 
    
    //NSLog(@"bssid %@", bssid);
    return bssid;
}


- (BOOL) getAllowedLocation
{
    BOOL returnValue;
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    NSString *deviceUDID = [appDelegate getDeviceUniqueIdentifier];
    NSString *sql = [NSString stringWithFormat:@"select * from location where device_id='%@'", deviceUDID];
    NSArray *rows = [DWDatabase getResultFromURL:[NSURL URLWithString:@"http://www.dualware.com/Service/EU/protocol.php"] withSQL:sql];
    
    
    
    allowedLocation = nil;
    if([rows count] == 1)
    {
        float lat = [[[rows objectAtIndex:0] valueForKey:@"lat"] floatValue];
        float lon = [[[rows objectAtIndex:0] valueForKey:@"lon"] floatValue];
        allowedLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        allowedACPRange = [[[rows objectAtIndex:0] valueForKey:@"acp_range"] intValue];
        allowed3GRange = [[[rows objectAtIndex:0] valueForKey:@"3g_range"] intValue];
        //    originalRange = allowedRange;
        NSString *userBSSID = [[[rows objectAtIndex:0] valueForKey:@"acp_address"] retain];
        [allowedBSSIDs addObject:userBSSID];
        returnValue = YES;
    }
    else
    {
        [locationServiceMessageView setMessage:@"Eşleştirme kaydı bulunamadı..."];
        returnValue = NO;
    }
    
    return returnValue;
}

- (void) generateAllowedConnectionRecordWithLocation:(CLLocation*) aLocation
{
        
    // Get user current location
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    [locationServiceMessageView setMessage:@"İlk kullanım için eşleştirme kaydı oluşturulyor..."];
    
    NSString *deviceUDID = [appDelegate getDeviceUniqueIdentifier];
    NSString *deviceName = [appDelegate getDeviceName];
    deviceName = [deviceName stringByReplacingOccurrencesOfString:@"'" withString:@""];
    NSString *bssid = [self getBSSID];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO `location` (`device_name`, `device_id`,`lat`,`lon`,`acp_range`,`3g_range`,`acp_address`,`reset`) VALUES ('%@', '%@', '%f', '%f', 160, 80, '%@', 0);", deviceName, deviceUDID, aLocation.coordinate.latitude, aLocation.coordinate.longitude, bssid];
    [DWDatabase getResultFromURL:[NSURL URLWithString:@"http://www.dualware.com/Service/EU/protocol.php"] withSQL:sql];
    
    [self getAllowedLocation];
}


- (void) startLocationTracking
{
    
    
    [locationManager startUpdatingLocation];
}

- (void) checkLocation
{
    if([staticBSSIDs containsObject:[self getBSSID]]) //return for trusted acp
    {
        [locationServiceMessageView setHidden:YES];
        [locationManager stopUpdatingLocation];
        NSLog(@"Not using location service");
        usingLocation = NO;
    }
    else
    {
        if(!usingLocation)
        {
            [self startLocationTracking];
            NSLog(@"Using location service");
        }
        
        usingLocation = YES;
    }
    
}



//*************************************>>>>>>>>>>>>>>>>>>>>>>>>>>

-(BOOL)reachable {
    Reachability *r = [Reachability reachabilityForLocalWiFi];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}

//*************************************<<<<<<<<<<<<<<<<<<<<<<<<<<


- (void) startService
{
    /*TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    locationServiceMessageView = [[LocationServiceMessageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [appDelegate.viewController.view addSubview:locationServiceMessageView];
    [locationServiceMessageView setHidden:NO];
    [locationServiceMessageView setMessage:@"Eşleştirme kontrolü yapılıyor..."];
    
    
     // Set known access points
    allowedBSSIDs = [[NSMutableArray alloc] initWithCapacity:10];
    staticBSSIDs = [[NSMutableArray alloc] initWithCapacity:10];
    
    [staticBSSIDs addObject:@"24:b6:57:43:35:90"];
    [staticBSSIDs addObject:@"6c:9c:ed:eb:81:b0"];
    [staticBSSIDs addObject:@"24:b6:57:8c:2:40"];
    [staticBSSIDs addObject:@"68:bc:c:ca:be:0"];
    [staticBSSIDs addObject:@"24:b6:57:43:35:b0"];
//    [staticBSSIDs addObject:@"c0:c1:c0:58:e5:2d"];   
    [staticBSSIDs addObject:@"0"]; 
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationServiceMessageView setHidden:NO];
    
    
//--*************************************>>>>>>>>>>>>>>>>>>>>>>>>>>    
   
    NSError *error=nil;
    NSString *protocolURL = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.dualware.com/Service/EU/protocol.php"] encoding:NSUTF8StringEncoding error:&error];
    
    if (protocolURL == NULL ) {
        [locationServiceMessageView setMessage:@"İnternet Bağlantısı Sağlanamadı. Lütfen bağlantınızı kontrol edin."];
        [locationServiceMessageView setHidden:NO];
        return;
    }


//--*************************************<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    [locationServiceMessageView setHidden:YES];
    
    //[self startLocationTracking];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkLocation) userInfo:nil repeats:YES];
    */
}


- (void)dealloc 
{
    [allowedBSSIDs release];
    [super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [locationServiceMessageView setHidden:NO];
//    [locationServiceMessageView setMessage:@"Eşleştirme kontrolü yapılamıyor, servis hatası..."];
    
    
    [locationServiceMessageView setMessage:@"Lokasyon bilgileri alınamıyor. Lütfen lokasyon servisinin açık olduğundan emin olun"];
    
    NSLog(@"location service failed.");
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
        NSLog(@"%f, %f", [newLocation verticalAccuracy], [newLocation horizontalAccuracy]);
    
//*************************************>>>>>>>>>>>>>>>>>>>>>>>>>> 
    
        NSString *locationInfoMessage = [NSString stringWithFormat:@"Lat - %f, Long - %f, ", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
        locationInfoMessage = [locationInfoMessage stringByAppendingFormat:@"Yatay Hassasiyet : %f, ", newLocation.verticalAccuracy];
        locationInfoMessage = [locationInfoMessage stringByAppendingFormat:@"Dikey Hassasiyet :  %f", newLocation.horizontalAccuracy];
        
    NSLog(@"message %@", locationInfoMessage);
    
        [locationServiceMessageView setMessageLocationLabel:locationInfoMessage];

//*************************************<<<<<<<<<<<<<<<<<<<<<<<<<<        
    
    
    
        if(runningOperation)
        {
            [locationServiceMessageView setHidden:YES];
            return;
        }
        else if([staticBSSIDs containsObject:[self getBSSID]]) //return for trusted acp
        {
            [locationServiceMessageView setHidden:YES];
            return;
        }

        
        if(!allowedLocation)
        {
            if ([newLocation verticalAccuracy] <= 260 && [newLocation horizontalAccuracy] <= 260) 
            {
                runningOperation = YES;
                
                if(![self getAllowedLocation])
                {
                    [self generateAllowedConnectionRecordWithLocation: newLocation];
                    
                    if(![self getAllowedLocation])
                    {
                        [locationServiceMessageView setMessage:@"Uygulama eşleştirme kaydınız oluşturulamadı. Lütfen sistem yöneticinize haber veriniz! "];
                        
                        //*************************************>>>>>>>>>>>>>>>>>>>>>>>>>>
                        
                        //[locationServiceMessageView setMessage:@""];
                        
                        //*************************************<<<<<<<<<<<<<<<<<<<<<<<<<<
                        
                        [locationServiceMessageView setHidden:NO];
                        [locationManager stopUpdatingLocation];
                    }
                }
                
                runningOperation = NO;
            }
            else
            {
                [locationServiceMessageView setMessage:@"Uygulama yatay ve dikey doğruluk değerleri sınır değerlerinin üstünde."];
                return;
            }
        }
        
        
        if([allowedBSSIDs containsObject:[self getBSSID]]) //extend range, trust access point
        {
            allowedRange = allowedACPRange;
        }
        else
        {
            allowedRange = allowed3GRange;
        }
        
        CLLocationDistance distanceInMeters = [newLocation distanceFromLocation:allowedLocation];
        
        if ( distanceInMeters > allowedRange ) 
        {
            /*
            NSString *message = [NSString stringWithFormat: @"Uygulama kullanım dışı bırakıldı. \n(Uzaklık:%f)\n", distanceInMeters];
            message = [message stringByAppendingFormat:@"Geçerli bölge : %f, %f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
            message = [message stringByAppendingFormat:@"Lokasyon Güncelleme Sayısı : %d\n", locationCount];
            message = [message stringByAppendingFormat:@"Yatay Hassasiyet : %f\n", newLocation.verticalAccuracy];
            message = [message stringByAppendingFormat:@"Dikey Hassasiyet :  %f", newLocation.horizontalAccuracy];
            
             */
            
            locationInfoMessage = [NSString stringWithFormat: @"Uygulama kullanım dışı bırakıldı. (Uzaklık:%f metre)", distanceInMeters];
            
            [locationServiceMessageView setMessage:locationInfoMessage];
            [locationServiceMessageView setHidden:NO];
        }
        else
        {
 /*           
            NSString *message = [NSString stringWithFormat: @"Uygulama kullanılabilir durumda. \n(Uzaklık:%f)\n", distanceInMeters];
            message = [message stringByAppendingFormat:@"Geçerli bölge : %f, %f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
            message = [message stringByAppendingFormat:@"Lokasyon Güncelleme Sayısı : %d\n", locationCount];
            message = [message stringByAppendingFormat:@"Yatay Hassasiyet : %f\n", newLocation.verticalAccuracy];
            message = [message stringByAppendingFormat:@"Dikey Hassasiyet :  %f", newLocation.horizontalAccuracy];
            
            [locationServiceMessageView setMessage:message];
  */
            [locationServiceMessageView setHidden:YES];
        }    
}



@end
