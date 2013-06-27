//
//  WaveformViewController.m
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/20/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "WaveformViewController.h"

@interface WaveformViewController (){
    UIButton *playButton;
}

@end

@implementation WaveformViewController

@synthesize waveformView, timeText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Waveform";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopFunction) name:@"StopAudio" object:nil];
        
        //set up buttons
        playButton = [[UIButton alloc] init];
        [playButton addTarget:self
                   action:@selector(playFunction)
                   forControlEvents:UIControlEventTouchDown];
        [playButton setImage:[UIImage imageNamed:@"30-circle-play.png"] forState:UIControlStateNormal];
        playButton.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height - 30, 50.0, 40.0);
        [self.view addSubview:playButton];
        
        UIButton *stopButton = [[UIButton alloc] init];
        [stopButton addTarget:self
                       action:@selector(stopFunction)
             forControlEvents:UIControlEventTouchDown];
        [stopButton setImage:[UIImage imageNamed:@"35-circle-stop.png"] forState:UIControlStateNormal];
        stopButton.frame = CGRectMake(self.view.frame.size.width - 140.0, self.view.frame.size.height - 30.0, 50.0, 40.0);
        [self.view addSubview:stopButton];
    }
    return self;
}

-(void)loadAudioForPath:(NSString *)path{
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL *audioURL = [NSURL fileURLWithPath:path];
        //[wfv openAudioURL:audioURL];
        [waveformView openAudioURL:audioURL];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Audio !"
                                                        message: @"You should add a sample.mp3 file to the project before test it."
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSTimer *refreshTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                               target:self
                                             selector:@selector(updateTime)
                                             userInfo:nil
                                              repeats:YES];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return YES;
}

-(void)playFunction{
    //[waveformView setPlayHeadToLeftSlider];
    if([waveformView player].rate == 0.0){
        [playButton setImage:[UIImage imageNamed:@"29-circle-pause.png"] forState:UIControlStateNormal];
    }
    else{
        [playButton setImage:[UIImage imageNamed:@"30-circle-play.png"] forState:UIControlStateNormal];
    }
    [waveformView pauseAudio];
    [self updateTime];
}

-(void)stopFunction{
    if(waveformView.player.rate != 0.0){
        [waveformView setPlayHeadToLeftSlider];
        [waveformView pauseAudio];
        [playButton setImage:[UIImage imageNamed:@"30-circle-play.png"] forState:UIControlStateNormal];
    }
    [self updateTime];
}

-(void)updateTime{
    [timeText setText:[waveformView timeString]];
}

@end
