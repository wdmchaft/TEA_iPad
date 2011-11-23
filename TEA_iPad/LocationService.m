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
        [info release];
    }
    [info autorelease];
    [ifs release];
    runningOperation = NO;
    return bssid;
}


- (void) getAllowedLocation
{
    generatingRecord = YES;
    // Get user current location
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
        allowedRange = [[[rows objectAtIndex:0] valueForKey:@"range"] intValue];
        originalRange = allowedRange;
        allowedBSSID = [[[rows objectAtIndex:0] valueForKey:@"acp_address"] retain];
    }
    else
    {
        [locationServiceMessageView setMessage:@"Eşleştirme kaydı bulunamadı..."];
    }
<<<<<<< Updated upstream
    generatingRecord = NO;
=======
    runningOperation = NO;
>>>>>>> Stashed changes
}

- (void) generateAllowedConnectionRecord
{
<<<<<<< Updated upstream
    generatingRecord = YES;
=======
    runningOperation = YES;
>>>>>>> Stashed changes
    // Get user current location
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    [locationServiceMessageView setMessage:@"İlk kullanım için eşleştirme kaydı oluşturulyor..."];
  
    NSString *deviceUDID = [appDelegate getDeviceUniqueIdentifier];
    NSString *bssid = [self getBSSID];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO `location` (`device_id`,`lat`,`lon`,`range`,`acp_address`,`reset`) VALUES ('%@', '%f', '%f', 20, '%@', 0);", deviceUDID, currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, bssid];
    [DWDatabase getResultFromURL:[NSURL URLWithString:@"http://www.dualware.com/Service/EU/protocol.php"] withSQL:sql];
    
    [self getAllowedLocation];
<<<<<<< Updated upstream
    
    generatingRecord = NO;
=======
    runningOperation = NO;
>>>>>>> Stashed changes
}

- (void) startService
{
    
    
    
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    [self getAllowedLocation];
    
   
    
    locationServiceMessageView = [[LocationServiceMessageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [appDelegate.viewController.view addSubview:locationServiceMessageView];
    [locationServiceMessageView setMessage:@"Eşleştirme kontrolü yapılıyıor..."];
    
    
    if([[Reachability reachabilityForInternetConnection] connectionRequired])
    {
        [locationServiceMessageView setMessage:@"Ugulamanın açılışta internet bağlantısı olması gerekmektedir.\nBağlantıyı sağladıktan sonra uygulamayı tekrar açınız..."];
    }
    else
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // Set a movement threshold for new events.
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [locationManager startUpdatingLocation];
    }
    
    
    
    
    
    
    
        // If current location not exists create current location
}


- (void)dealloc {
    [allowedBSSID release];
    [super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    
    sumX += newLocation.coordinate.latitude;
    sumY += newLocation.coordinate.longitude;
    locationCount ++;
    
<<<<<<< Updated upstream
    if(generatingRecord)
=======
    if(runningOperation)
>>>>>>> Stashed changes
    {
        return;
    }
    
    currentLocation = [[[CLLocation alloc] initWithLatitude:sumX / (float) locationCount  longitude:sumY / (float) locationCount] autorelease];
    
    // Define distance
    if([allowedBSSID isEqualToString:[self getBSSID]]) //extend range, trust access point
    {
<<<<<<< Updated upstream
        NSString *message = [NSString stringWithFormat: @"Uygulama kullanımda, ACP tanımlaması yapıldı\n"];
        message = [message stringByAppendingFormat:@"Şu Anki Lokasyon :%f, %f\n", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
        message = [message stringByAppendingFormat:@"Alınan Sinyal Sayısı : %d\n", locationCount];
        message = [message stringByAppendingFormat:@"Dikey Hassasiyet: %f\n", newLocation.verticalAccuracy];
        message = [message stringByAppendingFormat:@"Yatay Hassasiyet: %f", newLocation.horizontalAccuracy];
        
        //NSLog(@"location info : %@", message);
        
        [locationServiceMessageView setMessage:message];
        [locationServiceMessageView setHidden:YES];
=======
        allowedRange = 100;
    }
    else
    {
        originalRange = originalRange;
    }
    
    // Check distance...
    if(!allowedLocation)
    {
        [self generateAllowedConnectionRecord];
        [self getAllowedLocation];
>>>>>>> Stashed changes
    }
    else
    {
        CLLocationDistance distanceInMeters = [currentLocation distanceFromLocation:allowedLocation];
        
        if ( distanceInMeters > allowedRange ) 
        {
<<<<<<< Updated upstream
            [self generateAllowedConnectionRecord];
         //   [self getAllowedLocation];
        }
        else
        {
            
            CLLocationDistance distanceInMeters = [currentLocation distanceFromLocation:allowedLocation];
            
            if ( distanceInMeters > allowedRange ) 
            {
                NSString *message = [NSString stringWithFormat: @"ACP tanımlaması yapılamadı, Uygulama kullanıma kapatıldı... \n(Uzaklık:%f)\n", distanceInMeters];
                message = [message stringByAppendingFormat:@"Şu Anki Lokasyon :%f, %f\n", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
                message = [message stringByAppendingFormat:@"Alınan Sinyal Sayısı : %d\n", locationCount];
                message = [message stringByAppendingFormat:@"Dikey Hassasiyet: %f\n", newLocation.verticalAccuracy];
                message = [message stringByAppendingFormat:@"Yatay Hassasiyet: %f", newLocation.horizontalAccuracy];
                
                [locationServiceMessageView setMessage:message];
                [locationServiceMessageView setHidden:NO];
            }
            else
            {
                NSString *message = [NSString stringWithFormat: @"Uygulama kullanımda \n(distance:%f)\n", distanceInMeters];
                message = [message stringByAppendingFormat:@"current location:%f, %f\n", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
                message = [message stringByAppendingFormat:@"count %d\n", locationCount];
                message = [message stringByAppendingFormat:@"Dikey Hassasiyet %f\n", newLocation.verticalAccuracy];
                message = [message stringByAppendingFormat:@"Yatay Hassasiyet %f", newLocation.horizontalAccuracy];
                
                [locationServiceMessageView setMessage:message];
                [locationServiceMessageView setHidden:YES];
            }
  
        }
    }
    
    
    
       
=======
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
>>>>>>> Stashed changes
}



@end
