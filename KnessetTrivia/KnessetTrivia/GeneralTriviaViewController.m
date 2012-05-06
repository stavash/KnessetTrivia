//
//  GeneralTriviaViewController.m
//  KnessetTrivia
//
//  Created by Stav Ashuri on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GeneralTriviaViewController.h"
#import "ImageTriviaViewController.h"
#import "RightWrongTriviaViewController.h"
#import "DataManager.h"
#import "ScoreManager.h"
#import "NewGameViewController.h"
#import "EndOfGameViewController.h"
#import "SoundEngine.h"

#define kGeneralTriviaSecondsToPlay 60.0

@interface GeneralTriviaViewController ()

@end

@implementation GeneralTriviaViewController
@synthesize scoreLabel,timer,timeProgressView,endOfGameVC,currentTriviaController;
@synthesize myNewGameVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"טריוויה";
        self.tabBarItem.image = [UIImage imageNamed:@"TriviaTab"];
    }
    return self;
}

- (void)viewDidLoad
{
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 330, 30, 30)];
    [newLabel setBackgroundColor:[UIColor clearColor]];
    [newLabel setMinimumFontSize:10.0];
    [newLabel setAdjustsFontSizeToFitWidth:YES];
    [newLabel setFont:[UIFont boldSystemFontOfSize:19.0]];
    [newLabel setTextAlignment:UITextAlignmentRight];
    self.scoreLabel = newLabel;
    [self.view addSubview:self.scoreLabel];
    [newLabel release];
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.trackTintColor = [UIColor whiteColor];
    progressView.progress = 1.0;
    progressView.frame = CGRectMake(80, 380, 220, 21);
    [self.view addSubview:progressView];
    self.timeProgressView = progressView;
    [progressView release];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScoreLabel) name:@"scoreUpdatedNotification" object:nil];
        
    [self showNewGameScreen];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.scoreLabel = nil;
    self.timer = nil;
    self.timeProgressView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) updateScoreLabel {
    scoreLabel.text = [[ScoreManager sharedManager] getCurrentScoreStr];
    if ([[ScoreManager sharedManager] isCurrentScorePositive]) {
        scoreLabel.textColor = [UIColor colorWithRed:10.0/255.0 green:158.0/255.0 blue:23.0/255.0 alpha:1.0];
    } else {
        scoreLabel.textColor = [UIColor colorWithRed:171.0/255.0 green:0.0 blue:8.0/255.0 alpha:1.0];
    }
}


#pragma mark - Screen Handling

- (void)showNewGameScreen {
    NewGameViewController *newGameViewCont = [[NewGameViewController alloc] initWithNibName:@"NewGameViewController" bundle:nil];
    newGameViewCont.view.alpha = 0;
    newGameViewCont.delegate = self;
    [self.view addSubview:newGameViewCont.view];
    self.myNewGameVC = newGameViewCont;
    [newGameViewCont release];
    
    [UIView beginAnimations:@"" context:nil];
    self.myNewGameVC.view.alpha = 1.0;
    [UIView commitAnimations];

}

- (void) showEndOfGamePopup {
    EndOfGameViewController *endGameVC = [[EndOfGameViewController alloc] initWithNibName:@"EndOfGameViewController" bundle:nil];
    endGameVC.delegate = self;
    endGameVC.view.alpha = 0;
    CGSize size = endGameVC.view.frame.size;
    endGameVC.view.frame = CGRectMake(self.view.frame.size.width/2 - size.width/2, self.view.frame.size.height/2 - size.height/2, size.width, size.height);
    self.endOfGameVC = endGameVC;
    [[UIApplication sharedApplication].keyWindow addSubview:self.endOfGameVC.view];

    [UIView beginAnimations:@"" context:nil];
    self.endOfGameVC.view.alpha = 1.0;
    [UIView commitAnimations];
    [endGameVC release];
    
    [[SoundEngine sharedSoundEngine] play:kSoundCodeTimeIsUp];
}

#pragma mark - Timed selectors

- (void) updateTimeProgress {
    remainingSeconds -= 1.0;
    if (remainingSeconds <= 0.0) {
        self.view.userInteractionEnabled = NO;
        [self.timer invalidate];
        [[ScoreManager sharedManager] challengeHighScore];
        [self showNewGameScreen];
        [self showEndOfGamePopup];
    } else {
        timeProgressView.progress = remainingSeconds/kGeneralTriviaSecondsToPlay;
    }
}

#pragma mark - GeneralTriviaDelegate

- (void) advanceToNextQuestion {
    if (self.currentTriviaController) {
        [self.currentTriviaController.view removeFromSuperview];
        self.currentTriviaController = nil;
    }
    int triviaType = arc4random() % triviaTypeCount;
    switch (triviaType) {
        case kTriviaTypeImage:
        {
            ImageTriviaViewController *newImageTriviaVC = [[ImageTriviaViewController alloc] initWithNibName:@"ImageTriviaViewController" bundle:nil];
            [self.view insertSubview:newImageTriviaVC.view atIndex:0];
            newImageTriviaVC.delegate = self;
            self.currentTriviaController = newImageTriviaVC;
            [newImageTriviaVC release];
        }
            break;
        case kTriviaTypeRightWrong:
        {
            RightWrongTriviaViewController *newRWTriviaVC = [[RightWrongTriviaViewController alloc] initWithNibName:@"RightWrongTriviaViewController" bundle:nil];
            [self.view insertSubview:newRWTriviaVC.view atIndex:0];
            newRWTriviaVC.delegate = self;
            self.currentTriviaController = newRWTriviaVC;
            [newRWTriviaVC release];

        }
            break;
        default:
            break;
    }
}

#pragma mark - GameFlowDelegate

- (void) newGameRequested {
    self.view.userInteractionEnabled = YES;
    [[ScoreManager sharedManager] resetScore];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeProgress) userInfo:nil repeats:YES];
    remainingSeconds = kGeneralTriviaSecondsToPlay;
    [self.timer fire];
    [self advanceToNextQuestion];
}

- (void) reEnableGeneralScreenRequested {
    self.view.userInteractionEnabled = YES;
}

@end
