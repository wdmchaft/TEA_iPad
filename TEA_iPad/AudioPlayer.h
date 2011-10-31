//
//  AudioPlayer.h
//  TEA_iPad
//
//  Created by Oguz Demir on 22/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


enum kPlayerState {
    kPlayerStateIdle = 0,
    kPlayerStatePlaying = 1,
    kPlayerStatePausing = 2,
    kPlayerStateRecording = 3
};

enum kPlayerType
{
    kPlayerTypePlayer = 0,
    kPlayerTypeRecorder = 1
};

@interface AudioPlayer : UIViewController 
{
    int state;
    int type;
    UIButton *recordButton;
    IBOutlet UIButton *playButton;
    UILabel *duration;
    NSString *path;
    
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer   *audioPlayer;
}

@property (nonatomic, assign) int state;
@property (nonatomic, assign) int type;
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UILabel *duration;
@property (nonatomic, retain) IBOutlet NSString *path;

- (IBAction) recordAction:(id) sender;
- (IBAction) playAction:(id) sender;
- (IBAction) pauseAction:(id) sender;

@end
