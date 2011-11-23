//
//  LocationService.h
//  TEA_iPad
//
//  Created by Oguz Demir on 17/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationServiceMessageView.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationService : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    LocationServiceMessageView *locationServiceMessageView;
    
    NSString *allowedBSSID;
    int locationCount;
    int allowedRange;
    int originalRange;
    CLLocation *currentLocation;
    CLLocation *allowedLocation;
    float sumX;
    float sumY;

    BOOL runningOperation;

}

- (void) startService;
    

@end
