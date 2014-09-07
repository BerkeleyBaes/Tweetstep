#import "ViewController.h"
#import <pop/POP.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.logoImageView.alpha = 0;
    self.welcomeLabel.alpha = 0;
    
    POPBasicAnimation *logoFadeIn = [self fadeInAnimation];
    logoFadeIn.name = @"logoFadeIn";
    logoFadeIn.duration = 1.0;
    [self.logoImageView pop_addAnimation:logoFadeIn forKey:@"logoFadeIn"];
    [self addMoveUpAnimationForView:self.logoImageView];
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

@end
