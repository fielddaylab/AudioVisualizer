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
#import "WaveformControl.h"
#import "AudioTint.h"

#define SLIDER_BUFFER 5

@interface AudioVisualizerViewController (){
    UIToolbar *toolbar;
    UIButton *withoutBorderButton;
    UIBarButtonItem *playButton;
    AudioSlider *leftSlider;
    AudioSlider *rightSlider;
    AudioTint *leftTint;
    AudioTint *rightTint;
    WaveformControl *wf;
    FreqHistogramControl *freq;
    id timeObserver;
    UILabel *timeLabel;
    UIBarButtonItem *timeButton;
    Float64 duration;

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
    
    
    //Set up the right navbar buttons without a border.
    self.withoutBorderButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [self.withoutBorderButton setImage:[UIImage imageNamed:@"57-download"] forState:UIControlStateNormal];
    [self.withoutBorderButton addTarget:self action:@selector(flipView) forControlEvents:UIControlEventTouchUpInside];
    self.rightNavBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.withoutBorderButton];
    self.navigationItem.rightBarButtonItem = self.rightNavBarButton;
    
    
    [self loadAudioForPath:@"/Users/nickheindl/Desktop/AudioVisualizer/AudioVisualizer/AudioVisualizer/sample.m4a"];
    
    freq = [[FreqHistogramControl alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 88, self.view.bounds.size.height)];
    
    [self.view addSubview:freq];
    
    
    wf = [[WaveformControl alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 88, self.view.bounds.size.height + 12)];
    wf.delegate = self;
    [self.view addSubview:wf];

    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
    toolbar = [[UIToolbar alloc]init];
    toolbar.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
    withoutBorderButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [withoutBorderButton setImage:[UIImage imageNamed:@"30-circle-play.png"] forState:UIControlStateNormal];
    [withoutBorderButton addTarget:self action:@selector(playFunction) forControlEvents:UIControlEventTouchUpInside];
    playButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButton];

    UIButton *withoutBorderStopButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [withoutBorderStopButton setImage:[UIImage imageNamed:@"35-circle-stop.png"] forState:UIControlStateNormal];
    [withoutBorderStopButton addTarget:self action:@selector(stopFunction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *stopButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderStopButton];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *withoutBorderSaveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [withoutBorderSaveButton setImage:[UIImage imageNamed:@"57-download"] forState:UIControlStateNormal];
    [withoutBorderSaveButton addTarget:self action:@selector(trimAudio) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderSaveButton];
    
    
    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 125, 25)];
    [timeLabel setText:timeString];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextColor:[UIColor whiteColor]];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    timeButton = [[UIBarButtonItem alloc] initWithCustomView:timeLabel];
    
    NSArray *toolbarButtons = [NSArray arrayWithObjects:playButton, saveButton, flexibleSpace, timeButton, flexibleSpace, stopButton, nil];
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
	[AppModel sharedAppModel].playProgress = 0.0;

    
	green = [UIColor colorWithRed:143.0/255.0 green:196.0/255.0 blue:72.0/255.0 alpha:1.0];
	gray = [UIColor colorWithRed:64.0/255.0 green:63.0/255.0 blue:65.0/255.0 alpha:1.0];
	lightgray = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1.0];
	darkgray = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:48.0/255.0 alpha:1.0];
	white = [UIColor whiteColor];
	marker = [UIColor colorWithRed:242.0/255.0 green:147.0/255.0 blue:0.0/255.0 alpha:1.0];

    
    leftSlider = [[AudioSlider alloc] init];
    leftSlider.frame = CGRectMake(-7.5, 12, 15.0, self.view.bounds.size.height - 12);
    [leftSlider addTarget:self action:@selector(draggedOut:withEvent:)
         forControlEvents:UIControlEventTouchDragOutside |
     UIControlEventTouchDragInside];
    

    rightSlider = [[AudioSlider alloc] init];
    rightSlider.frame = CGRectMake(self.view.bounds.size.width - 88.0 - 7.5, 12, 15.0, self.view.bounds.size.height - 12);
    [rightSlider addTarget:self action:@selector(draggedOut:withEvent:)
          forControlEvents:UIControlEventTouchDragOutside |
     UIControlEventTouchDragInside];
    
    
    leftTint = [[AudioTint alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, 12, leftSlider.center.x, self.view.bounds.size.height)];
    [self.view addSubview:leftTint];
    [self.view addSubview:leftSlider];
    
    rightTint = [[AudioTint alloc] initWithFrame:CGRectMake(rightSlider.center.x, 12, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:rightTint];
    [self.view addSubview:rightSlider];
    
    [AppModel sharedAppModel].endTime = 1.0;

    
}

- (void) draggedOut: (UIControl *) c withEvent: (UIEvent *) ev {
    
    [self stopFunction];
    CGPoint point = [[[ev allTouches] anyObject] locationInView:self.view];

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

            CGFloat x = rightSlider.center.x - self.view.bounds.origin.x;
            float sel = x / self.view.bounds.size.width;
            [AppModel sharedAppModel].endTime = sel;
            if([AppModel sharedAppModel].endTime <= [AppModel sharedAppModel].playProgress){
                [self setPlayHeadToLeftSlider];
            }
        }

    }
}

-(void)playFunction{
    if(player.rate == 0.0){
        [withoutBorderButton setImage:[UIImage imageNamed:@"29-circle-pause.png"] forState:UIControlStateNormal];
        [withoutBorderButton addTarget:self action:@selector(playFunction) forControlEvents:UIControlEventTouchUpInside];
        playButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButton];
    }
    else{
        [withoutBorderButton setImage:[UIImage imageNamed:@"30-circle-play.png"] forState:UIControlStateNormal];
        [withoutBorderButton addTarget:self action:@selector(playFunction) forControlEvents:UIControlEventTouchUpInside];
        playButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButton];
    }
    [self pauseAudio];
    [self updateTimeString];
    NSLog(@"Updated Time String: Play Function");
}

-(void)stopFunction{
    if(player.rate != 0.0){
        [self pauseAudio];
        [withoutBorderButton setImage:[UIImage imageNamed:@"30-circle-play.png"] forState:UIControlStateNormal];
        [withoutBorderButton addTarget:self action:@selector(playFunction) forControlEvents:UIControlEventTouchUpInside];
        playButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButton];
        [player removeTimeObserver:timeObserver];
        [self addTimeObserver];
        [self setPlayHeadToLeftSlider];
    }
}

-(void)setPlayHeadToLeftSlider{
    CGFloat x = leftSlider.center.x - self.view.bounds.origin.x;
    float sel = x / self.view.bounds.size.width;
    duration = CMTimeGetSeconds(player.currentItem.duration);
    float timeSelected = duration * sel;
    CMTime tm = CMTimeMakeWithSeconds(timeSelected, NSEC_PER_SEC);
    [player seekToTime:tm];
}

-(void)loadAudioForPath:(NSString *)path{
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL *audioURL = [NSURL fileURLWithPath:path];
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

-(void)updateTimeString{
    duration = CMTimeGetSeconds(player.currentItem.duration);
    Float64 currentTime = CMTimeGetSeconds(player.currentTime);
    int dmin = duration / 60;
    int dsec = duration - (dmin * 60);
    int cmin = currentTime / 60;
    int csec = currentTime - (cmin * 60);
    [self setTimeString:[NSString stringWithFormat:@"%02d:%02d/%02d:%02d",cmin,csec,dmin,dsec]];
    [AppModel sharedAppModel].playProgress = currentTime/duration;
}

- (void) setTimeString:(NSString *)newTime
{
	//[timeString release];
	timeString = newTime;
    [timeLabel setText:timeString];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextColor:[UIColor whiteColor]];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    timeButton = [[UIBarButtonItem alloc] initWithCustomView:timeLabel];
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
		[self addTimeObserver];
	}
}

-(void)addTimeObserver{
    CMTime tm = CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC);
    timeObserver = [player addPeriodicTimeObserverForInterval:tm queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [self updateTimeString];
        [wf setNeedsDisplay];
    }];
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
    [freq setNeedsDisplay];
}

-(void)printSampleData:(CGPoint *)mySampleData forSampleLength:(int)mySampleLength{
    for(int i = 0; i < mySampleLength; i++){
        NSLog(@"X: %f Y: %f", mySampleData[i].x, mySampleData[i].y);
    }
}

#pragma mark -
#pragma mark Sample Data Provider Delegate
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
        //[self printSampleData:[AppModel sharedAppModel].sampleData forSampleLength:[AppModel sharedAppModel].sampleLength];
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

#pragma mark Waveform control delegate

-(void)waveformControl:(WaveformControl *)waveform wasTouched:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
	CGPoint local_point = [touch locationInView:self.view];
	//CGRect wr = [self waveRect];
	if(CGRectContainsPoint(self.view.bounds,local_point) && player != nil) {
        CGFloat x = local_point.x - self.view.bounds.origin.x;
        float sel = x / self.view.bounds.size.width;
        duration = CMTimeGetSeconds(player.currentItem.duration);
        float timeSelected = duration * sel;
        CMTime tm = CMTimeMakeWithSeconds(timeSelected, NSEC_PER_SEC);
        [player seekToTime:tm];
        
	}
}

-(void)clipOver{
    [self stopFunction];
}

#pragma mark Saving Data

- (BOOL)trimAudio
{

    
    float vocalStartMarker  = leftSlider.center.x  / self.view.frame.size.width;
    float vocalEndMarker    = rightSlider.center.x / self.view.frame.size.width;
    NSLog(@"HOLAAAA");
    NSString *inputPath =  @"/Users/nickheindl/Desktop/AudioVisualizer/AudioVisualizer/AudioVisualizer/sample.m4a";
    NSString *outputPath = @"/Users/nickheindl/Desktop/AudioVisualizer/AudioVisualizer/AudioVisualizer/sample10.m4a";
    
    
    NSURL *audioFileInput = [NSURL fileURLWithPath:inputPath];
    NSURL *audioFileOutput = [NSURL fileURLWithPath:outputPath];
    
    if (!audioFileInput || !audioFileOutput)
    {
        return NO;
    }
    
    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
    AVAsset *asset = [AVAsset assetWithURL:audioFileInput];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                        presetName:AVAssetExportPresetAppleM4A];
    
    if (exportSession == nil)
    {
        return NO;
    }
    NSLog(@"Left: %f Right: %f",vocalStartMarker,vocalEndMarker);
    
    duration = CMTimeGetSeconds(player.currentItem.duration);
    
    vocalStartMarker *= duration;
    vocalEndMarker *= duration;

    CMTime startTime = CMTimeMake(vocalStartMarker , 1);
    CMTime stopTime = CMTimeMake(vocalEndMarker , 1);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    exportSession.outputURL = audioFileOutput;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = exportTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         if (AVAssetExportSessionStatusCompleted == exportSession.status)
         {
             // It worked!
             // Show a popup saying it worked (maybe)
             NSLog(@"WORKED");
         }
         else if (AVAssetExportSessionStatusFailed == exportSession.status)
         {
             // It failed...
             // Show an error as a popup
             NSLog(@"DIDNT WORK");
         }
     }];
    
    return YES;
}

- (void) flipView
{

#pragma mark Control
//subviews[0 or 1 (not sure yet)] is wf; subviews[2] is freq
[self.view.subviews[0] setHidden:[self.view.subviews[2] isHidden]];
[self.view.subviews[2] setHidden:![self.view.subviews[2] isHidden]];

}



@end
