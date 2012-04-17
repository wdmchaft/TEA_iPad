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
    
    NSMutableArray *allowedBSSIDs;

    NSMutableArray *staticBSSIDs;
    
    int locationCount;
    int allowedRange;
    
    NSMutableArray *allowedLocations;
    
    BOOL runningOperation;
    BOOL usingLocation;
    int checkRange;
    int allowedLocationCount;
    
    double lastUpdateMilliseconds;
}

- (void) startService;


@end
