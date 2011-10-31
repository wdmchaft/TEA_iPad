//
//  AudioPlayer.m
//  TEA_iPad
//
//  Created by Oguz Demir on 22/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "AudioPlayer.h"


@implementation AudioPlayer
@synthesize recordButton;
@synthesize duration;
@synthesize state, type, path;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    if(audioRecorder)
    {
        if(audioRecorder.recording)
        {
            NSLog(@"file saved %@", path);
            [audioRecorder stop];
        }
        [audioRecorder release];
    }

    if(audioPlayer)
    {
        [audioPlayer release];
    }

    [recordButton release];
    [duration release];
    [playButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        
  
   
}


- (void) setupView
{
    [recordButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents]; 
    [playButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents]; 
    
    if(state == kPlayerStateIdle || state == kPlayerStatePausing)
    {
        [recordButton setImage:[UIImage imageNamed:@"AudioPlayerRecord.png"] forState:UIControlStateNormal];
        [recordButton addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [playButton setImage:[UIImage imageNamed:@"AudioPlayerPlay.png"] forState:UIControlStateNormal];
        [playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if(state == kPlayerStateRecording)
    {
        [recordButton setImage:[UIImage imageNamed:@"AudioPlayerPause.png"] forState:UIControlStateNormal];
        [recordButton addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [playButton setImage:[UIImage imageNamed:@"AudioPlayerPlay.png"] forState:UIControlStateNormal];
        [playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if(state == kPlayerStatePlaying)
    {
        [recordButton setImage:[UIImage imageNamed:@"AudioPlayerRecord.png"] forState:UIControlStateNormal];
        [recordButton addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [playButton setImage:[UIImage imageNamed:@"AudioPlayerPause.png"] forState:UIControlStateNormal];
        [playButton addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *audioFilePath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], @"test.caf"];
    self.path = audioFilePath;
    
    [self setupView];
}

- (void)viewDidUnload
{
    [self setRecordButton:nil];
    [self setDuration:nil];
    [playButton release];
    playButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
         
- (IBAction) recordAction:(id) sender
{
    [audioPlayer stop];
    
    
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
        audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:path] settings:recordSettings error:&error];
        
        if(error)
        {
            NSLog(@"Recorder error %@", [error localizedDescription]);
        }

    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil]; 
        NSLog(@"deleted");
    }
    
    [audioRecorder prepareToRecord];
    [audioRecorder record];
    
    state = kPlayerStateRecording;
    [self setupView];
}




- (IBAction) playAction:(id) sender
{
   // if(audioRecorder.recording)
   //     [audioRecorder stop];
    
    state = kPlayerStatePlaying;
    
    if(!audioPlayer)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        NSURL *url = [NSURL fileURLWithPath:path];
        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] ;
        
        if(error)
        {
            NSLog(@"Player error %@", [error localizedDescription]);
        }
    }
    
   
    audioPlayer.numberOfLoops = 0;
    [audioPlayer play];
    NSLog(@"playing on path %@", path);
    
    [self setupView];
}
         
- (IBAction) pauseAction:(id) sender
{
    if(state == kPlayerStateRecording)
    {
        NSLog(@"file saved %@", path);
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
    [self setupView];
}
         
@end
