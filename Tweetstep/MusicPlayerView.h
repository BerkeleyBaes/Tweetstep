//
//  MusicPlayerView.h
//  Tweetstep
//
//  Created by Andrew on 9/6/14.
//  Copyright (c) 2014 CASDisrupt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicPlayerView : UIView

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title
               icon: (UIImage *)icon
    backgroundColor: (UIColor *)color;

- (void)enterMusicPlayerMode;
@end
