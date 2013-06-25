//
//  AudioVisualizerContainerViewController.m
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/24/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "AudioVisualizerContainerViewController.h"

#import "WaveformViewController.h"
#import "FreqHistogramViewController.h"
//#import "JSON.h"
//#import "AppServices.h"
//#import "AppModel.h"

@interface AudioVisualizerContainerViewController ()

@end

@implementation AudioVisualizerContainerViewController

@synthesize currentChildViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = @"Game";
    }
    return self;
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.title = @"HELLLLLA";
    
    //Set up the right navbar buttons without a border.
    self.withoutBorderButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [self.withoutBorderButton setImage:[UIImage imageNamed:@"30-circle-play.png"] forState:UIControlStateNormal];
    [self.withoutBorderButton addTarget:self action:@selector(flipView) forControlEvents:UIControlEventTouchUpInside];
    self.rightNavBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.withoutBorderButton];
    self.navigationItem.rightBarButtonItem = self.rightNavBarButton;
    
    WaveformViewController *waveformViewController = [[WaveformViewController alloc] initWithNibName:@"WaveformViewController" bundle:nil];
    
    [self addChildViewController:waveformViewController];
    [self displayContentController:[[self childViewControllers] objectAtIndex:0]];
}

- (void) displayContentController:(UIViewController*)content
{
    if(currentChildViewController) [self hideContentController:currentChildViewController];
    
    [self addChildViewController:content];
    
    //Make a new rectangle with 88 as offset so that the Map is formated in the correct spot
    content.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)+88);
    
    [self.view addSubview:content.view];
    [content didMoveToParentViewController:self];
    
    currentChildViewController = content;
}

- (void) hideContentController:(UIViewController*)content
{
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
    
    currentChildViewController = nil;
}

-(IBAction)flipView{
    //figure out which view to flip to
    [self.rightNavBarButton setEnabled:NO];
    UIViewController *fromVC = [self currentChildViewController];
    WaveformViewController *toVCWave;
    FreqHistogramViewController *toVCFreq;
    UIViewController *toVC;
    NSUInteger animation;
    if([fromVC isKindOfClass:[WaveformViewController class]]){
        toVCFreq = [[FreqHistogramViewController alloc] initWithNibName:@"FreqHistogramViewController" bundle:nil];
        animation = UIViewAnimationOptionTransitionFlipFromRight;
        [self.withoutBorderButton setImage:[UIImage imageNamed:@"35-circle-stop.png"] forState:UIControlStateNormal];
        toVC = toVCFreq;
    }
    else{
        
        toVCWave = [[WaveformViewController alloc] initWithNibName:@"WaveformViewController" bundle:nil];
        animation = UIViewAnimationOptionTransitionFlipFromLeft;
        [self.withoutBorderButton setImage:[UIImage imageNamed:@"30-circle-play.png"] forState:UIControlStateNormal];
        toVC = toVCWave;
    }
    
    CGRect rect = fromVC.view.bounds;
    toVC.view.frame = rect;
    
    //transition between views
    [self addChildViewController:toVC];
    [self transitionFromViewController:fromVC toViewController:toVC duration: .5 options:animation animations:^{} completion:^(BOOL finished){
        //hide old view
        [fromVC willMoveToParentViewController:nil];
        [fromVC.view removeFromSuperview];
        [fromVC removeFromParentViewController];
        
        //show new view
        [self.view addSubview:toVC.view];
        [toVC didMoveToParentViewController:self];
        
        currentChildViewController = toVC;
        [self.rightNavBarButton setEnabled:YES];
    }];
    
    
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end