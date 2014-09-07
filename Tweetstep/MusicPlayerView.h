//
//  MusicPlayerView.h
//  Tweetstep
//
//  Created by Andrew on 9/6/14.
//  Copyright (c) 2014 CASDisrupt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicPlayerView : UIView

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UIView *navBarView;
@property (strong, nonatomic) UIButton *exitButton;

@property (nonatomic) CGRect originalFrame;

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title
               icon: (UIImage *)icon
    backgroundColor: (UIColor *)color;

- (void)enterMusicMode;
- (void)exitMusicMode;

@end
