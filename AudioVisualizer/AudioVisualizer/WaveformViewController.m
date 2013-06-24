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

@synthesize waveformView;

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
        [playButton setImage:[UIImage imageNamed:@"playButtonBlue.png"] forState:UIControlStateNormal];
        playButton.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height - 30, 50.0, 40.0);
        [self.view addSubview:playButton];
        
        UIButton *stopButton = [[UIButton alloc] init];
        [stopButton addTarget:self
                       action:@selector(stopFunction)
             forControlEvents:UIControlEventTouchDown];
        [stopButton setImage:[UIImage imageNamed:@"stopButtonRed.png"] forState:UIControlStateNormal];
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
     [self loadAudioForPath:@"/Users/jgmoeller/iOS Development/AudioVisualizer/AudioVisualizer/AudioVisualizer/AudioVisualizer/tail_toddle.mp3"];
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
        [playButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
    }
    else{
        [playButton setImage:[UIImage imageNamed:@"playButtonBlue.png"] forState:UIControlStateNormal];
    }
    
    [waveformView pauseAudio];
}

-(void)stopFunction{
    if(waveformView.player.rate != 0.0){
        [waveformView setPlayHeadToLeftSlider];
        [playButton setImage:[UIImage imageNamed:@"playButtonBlue.png"] forState:UIControlStateNormal];
        [waveformView pauseAudio];
    }
}

@end
