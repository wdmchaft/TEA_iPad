//
//  Sync.h
//  TEA_iPad
//
//  Created by Oguz Demir on 27/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LibraryView;
@interface Homework : UIView 
{
    UIProgressView *progressView;
    UILabel *progressLabel;
    
    int fileSize;
    NSString *fileName;
    
    NSMutableDictionary *dictionary;
    int currentFileIndex;
    NSMutableData *downloadData;
    //NSString *directoryPath;
    LibraryView *libraryViewController;
   
}

- (void) requestForHomework;
@property (nonatomic, retain) NSMutableDictionary *dictionary;
@property (nonatomic, assign) LibraryView *libraryViewController;

@end
