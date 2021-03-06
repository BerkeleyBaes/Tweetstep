@import AVFoundation;
#import "SoundPlayer.h"

@interface SoundPlayer()
@property (strong, nonatomic) NSArray *audioPlayers;
@end

@implementation SoundPlayer

- (instancetype)initWithTitle:(NSString *)title
{
    NSString *audioFilePath1 = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@sound1", title] ofType:@".mp3"];
    NSString *audioFilePath2 = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@sound2", title] ofType:@".mp3"];
    NSString *audioFilePath3 = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@sound3", title] ofType:@".mp3"];
    NSString *audioFilePath4 = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@sound4", title] ofType:@".mp3"];
    NSString *audioFilePath5 = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@sound5", title] ofType:@".mp3"];
    NSArray *audioPaths = @[audioFilePath1, audioFilePath2, audioFilePath3, audioFilePath4, audioFilePath5];
    
    NSMutableArray *players = [NSMutableArray new];
    //We have to create multiple instances of AVAudioPlayer because each can only handle one audio file
    for (NSString *audioPath in audioPaths) {
        NSURL *audioPathURL = [NSURL fileURLWithPath:audioPath];
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioPathURL error:nil];
        if ([title isEqualToString:@"happy"]) {
            player.volume = 0.6;
        } else if ([title isEqualToString:@"angry"]) {
            player.volume = 0.4;
        }
        [players addObject:player];
    }
    self.audioPlayers = [players copy];
    return self;
}

- (void)playSoundForType:(SoundType)type
{
    switch (type) {
        case SoundTypeFirst: {
            [(AVAudioPlayer *)[self.audioPlayers objectAtIndex:0] play];
            break;
        }
        case SoundTypeSecond: {
            [(AVAudioPlayer *)[self.audioPlayers objectAtIndex:1] play];
            break;
        }
        case SoundTypeThird: {
            [(AVAudioPlayer *)[self.audioPlayers objectAtIndex:2] play];
            break;
        }
        case SoundTypeFourth: {
            [(AVAudioPlayer *)[self.audioPlayers objectAtIndex:3] play];
            break;
        }
        case SoundTypeFifth: {
            [(AVAudioPlayer *)[self.audioPlayers objectAtIndex:4] play];
            break;
        }
        default:
            break;
    }
}
-(void)stopAll {
    for (AVAudioPlayer *player in self.audioPlayers) {
        [player stop];
    }
}

@end
