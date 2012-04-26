//
//  Sync.h
//  TEA_iPad
//
//  Created by Oguz Demir on 27/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LibraryView, GlobalSync;
@interface Homework : NSObject 
{
    UIProgressView *progressView;
    UILabel *progressLabel;
    
    int fileSize;
    NSString *fileName;
    
    NSMutableDictionary *dictionary;
    int currentFileIndex;
    NSMutableData *downloadData;
    LibraryView *libraryViewController;
    GlobalSync *globalSync;
}

- (void) requestForHomework;
@property (nonatomic, retain) NSMutableDictionary *dictionary;
@property (nonatomic, assign) LibraryView *libraryViewController;
@property (nonatomic, assign)  GlobalSync *globalSync;

@end
