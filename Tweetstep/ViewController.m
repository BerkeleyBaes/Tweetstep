#import <pop/POP.h>
#import <SocketRocket/SRWebSocket.h>
#import "ViewController.h"
#import "MusicPlayerView.h"

@interface ViewController () <SRWebSocketDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) SRWebSocket *webSocket;

@property (nonatomic) BOOL musicMode;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.logoImageView.alpha = 0;
    self.welcomeLabel.alpha = 0;
    
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://localhost:9999/tweetstep"]]];
    self.webSocket.delegate = self;
    
    self.title = @"Opening Connection...";
    [self.webSocket open];
    
    POPBasicAnimation *logoFadeIn = [self fadeInAnimation];
    logoFadeIn.name = @"logoFadeIn";
    logoFadeIn.duration = 1.0;
    [self.logoImageView pop_addAnimation:logoFadeIn forKey:@"logoFadeIn"];
    [self addMoveUpAnimationForView:self.logoImageView];
    
    
    MusicPlayerView *greenButton = [[MusicPlayerView alloc] initWithFrame:CGRectMake(0, 368, 160, 100) title:@"Moods" icon:[UIImage imageNamed:@"MoodIcon"] backgroundColor:[UIColor colorWithRed:102.0/255.0 green:212.0/255.0 blue:88.0/255.0 alpha:1]];
    
    MusicPlayerView *redButton = [[MusicPlayerView alloc] initWithFrame:CGRectMake(160, 368, 160, 100) title:@"Moods" icon:[UIImage imageNamed:@"MoodIcon"] backgroundColor:[UIColor colorWithRed:214.0/255.0 green:71.0/255.0 blue:80.0/255.0 alpha:1]];
    
    MusicPlayerView *purpleButton = [[MusicPlayerView alloc] initWithFrame:CGRectMake(0, 468, 160, 100) title:@"Moods" icon:[UIImage imageNamed:@"MoodIcon"] backgroundColor:[UIColor colorWithRed:120.0/255.0 green:93.0/255.0 blue:172.0/255.0 alpha:1]];
    
    MusicPlayerView *blueButton = [[MusicPlayerView alloc] initWithFrame:CGRectMake(160, 468, 160, 100) title:@"Moods" icon:[UIImage imageNamed:@"MoodIcon"] backgroundColor:[UIColor colorWithRed:85.0/255.0 green:172.0/255.0 blue:238.0/255.0 alpha:1]];
    
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
    
}

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
        };
        [button pop_addAnimation:squishViewAnimation forKey:nil];
    };
    
    [button pop_addAnimation:collapseAnimation forKey:nil];
    [button exitMusicMode];
    
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


#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Websocket Connected");
    self.title = @"Connected!";
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    
    self.title = @"Connection Failed! (see logs)";
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"Received \"%@\"", message);
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *messageDict = [NSJSONSerialization JSONObjectWithData:messageData options:NSJSONReadingAllowFragments error:&error];
    self.welcomeLabel.text = messageDict[@"text"];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    self.title = @"Connection Closed! (see logs)";
    _webSocket = nil;
}

#pragma mark - Animations
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

- (BOOL)musicMode {
    if (!_musicMode) { _musicMode = NO; }
    return _musicMode;
}

@end
