#import "ViewController.h"
#import <pop/POP.h>

@interface ViewController () <SRWebSocketDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIButton *greenButton;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UIButton *purpleButton;
@property (weak, nonatomic) IBOutlet UIButton *blueButton;

@end

@implementation ViewController
{
    SRWebSocket *_webSocket;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.logoImageView.alpha = 0;
    self.welcomeLabel.alpha = 0;
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://localhost:9999/tweetstep"]]];
    _webSocket.delegate = self;
    
    self.title = @"Opening Connection...";
    [_webSocket open];
    
    POPBasicAnimation *logoFadeIn = [self fadeInAnimation];
    logoFadeIn.name = @"logoFadeIn";
    logoFadeIn.duration = 1.0;
    [self.logoImageView pop_addAnimation:logoFadeIn forKey:@"logoFadeIn"];
    [self addMoveUpAnimationForView:self.logoImageView];
}

- (IBAction)expandButton:(id)sender {
    UIButton *button = (UIButton *)sender;
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
        
        [button setTitle:@"" forState:UIControlStateNormal];
        [button pop_addAnimation:fillScreenAnimation forKey:nil];
    };
    
    [button pop_addAnimation:expandAnimation forKey:nil];
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
#pragma mark - 
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


@end
