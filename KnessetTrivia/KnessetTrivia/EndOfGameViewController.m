//
//  EndOfGameViewController.m
//  KnessetTrivia
//
//  Created by Stav Ashuri on 5/2/12.
//   
//

#import <QuartzCore/QuartzCore.h>
#import "EndOfGameViewController.h"
#import "ScoreManager.h"
#import "SocialManager.h"

@interface EndOfGameViewController ()

@end

@implementation EndOfGameViewController
@synthesize delegate;

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
    CALayer *l = [self.view layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    
    CALayer *l2 = [scoreBgView layer];
    [l2 setMasksToBounds:YES];
    [l2 setCornerRadius:10.0];
    
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0, 0);
    self.view.layer.shadowOpacity = 0.6;
    self.view.layer.shadowRadius = 20.0;
    self.view.clipsToBounds = NO;

    scoreLabel.text = [NSString stringWithFormat:@"%d",[[ScoreManager sharedManager] getCurrentScoreAboveZero]];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - Animations

- (void) animationStopped {
    [self.view removeFromSuperview];
}

- (void) closeAnimated {
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationStopped)];
    self.view.alpha = 0;
    [UIView commitAnimations];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - IBActions

- (IBAction)closePressed:(id)sender {
    [self.delegate reEnableGeneralScreenRequested];
    [self closeAnimated];
}

- (IBAction)sharePressed:(id)sender {
    BOOL isFacebookConnected = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsIsFacebookConnectedKey] boolValue];
    if (isFacebookConnected) {
        [[SocialManager sharedManager] postToFacebookWithFeedDialogWithPostName:@"?????????????????? ?????????????? ????????" andCaption:[NSString stringWithFormat:@"???????????? ?????????? %d ???????????? ???????????????????? ?????????????? ????????!",[[ScoreManager sharedManager] getCurrentScoreAboveZero]] andDescription:nil andLink:@"https://itunes.apple.com/il/app/trywwyh-knst/id528980460?mt=8" andPictureUrl:nil onCompletion:^{
            NSLog(@"Score posted to user's timeline");
        } onFailure:^(NSString *errorDescription) {
            NSLog(@"Error - couldn't post to facebook: %@",errorDescription);
        }];
    } else {
        
    }
}

@end
