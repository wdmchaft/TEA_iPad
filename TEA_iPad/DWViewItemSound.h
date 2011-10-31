//
//  DWViewItemText.h
//  TEA_iPad
//
//  Created by Oguz Demir on 14/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWViewItem.h"
#import <AVFoundation/AVFoundation.h>

enum kPlayerState {
    kPlayerStateIdle = 0,
    kPlayerStatePlaying = 1,
    kPlayerStatePausing = 2,
    kPlayerStateRecording = 3
};

@interface DWViewItemSound : DWViewItem 
{
    NSString *audioFilePath;
    UIButton *actionButton;
    UITextField *soundItemName;
    int state;
    
    AVAudioPlayer *audioPlayer;
    AVAudioRecorder *audioRecorder;
}

@property (nonatomic, assign) UITextField *soundItemName;
@property (nonatomic, retain) NSString *audioFilePath;
@property (nonatomic, assign) int state;

- (IBAction) recordButtonClicked:(UIButton*) sender;

- (IBAction) playButtonClicked:(UIButton*) sender;

- (IBAction) pauseButtonClicked:(UIButton*) sender;
- (void) setupActionButton;
@end
