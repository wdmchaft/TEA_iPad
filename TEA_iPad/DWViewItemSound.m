//
//  DWViewItemText.m
//  TEA_iPad
//
//  Created by Oguz Demir on 14/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWViewItemSound.h"

@implementation DWViewItemSound
@synthesize soundItemName, audioFilePath, state;

- (void)dealloc {
    [audioFilePath release];
    [super dealloc];
}

- (void) setupActionButton
{
    [actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    if(state == kPlayerStatePausing || state == kPlayerStateIdle)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:audioFilePath])
        {
            [actionButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [actionButton setImage:[UIImage imageNamed:@"SketchBookPlay.png"] forState:UIControlStateNormal];
        }
        else
        {
            [actionButton addTarget:self action:@selector(recordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [actionButton setImage:[UIImage imageNamed:@"SketchBookRecord.png"] forState:UIControlStateNormal];
        }
    }
    else
    {
        [actionButton addTarget:self action:@selector(pauseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if(state == kPlayerStateRecording)
            [actionButton setImage:[UIImage imageNamed:@"SketchBookRecordPause.png"] forState:UIControlStateNormal];
        else if(state == kPlayerStatePlaying)
            [actionButton setImage:[UIImage imageNamed:@"SketchBookPlayPause.png"] forState:UIControlStateNormal];
    }
    
    
}

- (void) setSelected:(BOOL)pSelected
{
    [super setSelected:pSelected];
    
    [viewObject.layer setBorderWidth:1.0];
    [viewObject.layer setCornerRadius:3.0];
    [viewObject.layer setMasksToBounds:YES];
}

- (void) initViewItem
{
    [super initViewItem];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.audioFilePath = [[NSString stringWithFormat:@"%@/%@.caf",  [paths objectAtIndex:0], guid] retain];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectNull];
    [self addSubview:view];
    [view release];
    [view setBackgroundColor:[UIColor yellowColor]];
    [view setAlpha:0.7];
    viewObject = view;
    
    soundItemName = [[UITextField alloc] initWithFrame:CGRectNull];
    soundItemName.text = @"Yeni ses alanı...";
    [view addSubview:soundItemName];
    [soundItemName release];
    
    actionButton = [[UIButton alloc] init];
    [actionButton setFrame:CGRectMake(12, 12, 32, 32)];
    [view addSubview:actionButton];
    
    [self setupActionButton];
    
    [self resized];
}

- (void) resized
{
    [super resized];
    
    soundItemName.frame = CGRectMake(50, 15, self.frame.size.width - 62, 20);
}

- (IBAction) recordButtonClicked:(UIButton*) sender
{
    state = kPlayerStateRecording;
    
    if(!audioRecorder)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                                        [NSNumber numberWithInt: kAudioFormatAppleIMA4], AVFormatIDKey,
                                        [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                                        [NSNumber numberWithInt: AVAudioQualityLow],         AVEncoderAudioQualityKey,
                                        nil];
        
        NSError *error;
        audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:audioFilePath] settings:recordSettings error:&error];
        
        if(error)
        {
            NSLog(@"Recorder error %@", [error localizedDescription]);
        }
        
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:audioFilePath isDirectory:NO])
    {
        [[NSFileManager defaultManager] removeItemAtPath:audioFilePath error:nil]; 
        NSLog(@"deleted");
    }
    
    [audioRecorder prepareToRecord];
    [audioRecorder record];
    
    [self setupActionButton];
}

- (IBAction) playButtonClicked:(UIButton*) sender
{
    state = kPlayerStatePlaying;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSURL *url = [NSURL fileURLWithPath:audioFilePath];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] ;
    
    if(error)
    {
        NSLog(@"Player error %@", [error localizedDescription]);
    }

    audioPlayer.numberOfLoops = 0;
    [audioPlayer play];
    
    [self setupActionButton];
}

- (IBAction) pauseButtonClicked:(UIButton*) sender
{
    
    if(state == kPlayerStateRecording)
    {
        [audioRecorder stop];
        [audioRecorder release];
        audioRecorder = nil;
    }
    else if(state == kPlayerStatePlaying)
    {
        [audioPlayer stop];
        [audioPlayer release];
        audioPlayer = nil;
    }

    state = kPlayerStatePausing;
    
    [self setupActionButton];
}

- (NSString *) getXML
{
     NSString *xml = [NSString stringWithFormat:@"<sounditem path=\"%@\" position=\"%@\"></sounditem>", audioFilePath, [self getPosition]];
    return xml;
}

@end
