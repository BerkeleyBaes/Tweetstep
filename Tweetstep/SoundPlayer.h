//
//  SoundPlayer.h
//  Tweetstep
//
//  Created by Steven Veshkini on 9/6/14.
//  Copyright (c) 2014 CASDisrupt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SoundType) {
    SoundTypeFirst,
    SoundTypeSecond,
    SoundTypeThird,
    SoundTypeFourth,
    SoundTypeFifth
};

@interface SoundPlayer : NSObject

- (instancetype)initWithTitle:(NSString *)title;
- (void)playSoundForType:(SoundType)type;

@end
