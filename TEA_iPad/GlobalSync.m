

//
//  Sync.m
//  TEA_iPad
//
//  Created by Oguz Demir on 27/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "GlobalSync.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"

#import "LocalDatabase.h"
#import "TEA_iPadAppDelegate.h"
#import "ZipFile.h"
#import "ZipReadStream.h"
#import "FileInZipInfo.h"
#import "BonjourService.h"
#import "ConfigurationManager.h"

#import "Reachability.h"

#import <ifaddrs.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import "ZipWriteStream.h"
#import "DWDatabase.h"

@implementation GlobalSync
@synthesize progressView, progressLabel, currentPhase;

- (void) updateMessageAssync:(NSString*) message
{
    [progressLabel setText:message];
}


- (void) updateProgressAssync:(NSNumber*) progressValue
{

    CGFloat progress = (float) currentPhase / (float) phaseCount + ([progressValue floatValue] / 4.0);
    [progressView setProgress: progress];
}




- (void) updateMessage:(NSString*) message
{
    NSLog(@"sync message %@", message);
    [self performSelectorInBackground:@selector(updateMessageAssync:) withObject:message];
}

- (void) updateProgress:(NSNumber*) progressValue
{
    [self performSelectorInBackground:@selector(updateProgressAssync:) withObject:progressValue];
}


- (void)dealloc {
    [progressView release];
    [progressLabel release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        phaseCount = 4;
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [imageView setImage:[UIImage imageNamed:@"SyncBG.jpg"]];
        [self addSubview:imageView];
        
        
        
        self.progressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(100, 480, 824, 25)] autorelease];
        [self addSubview:progressView];
        
        self.progressLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 510, 1024, 25)] autorelease];
        [progressLabel setTextColor:[UIColor whiteColor]];
        [progressLabel setBackgroundColor:[UIColor clearColor]];
        [progressLabel setTextAlignment:UITextAlignmentCenter];
        [progressLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
        
        [self addSubview:progressLabel]; 
        
        
    }
    return self;
}




@end
