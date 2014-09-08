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
