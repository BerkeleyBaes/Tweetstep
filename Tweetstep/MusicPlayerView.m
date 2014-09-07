//
//  MusicPlayerView.m
//  Tweetstep
//
//  Created by Andrew on 9/6/14.
//  Copyright (c) 2014 CASDisrupt. All rights reserved.
//

#import "MusicPlayerView.h"

@interface MusicPlayerView()

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *icon;

@end

@implementation MusicPlayerView

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title
               icon: (UIImage *)icon
    backgroundColor: (UIColor *)color;
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
        iconView.frame = CGRectMake(self.frame.size.width / 2 - 20, 20, 40, 40);
        iconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, self.frame.size.width, 20)];
        titleLabel.text = title;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:15.0];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        self.backgroundColor = color;
        
    }
    return self;
}

-(void)enterMusicMode
{
    UIView *navBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 64)];
    navBarView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    [self addSubview:navBarView];
    
    UIButton *exitButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 31, 33, 18, 18)];
    [exitButton setBackgroundImage:[UIImage imageNamed:@"X-Button"] forState:UIControlStateNormal];
    [self addSubview:exitButton];
    
    [UIView animateWithDuration:0.4 animations:^{
        navBarView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.15];
    }];
}


@end
