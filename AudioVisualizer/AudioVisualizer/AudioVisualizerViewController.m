//
//  AudioVisualizerViewController.m
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "AudioVisualizerViewController.h"
#import "WaveformControl.h"
#import "AppModel.h"
#import "FreqHistogramControl.h"

#define SLIDER_BUFFER 5

@interface AudioVisualizerViewController (){
    UIBarButtonItem *playButton;
    UIImageView *playImage;
    UIImageView *pauseImage;
    UIImageView *stopImage;
}

- (void) initView;
- (void) setSampleData:(float *)theSampleData length:(int)length;
- (void) startAudio;
- (void) pauseAudio;
@end

@implementation AudioVisualizerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadAudioForPath:@"/Users/jgmoeller/iOS Development/AudioVisualizer/AudioVisualizer/AudioVisualizer/AudioVisualizer/tail_toddle.mp3"];
    wf = [[WaveformControl alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 88, self.view.bounds.size.height + 12)];
    [self.view addSubview:wf];
    
//    freq = [[FreqHistogramControl alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 88, self.view.bounds.size.height)];
//    [self.view addSubview:freq];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
    UIToolbar *toolbar = [[UIToolbar alloc]init];
    toolbar.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
    UIButton *withoutBorderButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [withoutBorderButton setImage:[UIImage imageNamed:@"30-circle-play.png"] forState:UIControlStateNormal];
    [withoutBorderButton addTarget:self action:@selector(playFunction) forControlEvents:UIControlEventTouchUpInside];
    playButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButton];
    NSArray *toolbarButtons = [NSArray arrayWithObjects:playButton, nil];
    [toolbar setItems:toolbarButtons animated:NO];
    [self.view addSubview:toolbar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initView
{
	playProgress = 0.0;

	green = [UIColor colorWithRed:143.0/255.0 green:196.0/255.0 blue:72.0/255.0 alpha:1.0];
	gray = [UIColor colorWithRed:64.0/255.0 green:63.0/255.0 blue:65.0/255.0 alpha:1.0];
	lightgray = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1.0];
	darkgray = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:48.0/255.0 alpha:1.0];
	white = [UIColor whiteColor];
	marker = [UIColor colorWithRed:242.0/255.0 green:147.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    playImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"30-circle-play.png"]];
    pauseImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"29-circle-pause.png"]];
    stopImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"35-circle-stop.png"]];

    leftSlider = [[AudioSlider alloc] init];
    leftSlider.frame = CGRectMake(-5, 12, 10.0, self.view.bounds.size.height - 12);
    [leftSlider addTarget:self action:@selector(draggedOut:withEvent:)
         forControlEvents:UIControlEventTouchDragOutside |
     UIControlEventTouchDragInside];
    

    rightSlider = [[AudioSlider alloc] init];
    rightSlider.frame = CGRectMake(self.view.bounds.size.width - 88.0 - 5.0, 12, 10.0, self.view.bounds.size.height - 12);
    [rightSlider addTarget:self action:@selector(draggedOut:withEvent:)
          forControlEvents:UIControlEventTouchDragOutside |
     UIControlEventTouchDragInside];
    
    
    leftTint = [[AudioTint alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, leftSlider.center.x, self.view.bounds.size.height)];
    [self.view addSubview:leftTint];
    [self.view addSubview:leftSlider];
    
    rightTint = [[AudioTint alloc] initWithFrame:CGRectMake(rightSlider.center.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:rightTint];
    [self.view addSubview:rightSlider];
    
}

- (void) draggedOut: (UIControl *) c withEvent: (UIEvent *) ev {
    
    //Stop playing if you begin to crop.
    //[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"StopAudio" object:nil userInfo:nil]];
    
    NSLog(@"Dragging");
    CGPoint point = [[[ev allTouches] anyObject] locationInView:self.view];
    //CGRect waveRect = [self waveRect];
    //all of these checks arent precise because they dont take into account the width of the bar
    if(point.x > 0 && point.x < self.view.bounds.size.width){
        if([c isEqual:leftSlider]){
            if(rightSlider.center.x - point.x > SLIDER_BUFFER){
                c.center = CGPointMake(point.x, c.center.y);
            }
            else{
                c.center = CGPointMake(rightSlider.center.x - SLIDER_BUFFER, c.center.y);
            }
            if(player.rate == 0.0){
                [self setPlayHeadToLeftSlider];
            }
            leftTint.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, leftSlider.center.x, self.view.bounds.size.height);
            [leftTint setNeedsDisplay];
        }
        else{
            if(leftSlider.center.x - point.x < -SLIDER_BUFFER){
                c.center = CGPointMake(point.x, c.center.y);
            }
            else{
                c.center = CGPointMake(leftSlider.center.x + SLIDER_BUFFER, c.center.y);
            }
            rightTint.frame = CGRectMake(rightSlider.center.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
            [rightTint setNeedsDisplay];
        }

    }
}

-(void)playFunction{
    //[waveformView setPlayHeadToLeftSlider];
//    if(player.rate == 0.0){
//        [playButton setImage:[UIImage imageNamed:@"29-circle-pause.png"] forState:UIControlStateNormal];
//    }
//    else{
//        [playButton setImage:[UIImage imageNamed:@"30-circle-play.png"] forState:UIControlStateNormal];
//    }
    [self pauseAudio];
}

-(void)setPlayHeadToLeftSlider{
//    CGRect wr = [self waveRect];
//    CGFloat x = leftSlider.center.x - wr.origin.x;
//    float sel = x / wr.size.width;
//    Float64 duration = CMTimeGetSeconds(player.currentItem.duration);
//    float timeSelected = duration * sel;
//    CMTime tm = CMTimeMakeWithSeconds(timeSelected, NSEC_PER_SEC);
//    [player seekToTime:tm];
}

-(void)loadAudioForPath:(NSString *)path{
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL *audioURL = [NSURL fileURLWithPath:path];
        //[wfv openAudioURL:audioURL];
        [self openAudioURL:audioURL];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Audio !"
                                                        message: @"You should add a sample.mp3 file to the project before test it."
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}


- (void) setTimeString:(NSString *)newTime
{
	//[timeString release];
	timeString = newTime;
	[self.view setNeedsDisplay];
}

- (void) openAudioURL:(NSURL *)url
{
	if(player != nil) {
		[player pause];
		//[player release];
		player = nil;
	}
	[AppModel sharedAppModel].sampleLength = 0;
	[wf setNeedsDisplay];
	//[progress setHidden:FALSE];
	//[progress startAnimating];
	//[wsp release];
	wsp = [[WaveSampleProvider alloc]initWithURL:url];
	wsp.delegate = self;
	[wsp createSampleData];
}

- (void) pauseAudio
{
	if(player == nil) {
		[self startAudio];
		[player play];
		//[self setInfoString:@"Playing"];
	} else {
		if(player.rate == 0.0) {
			[player play];
			//[self setInfoString:@"Playing"];
		} else {
			[player pause];
			//[self setInfoString:@"Paused"];
		}
	}
}

- (void) startAudio
{
	if(wsp.status == LOADED) {
		player = [[AVPlayer alloc] initWithURL:wsp.audioURL];
		CMTime tm = CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC);
		[player addPeriodicTimeObserverForInterval:tm queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
			Float64 duration = CMTimeGetSeconds(player.currentItem.duration);
			Float64 currentTime = CMTimeGetSeconds(player.currentTime);
			int dmin = duration / 60;
			int dsec = duration - (dmin * 60);
			int cmin = currentTime / 60;
			int csec = currentTime - (cmin * 60);
			if(currentTime > 0.0) {
				[self setTimeString:[NSString stringWithFormat:@"%02d:%02d/%02d:%02d",cmin,csec,dmin,dsec]];
			}
			playProgress = currentTime/duration;
			[wf setNeedsDisplay];
		}];
	}
}



- (void) setSampleData:(float *)theSampleData length:(int)length
{
	//[progress setHidden:FALSE];
	//[progress startAnimating];
	[AppModel sharedAppModel].sampleLength = 0;
	
	length += 2;
	CGPoint *tempData = (CGPoint *)calloc(sizeof(CGPoint),length);
	tempData[0] = CGPointMake(0.0,0.0);
	tempData[length-1] = CGPointMake(length-1,0.0);
	for(int i = 1; i < length-1;i++) {
		tempData[i] = CGPointMake(i, theSampleData[i]);
	}
	
	CGPoint *oldData = [AppModel sharedAppModel].sampleData;
	
	[AppModel sharedAppModel].sampleData = tempData;
	[AppModel sharedAppModel].sampleLength = length;
	
	if(oldData != nil) {
		free(oldData);
	}
	
	free(theSampleData);
	//[progress setHidden:TRUE];
	//[progress stopAnimating];
	[wf setNeedsDisplay];
}

#pragma mark -
#pragma mark Sample Data Provider Delegat
- (void) statusUpdated:(WaveSampleProvider *)provider
{
	//[self setInfoString:wsp.statusMessage];
}

- (void) sampleProcessed:(WaveSampleProvider *)provider
{
	if(wsp.status == LOADED) {
		int sdl = 0;
		//		float *sd = [wsp dataForResolution:[self waveRect].size.width lenght:&sdl];
		float *sd = [wsp dataForResolution:8000 lenght:&sdl];
		[self setSampleData:sd length:sdl];
		//[self setInfoString:@"Paused"];
		int dmin = wsp.minute;
		int dsec = wsp.sec;
		[self setTimeString:[NSString stringWithFormat:@"--:--/%02d:%02d",dmin,dsec]];
		[self startAudio];
		
	}
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end
