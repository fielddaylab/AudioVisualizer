//
//  TestStartViewController.m
//  AudioVisualizer
//
//  Created by Nick Heindl on 6/28/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "TestStartViewController.h"

#import "AudioVisualizerViewController.h"

@interface TestStartViewController ()

@end

@implementation TestStartViewController{
    AVAudioRecorder *recorder;

}

@synthesize AVVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)nextScreen
{
    self.AVVC = [[AudioVisualizerViewController alloc] initWithNibName:@"AudioVisualizerViewController" bundle:nil];
    [self.navigationController pushViewController:self.AVVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gotonext:(id)sender {
    [self nextScreen];
}

- (IBAction)record:(id)sender {
    //NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *docsDir = [dirPaths objectAtIndex:0];
    //NSURL *tmpFileUrl = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:@"temp.m4a"]];
    NSString *tmpFileUrl = @"/Users/nickheindl/Desktop/AudioVisualizer/AudioVisualizer/AudioVisualizer/temp.m4a";
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    nil];
    NSError *error = nil;
    recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:tmpFileUrl] settings:recordSettings error:&error];
    [recorder prepareToRecord];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:nil];
    
    [recorder record];
    
}

- (IBAction)stoprec:(id)sender {
    [recorder stop];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    int flags = AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation;
    [session setActive:NO withFlags:flags error:nil];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}
@end
