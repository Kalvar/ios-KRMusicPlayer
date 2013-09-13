//
//  KMusicPlayer.h
//  V0.5 Beta
//
//  Created by Kalvar on 13/7/05.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface KRMusicPlayer : NSObject
{
    MPMusicPlayerController *musicPlayer;
    BOOL isPlaying;
    BOOL isPause;
    BOOL isStop;
}

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPause;
@property (nonatomic, assign) BOOL isStop;


+(KRMusicPlayer *)sharedManager;
-(id)init;
-(void)initialize;
-(void)setValume:(CGFloat)_valume;
-(void)play;
-(void)pause;
-(void)stop;
-(void)nextSong;
-(void)previousSong;
-(NSString *)getPlayingSong;
-(NSString *)getPlayingAlbum;
-(CGFloat)getPlayingSongDuration;


@end
