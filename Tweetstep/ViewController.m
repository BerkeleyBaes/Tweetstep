@import AVFoundation;
#import <pop/POP.h>
#import <SIOSocket/SIOSocket.h>
#import "ViewController.h"
#import "MusicPlayerView.h"
#import "SoundPlayer.h"

#define kURL @"http://tweetstep.herokuapp.com"
const double kSecondsPerBeat = 0.418;

@interface ViewController () <AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) SIOSocket *webSocket;
@property (strong, nonatomic) NSDate *lastDate;

@property (strong, nonatomic) AVAudioPlayer *backgroundMusic;
@property (strong, nonatomic) SoundPlayer *melodyPlayer;
@property (strong, nonatomic) NSMutableArray *notesQueue;

@property (nonatomic) int notesCounter;
@property (nonatomic) BOOL musicMode;
@property (nonatomic) BOOL isPlaying;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.logoImageView.alpha = 0;
    self.welcomeLabel.alpha = 0;
    self.notesCounter = 0;
    self.notesQueue = [[NSMutableArray alloc]init];
    self.isPlaying = NO;
    
    [SIOSocket socketWithHost:kURL response: ^(SIOSocket *socket)
    {
        self.webSocket = socket;
        
        self.lastDate = [NSDate date];
        [self.webSocket on:@"update" callback:^(id data) {
            
            if ([data respondsToSelector:@selector(objectForKey:)]) {
                if (![data[@"keyword"] isEqualToString:@""]) {
                    double timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastDate];
                    self.lastDate = [NSDate date];
                    
                    NSDictionary *noteMap = [NSDictionary dictionaryWithObjects:@[@4,@1,@2,@3,@0] forKeys:data[@"filter"]];
                    NSNumber *indexNumber = noteMap[data[@"keyword"]];
                    NSNumber *noteValue;
                    
                    if (timeInterval <= kSecondsPerBeat/4) {
                        noteValue = [NSNumber numberWithDouble:kSecondsPerBeat/2];
                    } else if (timeInterval <= kSecondsPerBeat/2) {
                        noteValue = [NSNumber numberWithDouble:kSecondsPerBeat/2];
                    } else if (timeInterval <= kSecondsPerBeat) {
                        noteValue = [NSNumber numberWithDouble:kSecondsPerBeat];
                    } else if (timeInterval <= kSecondsPerBeat*2) {
                        noteValue = [NSNumber numberWithDouble:kSecondsPerBeat*2];
                    } else noteValue = [NSNumber numberWithDouble:kSecondsPerBeat*2];
                    
                    [self.notesQueue addObject:@{
                                                 @"keyword" : data[@"keyword"],
                                                 @"note" : indexNumber,
                                                 @"note_value" : noteValue
                                                 }];
                    
                   if (self.notesQueue.count > 2) {
                       if (self.isPlaying == NO) {
                           if (self.musicMode) {
                               [self.backgroundMusic play];
                           }
                           [self playFromQueue];
                           self.isPlaying = YES;
                       }
                   }
                }
            }

        }];
    }];
    
    POPBasicAnimation *logoFadeIn = [self fadeInAnimation];
    logoFadeIn.name = @"logoFadeIn";
    logoFadeIn.duration = 1.0;
    [self.logoImageView pop_addAnimation:logoFadeIn forKey:@"logoFadeIn"];
    [self addMoveUpAnimationForView:self.logoImageView];
    
    MusicPlayerView *greenButton = [[MusicPlayerView alloc] initWithFrame:CGRectMake(0, 368, 160, 100) title:@"Happy" icon:[UIImage imageNamed:@"HappyIcon"] backgroundColor:[UIColor colorWithRed:102.0/255.0 green:212.0/255.0 blue:88.0/255.0 alpha:1]];
    
    MusicPlayerView *redButton = [[MusicPlayerView alloc] initWithFrame:CGRectMake(160, 368, 160, 100) title:@"Sad" icon:[UIImage imageNamed:@"SadIcon"] backgroundColor:[UIColor colorWithRed:214.0/255.0 green:71.0/255.0 blue:80.0/255.0 alpha:1]];
    
    MusicPlayerView *purpleButton = [[MusicPlayerView alloc] initWithFrame:CGRectMake(0, 468, 160, 100) title:@"Angry" icon:[UIImage imageNamed:@"AngryIcon"] backgroundColor:[UIColor colorWithRed:120.0/255.0 green:93.0/255.0 blue:172.0/255.0 alpha:1]];
    
    MusicPlayerView *blueButton = [[MusicPlayerView alloc] initWithFrame:CGRectMake(160, 468, 160, 100) title:@"Chill" icon:[UIImage imageNamed:@"ChillIcon"] backgroundColor:[UIColor colorWithRed:85.0/255.0 green:172.0/255.0 blue:238.0/255.0 alpha:1]];
    
    [self.view addSubview:greenButton];
    [self.view addSubview:redButton];
    [self.view addSubview:purpleButton];
    [self.view addSubview:blueButton];
    
    UITapGestureRecognizer *musicPlayerTapGreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandMusicPlayer:)];
    UITapGestureRecognizer *musicPlayerTapRed = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandMusicPlayer:)];
    UITapGestureRecognizer *musicPlayerTapPurple = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandMusicPlayer:)];
    UITapGestureRecognizer *musicPlayerTapBlue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandMusicPlayer:)];
    
    [greenButton addGestureRecognizer:musicPlayerTapGreen];
    [redButton addGestureRecognizer:musicPlayerTapRed];
    [purpleButton addGestureRecognizer:musicPlayerTapPurple];
    [blueButton addGestureRecognizer:musicPlayerTapBlue];
    
    self.melodyPlayer = [[SoundPlayer alloc] initWithTitle:@"angry"];
}

#pragma mark - Animations


- (void)expandMusicPlayer:(UIGestureRecognizer *)sender
{
    if (!self.musicMode) {
        MusicPlayerView *button = (MusicPlayerView *) sender.view;
        [self.view bringSubviewToFront:button];
        POPBasicAnimation *expandAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
        expandAnimation.fromValue = [NSValue valueWithCGRect:button.frame];
        
        CGRect newFrame = CGRectMake(0, button.frame.origin.y, self.view.frame.size.width, button.frame.size.height);
        expandAnimation.toValue = [NSValue valueWithCGRect:newFrame];
        expandAnimation.delegate = self;
        expandAnimation.completionBlock = ^(POPAnimation *animation, BOOL finished) {
            POPBasicAnimation *fillScreenAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
            fillScreenAnimation.fromValue = [NSValue valueWithCGRect:button.frame];
            fillScreenAnimation.toValue = [NSValue valueWithCGRect:self.view.frame];
            fillScreenAnimation.completionBlock = ^(POPAnimation *animation, BOOL finished) {
                [button enterMusicMode];
                [button.exitButton addTarget:self action:@selector(collapseMusicPlayer:) forControlEvents:UIControlEventTouchUpInside];
            };
            [button pop_addAnimation:fillScreenAnimation forKey:nil];
            
            POPBasicAnimation *iconToLeftAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
            iconToLeftAnimation.fromValue = [NSValue valueWithCGRect:button.iconView.frame];
            iconToLeftAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(11, 31, 22, 22)];
            [button.iconView pop_addAnimation:iconToLeftAnimation forKey:nil];
            
            POPBasicAnimation *setNavBarTitleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
            setNavBarTitleAnimation.fromValue = [NSValue valueWithCGRect:button.titleLabel.frame];
            setNavBarTitleAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 33, button.frame.size.width, 18)];
            [button.titleLabel pop_addAnimation:setNavBarTitleAnimation forKey:nil];
            [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        };
        
        [button pop_addAnimation:expandAnimation forKey:nil];
        
        self.musicMode = YES;
        [self.webSocket emit:button.titleLabel.text.lowercaseString, nil];
        
        //CHANGE FOR SPECIFIC BUTTONS
        if ([button.titleLabel.text.lowercaseString isEqualToString:@"chill"] ||
            [button.titleLabel.text.lowercaseString isEqualToString:@"angry"] ) {
            self.melodyPlayer = [[SoundPlayer alloc] initWithTitle:@"angry"];
        } else {
            self.melodyPlayer = [[SoundPlayer alloc] initWithTitle:@"happy"];
        }
        
        self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@background", button.titleLabel.text.lowercaseString] ofType:@".mp3"]] error:nil];
        self.backgroundMusic.delegate = self;
    }
}

- (void)collapseMusicPlayer:(UIButton *)sender
{
    MusicPlayerView *button = (MusicPlayerView *) sender.superview;
    POPBasicAnimation *collapseAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    collapseAnimation.fromValue = [NSValue valueWithCGRect:button.frame];
    
    CGRect newFrame = CGRectMake(0, button.originalFrame.origin.y, 320, 100);
    collapseAnimation.toValue = [NSValue valueWithCGRect:newFrame];
    collapseAnimation.completionBlock = ^(POPAnimation *animation, BOOL finished) {
        POPBasicAnimation *squishViewAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
        squishViewAnimation.fromValue = [NSValue valueWithCGRect:button.frame];
        squishViewAnimation.toValue = [NSValue valueWithCGRect:button.originalFrame];
        squishViewAnimation.completionBlock = ^(POPAnimation *animation, BOOL finished) {
            self.musicMode = NO;
            self.isPlaying = NO;
        };
        [button pop_addAnimation:squishViewAnimation forKey:nil];
    };
    
    [button pop_addAnimation:collapseAnimation forKey:nil];
    [button exitMusicMode];
    [self.backgroundMusic stop];
    self.notesCounter = 0;
    [self.notesQueue removeAllObjects];
    [self.webSocket emit:@"stop", nil];
    
    POPBasicAnimation *iconToCenterAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    iconToCenterAnimation.fromValue = [NSValue valueWithCGRect:button.iconView.frame];
    iconToCenterAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(button.frame.size.width / 2 - 20, 20, 40, 40)];
    [button.iconView pop_addAnimation:iconToCenterAnimation forKey:nil];
    
    POPBasicAnimation *removeNavBarTitleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    removeNavBarTitleAnimation.fromValue = [NSValue valueWithCGRect:button.titleLabel.frame];
    removeNavBarTitleAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 60, button.frame.size.width, 20)];
    [button.titleLabel pop_addAnimation:removeNavBarTitleAnimation forKey:nil];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
}

- (POPBasicAnimation *)fadeOutAnimation
{
    POPBasicAnimation *fadeOutAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fadeOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    fadeOutAnimation.name = @"fadeOut";
    fadeOutAnimation.fromValue = @(1.0);
    fadeOutAnimation.toValue = @(0.0);
    fadeOutAnimation.delegate = self;
    
    return fadeOutAnimation;
}

- (void)addMoveUpAnimationForView:(UIView *)view
{
    POPBasicAnimation *moveUpAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
    moveUpAnimation.name = @"moveUpAnimation";
    moveUpAnimation.fromValue = [NSValue valueWithCGPoint:view.center];
    moveUpAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(view.center.x, view.center.y - 20)];
    moveUpAnimation.delegate = self;
    moveUpAnimation.duration = 1.0;
    
    
    [view pop_addAnimation:moveUpAnimation forKey:@"moveUpAnimation"];
}

- (POPBasicAnimation *)fadeInAnimation
{
    POPBasicAnimation *fadeInAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fadeInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    fadeInAnimation.name = @"fadeIn";
    fadeInAnimation.fromValue = @(0.0);
    fadeInAnimation.toValue = @(1.0);
    fadeInAnimation.delegate = self;
    
    return fadeInAnimation;
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished {
    if (finished) {
        if ([anim.name isEqualToString:@"logoFadeIn"]) {
            POPBasicAnimation *welcomeFadeIn = [self fadeInAnimation];
            welcomeFadeIn.name = @"welcomeFadeIn";
            welcomeFadeIn.duration = 1.0;
            [self.welcomeLabel pop_addAnimation:welcomeFadeIn forKey:@"welcomeFadeIn"];
            [self addMoveUpAnimationForView:self.welcomeLabel];
        }
    }
}


#pragma mark - Audio playing methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.backgroundMusic play];
}
-(void)playFromQueue {
    if (self.notesQueue.count == 0) {
        return;
    }
    if (self.musicMode) {
        NSDictionary *noteDictionary = self.notesQueue[self.notesCounter];
        int noteIndex = [noteDictionary[@"note"] intValue];
        [self.melodyPlayer playSoundForType:noteIndex];
        
        //Generate circles and animate them
        CGFloat size = arc4random() % 80 + 40;
        int x = arc4random() % 250 + 30;
        int y = arc4random() % 475 + 50;
        UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(x,y,size,size)];
        circleView.alpha = 0.5;
        circleView.layer.cornerRadius = size / 2;
        circleView.backgroundColor = [UIColor whiteColor];
        
        UILabel *wordLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, size, size)];
        wordLabel.textAlignment = NSTextAlignmentCenter;
        wordLabel.text = [NSString stringWithFormat:@"#%@", noteDictionary[@"keyword"]];
        wordLabel.font = [UIFont boldSystemFontOfSize:12.0];
        wordLabel.textColor = [UIColor grayColor];
        [circleView addSubview:wordLabel];
        
        [self.view addSubview:circleView];
        [UIView animateWithDuration:1.0
                         animations:^{
                             circleView.transform = CGAffineTransformMakeScale(1.5, 1.5);
                             circleView.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             [circleView removeFromSuperview];
                         }
         ];
        if (self.notesCounter < [self.notesQueue count]-1){
            self.notesCounter++;
            
        } else {
            self.notesCounter = 0;
        }
        [self performSelector:@selector(playFromQueue) withObject:nil afterDelay:[noteDictionary[@"note_value"] doubleValue]];
    }
}

@end
