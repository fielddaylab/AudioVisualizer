//
//  AudioVisualizerViewController.m
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "AudioVisualizerViewController.h"
#import "WaveformControl.h"
#import "FreqHistogramControl.h"
#import "WaveformControl.h"
#import "AudioTint.h"
#import <Accelerate/Accelerate.h>

#define SLIDER_BUFFER 5

@interface AudioVisualizerViewController (){
    UIToolbar *toolbar;
    UIButton *withoutBorderButton;
    UIButton *withoutBorderButtonStop;
    UIBarButtonItem *playButton;
    UIBarButtonItem *stopButton;
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

    
    UILabel *freqLabel;
    UIBarButtonItem *freqButton;
    
    ExtAudioFileRef extAFRef;
    int extAFNumChannels;
    NSURL *audioURL;
    NSString *path;
}

- (void) initView;
- (void) setSampleData:(float *)theSampleData length:(int)length;
- (void) startAudio;
- (void) pauseAudio;
@end

@implementation AudioVisualizerViewController

@synthesize sampleData;
@synthesize sampleLength;
@synthesize playProgress;
@synthesize endTime;
@synthesize lengthInSeconds;

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
    
    [self.navigationItem setHidesBackButton:YES animated:YES];

    
    
    //Can either have text 'Save' or a floppy icon.
    withoutBorderButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [withoutBorderButton setImage:[UIImage imageNamed:@"57-download"] forState:UIControlStateNormal];
    [withoutBorderButton addTarget:self action:@selector(saveAudioConfirmation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftNavBarButton = [[UIBarButtonItem alloc] initWithCustomView:withoutBorderButton];
    self.navigationItem.leftBarButtonItem = leftNavBarButton;
    
    //Can maybe have 77-ekg and 17-bar-chart (with a tad bit of editing) for wf/freq respectively
    withoutBorderButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [withoutBorderButton setImage:[UIImage imageNamed:@"05-shuffle"] forState:UIControlStateNormal];
    [withoutBorderButton addTarget:self action:@selector(flipView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightNavBarButton = [[UIBarButtonItem alloc] initWithCustomView:withoutBorderButton];
    self.navigationItem.rightBarButtonItem = rightNavBarButton;
    
    path = @"/Users/nickheindl/Desktop/AudioVisualizer/AudioVisualizer/AudioVisualizer/3000hz.m4a";
    [self loadAudioForPath:path];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIAlertView *alertRotate = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"RotateToLandscapeKey", nil) message:nil delegate:self cancelButtonTitle: NSLocalizedString(@"OkKey", nil) otherButtonTitles:nil, nil];
    
    [alertRotate setTag:1];
    [alertRotate show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

    freq = [[FreqHistogramControl alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 88, self.view.bounds.size.height + 12)];
    freq.delegate = self;
    [self.view addSubview:freq];
    
    
    wf = [[WaveformControl alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 88, self.view.bounds.size.height + 12)];
    wf.delegate = self;
    [self.view addSubview:wf];
    
    
    leftSlider = [[AudioSlider alloc] init];
    leftSlider.frame = CGRectMake(-7.5, 0, 15.0, self.view.bounds.size.height + 12);
    [leftSlider addTarget:self action:@selector(draggedOut:withEvent:)
         forControlEvents:UIControlEventTouchDragOutside |
     UIControlEventTouchDragInside];

    rightSlider = [[AudioSlider alloc] init];
    rightSlider.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 7.5, 0, 15.0, self.view.bounds.size.height + 12);
    [rightSlider addTarget:self action:@selector(draggedOut:withEvent:)
          forControlEvents:UIControlEventTouchDragOutside |
     UIControlEventTouchDragInside];
    
    
    leftTint = [[AudioTint alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, 12, leftSlider.center.x, self.view.bounds.size.height)];
    [self.view addSubview:leftTint];
    [self.view addSubview:leftSlider];
    
    rightTint = [[AudioTint alloc] initWithFrame:CGRectMake(rightSlider.center.x, 12, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:rightTint];
    [self.view addSubview:rightSlider];
    
    toolbar = [[UIToolbar alloc]init];
    toolbar.frame = CGRectMake(self.view.bounds.origin.x, wf.bounds.size.height, self.view.bounds.size.width, 44);
    
    withoutBorderButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [withoutBorderButton setImage:[UIImage imageNamed:@"30-circle-play.png"] forState:UIControlStateNormal];
    [withoutBorderButton addTarget:self action:@selector(playFunction) forControlEvents:UIControlEventTouchUpInside];
    playButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButton];
    
    withoutBorderButtonStop = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [withoutBorderButtonStop setImage:[UIImage imageNamed:@"35-circle-stop.png"] forState:UIControlStateNormal];
    [withoutBorderButtonStop addTarget:self action:@selector(stopFunction) forControlEvents:UIControlEventTouchUpInside];
    stopButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButtonStop];
    
    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 125, 25)];
    [timeLabel setText:timeString];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    timeButton = [[UIBarButtonItem alloc] initWithCustomView:timeLabel];
    
    freqLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 125, 25)];
    [freqLabel setText:@""];
    [freqLabel setBackgroundColor:[UIColor clearColor]];
    [freqLabel setTextColor:[UIColor whiteColor]];
    [freqLabel setTextAlignment:NSTextAlignmentCenter];
    freqButton = [[UIBarButtonItem alloc]initWithCustomView:freqLabel];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    NSLog(@"%f height lulz",[UIScreen mainScreen].bounds.size.height);
    //Normal Screen - 480
    //fixedSpace.width = 42;//42*3=128 ; 480-128=352 -> ([UIScreen mainScreen].bounds.size.height - 352)/3
    //4 Inch Screen - 568
    //fixedSpace.width = 72;//72*3=216 ; 568-216=352 -> ([UIScreen mainScreen].bounds.size.height - 352)/3
    fixedSpace.width = ([UIScreen mainScreen].bounds.size.height - 352)/3;
    
    NSArray *toolbarButtons = [NSArray arrayWithObjects:playButton, fixedSpace, timeButton, fixedSpace, freqButton, fixedSpace, stopButton, nil];
    [toolbar setItems:toolbarButtons animated:NO];
    [self.view addSubview:toolbar];
    
    endTime = 1.0;
    
    audioURL = [NSURL fileURLWithPath:path];
    OSStatus err;
	CFURLRef inpUrl = (__bridge CFURLRef)audioURL;
	err = ExtAudioFileOpenURL(inpUrl, &extAFRef);
	if(err != noErr) {
		NSLog(@"Cannot open audio file");
		return;
	}
    
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
            endTime = sel;
            if(endTime <= playProgress){
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

-(void)loadAudioForPath:(NSString *)pathURL{
    if([[NSFileManager defaultManager] fileExistsAtPath:pathURL]) {
        NSURL *audio = [NSURL fileURLWithPath:pathURL];
        [self openAudioURL:audio];
    } else {
        UIAlertView *alertNoAudio = [[UIAlertView alloc] initWithTitle: @"No Audio !"
                                                        message: @"You should add a sample.mp3 file to the project before test it."
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alertNoAudio setTag:3];
        [alertNoAudio show];
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
    playProgress = currentTime/duration;
}

- (void) setTimeString:(NSString *)newTime
{
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
		player = nil;
	}
	sampleLength = 0;
	[wf setNeedsDisplay];
	wsp = [[WaveSampleProvider alloc]initWithURL:url];
	wsp.delegate = self;
	[wsp createSampleData];
}

- (void) pauseAudio
{
	if(player == nil) {
		[self startAudio];
		[player play];
	} else {
		if(player.rate == 0.0) {
			[player play];
		} else {
			[player pause];
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
        [self loadAudio];
        if(playProgress >= endTime){
            [self clipOver];
        }
    }];
}


- (void) setSampleData:(float *)theSampleData length:(int)length
{
	sampleLength = 0;
	
	length += 2;
	CGPoint *tempData = (CGPoint *)calloc(sizeof(CGPoint),length);
	tempData[0] = CGPointMake(0.0,0.0);
	tempData[length-1] = CGPointMake(length-1,0.0);
	for(int i = 1; i < length-1;i++) {
		tempData[i] = CGPointMake(i, theSampleData[i]);
	}
	
	CGPoint *oldData = sampleData;
	
	sampleData = tempData;
	sampleLength = length;
	
	if(oldData != nil) {
		free(oldData);
	}
	
	free(theSampleData);
	[wf setNeedsDisplay];
    [freq setNeedsDisplay];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
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
		int dmin = wsp.minute;
		int dsec = wsp.sec;
		[self setTimeString:[NSString stringWithFormat:@"--:--/%02d:%02d",dmin,dsec]];
		[self startAudio];
		
	}
}

-(void)setAudioLength:(float)seconds{
    self.lengthInSeconds = seconds;
}



#pragma mark Waveform control delegate

-(void)waveformControl:(WaveformControl *)waveform wasTouched:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
	CGPoint local_point = [touch locationInView:self.view];
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

-(CGPoint *)getSampleData{
    return sampleData;
}

-(int)getSampleLength{
    return sampleLength;
}

-(float)getPlayProgress{
    return playProgress;
}

#pragma mark Freq Histogram control delegate
-(void)freqHistogramControl:(WaveformControl *)waveform wasTouched:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
    CGPoint local_point = [touch locationInView:freq];
    float binWidth = freq.bounds.size.width / 256;
    float bin = local_point.x / binWidth;
    NSLog(@"Frequency: %.2f", (bin * 44100.0)/512);
    
    if(CGRectContainsPoint(freq.bounds,local_point)){
        freq.currentFreqX = local_point.x;
    }
    
    [freq setNeedsDisplay];
    
    [freqLabel setText:[NSString stringWithFormat:@"%.2f Hz", ((bin * 44100.0)/512)]];
    [freqLabel setBackgroundColor:[UIColor clearColor]];
    [freqLabel setTextColor:[UIColor whiteColor]];
    [freqLabel setTextAlignment:NSTextAlignmentCenter];
    freqButton = [[UIBarButtonItem alloc] initWithCustomView:freqLabel];
}

#pragma mark Saving Data

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{ 
    if(alertView.tag >= 2)
    {
        if (buttonIndex == 1)
        {
            [self saveAudio];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)saveAudioConfirmation
{
    [player pause];
    UIAlertView *confirmationAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"SaveConfirmationKey", nil)
                                                               message:nil
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"DiscardKey", nil)
                                                     otherButtonTitles:NSLocalizedString(@"SaveKey", nil), nil];
    [confirmationAlert setTag:2];
    [confirmationAlert show];
}

- (BOOL)saveAudio
{
    //TODO in ARIS: We'll need to put the sample back at the original file at the very end.
                //  We'll need to change the paths in general to reflect aris's stuff
                //  We'll probably have to convert .caf from ARIS to .m4a - talk to David because he talked about switching over to .m4a anyways.
    
    //Also need to force into landscape. Seems like a bitch to do so in iOS6 >:/
    //If not there already, need to add DiscardKey "Discard", SaveKey "Save", and SaveConfirmationKey "Would you like to save?"
    //Also SaveErrorKey "Sorry, the file didn't save properly" ; ErrorKey "Error :'[" ; RotateToLandscapeKey "Rotate to Landscape"
    
    //possibly add slider's representation of time. Something like this:
    //*toolbarButtons = [NSArray arrayWithObjects:
    //playButton, leftPlayHeadTime, flexibleSpace, timeButton, flexibleSpace, rightPlayHeadTime, stopButton, nil];
    
    float vocalStartMarker  = leftSlider.center.x  / self.view.frame.size.width;
    float vocalEndMarker    = rightSlider.center.x / self.view.frame.size.width;

    NSString *inputPath =  @"/Users/nickheindl/Desktop/AudioVisualizer/AudioVisualizer/AudioVisualizer/sample12.m4a";
    NSString *outputPath = @"/Users/nickheindl/Desktop/AudioVisualizer/AudioVisualizer/AudioVisualizer/sample13.m4a";
    
    
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
             NSLog(@"DIDNT WORK");
             
             UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ErrorKey", nil)
                                                                        message:NSLocalizedString(@"SaveErrorKey", nil)
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"OkKey", nil)
                                                              otherButtonTitles:nil];
             [errorAlert setTag:4];
             [errorAlert show];
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
    [freqLabel setText:@""];
    [freqLabel setBackgroundColor:[UIColor clearColor]];
    [freqLabel setTextColor:[UIColor whiteColor]];
    [freqLabel setTextAlignment:NSTextAlignmentCenter];
    freqButton = [[UIBarButtonItem alloc]initWithCustomView:freqLabel];
    [leftSlider setHidden:![leftSlider isHidden]];
    [rightSlider setHidden:![rightSlider isHidden]];
    [leftTint setHidden:![leftTint isHidden]];
    [rightTint setHidden:![rightTint isHidden]];
}

#pragma mark Fourier Helper functions

-(void)loadAudio{
    
    extAFNumChannels = 2;
    
    OSStatus err;
    AudioStreamBasicDescription fileFormat;
    UInt32 propSize = sizeof(fileFormat);
    memset(&fileFormat, 0, sizeof(AudioStreamBasicDescription));
    
    err = ExtAudioFileGetProperty(extAFRef, kExtAudioFileProperty_FileDataFormat, &propSize, &fileFormat);
	if(err != noErr) {
		NSLog(@"Cannot get audio file properties");
		return;
	}
    
    Float64 sampleRate = 44100.0;
    
    float startingSample = (44100.0 * playProgress * lengthInSeconds);
    
    AudioStreamBasicDescription clientFormat;
    propSize = sizeof(clientFormat);
    
    memset(&clientFormat, 0, sizeof(AudioStreamBasicDescription));
    clientFormat.mFormatID = kAudioFormatLinearPCM;
    clientFormat.mSampleRate = sampleRate;
    clientFormat.mFormatFlags = kAudioFormatFlagIsFloat;
    clientFormat.mChannelsPerFrame = extAFNumChannels;
    clientFormat.mBitsPerChannel     = sizeof(float) * 8;
    clientFormat.mFramesPerPacket    = 1;
    clientFormat.mBytesPerFrame      = extAFNumChannels * sizeof(float);
    clientFormat.mBytesPerPacket     = extAFNumChannels * sizeof(float);
    
    err = ExtAudioFileSetProperty(extAFRef, kExtAudioFileProperty_ClientDataFormat, propSize, &clientFormat);
	if(err != noErr) {
		NSLog(@"Couldn't convert audio file to PCM format");
		return;
	}
    
    err = ExtAudioFileSeek(extAFRef, startingSample);
    if(err != noErr) {
		NSLog(@"Error in seeking in file");
		return;
	}
    
    float *returnData = (float *)malloc(sizeof(float) * 1024);
    
    AudioBufferList bufList;
    bufList.mNumberBuffers = 1;
    bufList.mBuffers[0].mNumberChannels = extAFNumChannels; // Always 2 channels in this example
    bufList.mBuffers[0].mData = returnData; // data is a pointer (float*) to our sample buffer
    bufList.mBuffers[0].mDataByteSize = 1024 * sizeof(float);
    
    UInt32 loadedPackets = 1024;
    
    err = ExtAudioFileRead(extAFRef, &loadedPackets, &bufList);
    if(err != noErr) {
		NSLog(@"Error in reading the file");
		return;
	}
    
    freq.fourierData = [self computeFFTForData:returnData forSampleSize:1024];
    [freq setNeedsDisplay];
    
}

-(float *)computeFFTForData:(float *)data forSampleSize:(int)bufferFrames{
    
    int bufferLog2 = round(log2(bufferFrames));
    FFTSetup fftSetup = vDSP_create_fftsetup(bufferLog2, kFFTRadix2);
    float *hammingWindow = (float *)malloc(sizeof(float) * bufferFrames);
    vDSP_hamm_window(hammingWindow, bufferFrames, 0);
    float outReal[bufferFrames / 2];
    float outImaginary[bufferFrames / 2];
    COMPLEX_SPLIT out = { .realp = outReal, .imagp = outImaginary };
    vDSP_vmul(data, 1, hammingWindow, 1, data, 1, bufferFrames);
    vDSP_ctoz((COMPLEX *)data, 2, &out, 1, bufferFrames / 2);
    vDSP_fft_zrip(fftSetup, &out, 1, bufferLog2, FFT_FORWARD);
    
    //print out data
    //    for(int i = 1; i < bufferFrames / 2; i++){
    //        float frequency = (i * 44100.0)/bufferFrames;
    //        float magnitude = sqrtf((out.realp[i] * out.realp[i]) + (out.imagp[i] * out.imagp[i]));
    //        float magnitudeDB = 10 * log10(out.realp[i] * out.realp[i] + (out.imagp[i] * out.imagp[i]));
    //        NSLog(@"Bin %i: Magnitude: %f Magnitude DB: %f  Frequency: %f Hz", i, magnitude, magnitudeDB, frequency);
    //    }
    
    //NSLog(@"\nSpectrum\n");
    //    for(int k = 0; k < bufferFrames / 2; k++){
    //        NSLog(@"Frequency %f Real: %f Imag: %f", (k * 44100.0)/bufferFrames, out.realp[k], out.imagp[k]);
    //    }
    
    float *mag = (float *)malloc(sizeof(float) * bufferFrames/2);
    float *phase = (float *)malloc(sizeof(float) * bufferFrames/2);
    float *magDB = (float *)malloc(sizeof(float) * bufferFrames/2);
    
    vDSP_zvabs(&out, 1, mag, 1, bufferFrames/2);
    vDSP_zvphas(&out, 1, phase, 1, bufferFrames/2);
    
    //NSLog(@"\nMag / Phase\n");
    for(int k = 1; k < bufferFrames/2; k++){
        float magnitudeDB = 10 * log10(out.realp[k] * out.realp[k] + (out.imagp[k] * out.imagp[k]));
        magDB[k] = magnitudeDB;
        //NSLog(@"Frequency: %f Magnitude DB: %f", (k * 44100.0)/bufferFrames, magnitudeDB);
        if(magDB[k] > freq.largestMag){
            freq.largestMag = magDB[k];
        }
        //NSLog(@"Frequency: %f Mag: %f Phase: %f", (k * 44100.0)/bufferFrames, mag[k], phase[k]);
    }
    
    return magDB;
}



@end
