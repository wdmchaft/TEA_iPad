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
    NSString *startupBSSID;
    int locationCount;
    int allowedACPRange;
    int allowed3GRange;
    int allowedRange;
    CLLocation *currentLocation;
    CLLocation *allowedLocation;
    float sumX;
    float sumY;
    
    BOOL runningOperation;
    BOOL runningInStaticACPRegion;
    BOOL noInternet;
}

- (void) startService;


@end
