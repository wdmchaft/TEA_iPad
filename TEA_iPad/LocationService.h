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
    int locationCount;
    int allowedACPRange;
    int allowed3GRange;
    int allowedRange;
    CLLocation *currentLocation;
    CLLocation *allowedLocation;
    float sumX;
    float sumY;
    
    BOOL runningOperation;
    
}

- (void) startService;


@end
