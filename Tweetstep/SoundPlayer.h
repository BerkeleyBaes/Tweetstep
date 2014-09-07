//
//  SoundPlayer.h
//  Tweetstep
//
//  Created by Steven Veshkini on 9/6/14.
//  Copyright (c) 2014 CASDisrupt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SoundType) {
    SoundTypeFirst = 0,
    SoundTypeSecond = 1,
    SoundTypeThird = 2,
    SoundTypeFourth = 3,
    SoundTypeFifth = 4
};

@interface SoundPlayer : NSObject

- (instancetype)initWithTitle:(NSString *)title;
- (void)playSoundForType:(SoundType)type;
- (void)stopAll;

@end
