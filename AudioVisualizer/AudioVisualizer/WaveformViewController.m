//
//  WaveformViewController.m
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/20/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "WaveformViewController.h"

@interface WaveformViewController ()

@end

@implementation WaveformViewController

@synthesize waveformView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

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

@end
