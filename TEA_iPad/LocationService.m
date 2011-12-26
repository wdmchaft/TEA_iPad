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
      //  NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        if (info && [info count]) {
            break;
        }
       // [info release];
    }
    [info autorelease];
    [ifs release];
    runningOperation = NO;
    return bssid;
}


- (BOOL) getAllowedLocation
{
    BOOL returnValue;
    runningOperation = YES;
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

    runningOperation = NO;
    return returnValue;
}

- (void) generateAllowedConnectionRecord
{

    runningOperation = YES;

    // Get user current location
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    [locationServiceMessageView setMessage:@"İlk kullanım için eşleştirme kaydı oluşturulyor..."];
  
    NSString *deviceUDID = [appDelegate getDeviceUniqueIdentifier];
    NSString *deviceName = [appDelegate getDeviceName];
    NSString *bssid = [self getBSSID];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO `location` (`device_name`, `device_id`,`lat`,`lon`,`acp_range`,`3g_range`,`acp_address`,`reset`) VALUES ('%@', '%@', '%f', '%f', 80, 40, '%@', 0);", deviceName, deviceUDID, currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, bssid];
    [DWDatabase getResultFromURL:[NSURL URLWithString:@"http://www.dualware.com/Service/EU/protocol.php"] withSQL:sql];
    
    [self getAllowedLocation];

    runningOperation = NO;
}


- (void) startLocationTracking
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    locationServiceMessageView = [[LocationServiceMessageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [appDelegate.viewController.view addSubview:locationServiceMessageView];
    [locationServiceMessageView setMessage:@"Eşleştirme kontrolü yapılıyıor..."];

    [locationManager startUpdatingLocation];
}

- (void) startService
{
   /*
    
    // Set known access points
    allowedBSSIDs = [[NSMutableArray alloc] initWithCapacity:10];

    [allowedBSSIDs addObject:@"24:B6:57:43:35:90"];
    [allowedBSSIDs addObject:@"6C:9C:ED:EB:81:B0"];
    [allowedBSSIDs addObject:@"24:B6:57:8C:2:40"];
    [allowedBSSIDs addObject:@"68:BC:C:CA:BE:0"];
    [allowedBSSIDs addObject:@"24:B6:57:43:35:B0"];
    [allowedBSSIDs addObject:@"c0:c1:c0:58:e5:2d"];
    
    
    if(![allowedBSSIDs containsObject:[self getBSSID]]) //extend range, trust access point
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // Set a movement threshold for new events.
        locationManager.distanceFilter = kCLDistanceFilterNone;
        
        currentLocation = locationManager.location;
        
        if(![self getAllowedLocation])
        {
            [self generateAllowedConnectionRecord];
            
            if(![self getAllowedLocation])
            {
                [locationServiceMessageView setMessage:@"Uygulama eşleştirme kaydınız sağlanamadı. Lütfen sistem yöneticinize haber veriniz! "];
            }
            else
            {
                [self startLocationTracking];
            }
        }
        else
        {
            [self startLocationTracking];
        }
    }
    else
    {
        [locationServiceMessageView setHidden:YES];
    }
    
       */ 

}


- (void)dealloc {
    [allowedBSSIDs release];
    [super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    
    sumX += newLocation.coordinate.latitude;
    sumY += newLocation.coordinate.longitude;
    locationCount ++;
    
    if(runningOperation)
    {
        return;
    }
    
    currentLocation = [[[CLLocation alloc] initWithLatitude:sumX / (float) locationCount  longitude:sumY / (float) locationCount] autorelease];
    
    // Define distance
    if([allowedBSSIDs containsObject:[self getBSSID]]) //extend range, trust access point
    {
        allowedRange = allowedACPRange;
    }
    else
    {
        allowedRange = allowed3GRange;
    }
    

    CLLocationDistance distanceInMeters = [currentLocation distanceFromLocation:allowedLocation];
        
        
    if ( distanceInMeters > allowedRange ) 
    {
           
        NSString *message = [NSString stringWithFormat: @"Uygulama kullanım dışı bırakıldı. \n(Uzaklık:%f)\n", distanceInMeters];
        message = [message stringByAppendingFormat:@"Geçerli bölge : %f, %f\n", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
        message = [message stringByAppendingFormat:@"Lokasyon Güncelleme Sayısı : %d\n", locationCount];
        message = [message stringByAppendingFormat:@"Yatay Hassasiyet : %f\n", newLocation.verticalAccuracy];
        message = [message stringByAppendingFormat:@"Dikey Hassasiyet :  %f", newLocation.horizontalAccuracy];
        
        [locationServiceMessageView setMessage:message];
        [locationServiceMessageView setHidden:NO];
    }
    else
    {
        [locationServiceMessageView setHidden:YES];
    }  
        
}



@end
