//
//  SparkSetupVideoViewController.m
//  Pods
//
//  Created by Ido on 6/15/15.
//
//

#import "SparkSetupVideoViewController.h"
#import "SparkSetupCustomization.h"
#import <MediaPlayer/MediaPlayer.h>
#if ANALYTICS
#import <Mixpanel.h>
#endif

@interface SparkSetupVideoViewController ()
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;
@end

@implementation SparkSetupVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // move to super viewdidload?
    self.brandImageView.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;

    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)viewWillAppear:(BOOL)animated
{
#ifdef ANALYTICS
    [[Mixpanel sharedInstance] timeEvent:@"Device Setup: How-To video screen activity"];
#endif
}


-(void)viewWillDisappear:(BOOL)animated
{
#ifdef ANALYTICS
    [[Mixpanel sharedInstance] track:@"Device Setup: How-To video screen activity"];
#endif
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    self.videoViewWidth.constant = ((self.videoView.frame.size.height * 9.0)/16.0);
    
    
    if (self.videoFilePath)
    {
        NSArray *videoFilenameArr = [self.videoFilePath componentsSeparatedByString:@"."];
        NSString *path = [[NSBundle mainBundle] pathForResource:videoFilenameArr[0] ofType:videoFilenameArr[1]];
        
        if (path)
            self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
        if (self.videoPlayer)
        {
            self.videoPlayer.shouldAutoplay = YES;
            self.videoPlayer.view.frame = self.videoView.bounds;
            self.videoPlayer.repeatMode = MPMovieRepeatModeOne;
            self.videoPlayer.fullscreen = NO;
            self.videoPlayer.movieSourceType = MPMovieSourceTypeFile;
            self.videoPlayer.scalingMode = MPMovieScalingModeAspectFit;
            self.videoPlayer.controlStyle = MPMovieControlStyleNone;
            [self.videoView addSubview:self.videoPlayer.view];
            [self.videoPlayer play];
//            self.videoView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//            self.videoView.layer.borderWidth = 0.5;
            
        }
    }
    
    
    
}

- (IBAction)doneButtonTapped:(id)sender {
    [self.videoPlayer stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
