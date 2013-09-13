//
//  KMusicPlayer.m
//  V0.5 Beta
//
//  Created by Kalvar on 13/7/05.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "KRMusicPlayer.h"


@interface KRMusicPlayer ()


@end

@implementation KRMusicPlayer

@synthesize musicPlayer = _musicPlayer;
@synthesize isPlaying   = _isPlaying;
@synthesize isPause     = _isPause;
@synthesize isStop      = _isStop;


+(KRMusicPlayer *)sharedManager
{
    static dispatch_once_t pred;
    static KRMusicPlayer *_object = nil;
    dispatch_once(&pred, ^{
        _object = [[KRMusicPlayer alloc] init];
    });
    return _object;
}

-(id)init
{
    self = [super init];
    if( self )
    {
        if( !_musicPlayer )
        {
            _musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        }
    }
    return self;
}

-(void)initialize
{
    //先在這裡宣告操控的物件
    _musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
}

//設定聲音大小 0.0 ( 靜音 ) ~ 1.0 ( 最大聲 )
-(void)setValume:(CGFloat)_valume
{
    if( _valume <= 0.0f )
    {
        _valume = 0.0f;
    }
    [_musicPlayer setVolume:_valume];
}

//播放
-(void)play
{
    [_musicPlayer prepareToPlay];
    [_musicPlayer play];
}

//暫停
-(void)pause
{
    [_musicPlayer pause];
}

//停止
-(void)stop
{
    [self pause];
    // Apple 的官方 Bug : 別用 stop，會無法再次啟動 Music.
    //[self._musicPlayer stop];
}

//下一首歌
-(void)nextSong
{
    [_musicPlayer skipToNextItem];
}

//上一首歌
-(void)previousSong
{
    [_musicPlayer skipToPreviousItem];
}

//取得正在播放歌名
-(NSString *)getPlayingSong
{
    return [_musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
}

//取得正在播放專輯
-(NSString *)getPlayingAlbum
{
    return [_musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle];
}

//取得正在播放的歌曲總播放時間長度 ( 秒 )
-(CGFloat)getPlayingSongDuration
{
    return [[_musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
}

#pragma --mark Getters
-(BOOL)isPlaying
{
    return ( [_musicPlayer playbackState] == MPMusicPlaybackStatePlaying );
}

-(BOOL)isPause
{
    return ( [_musicPlayer playbackState] == MPMusicPlaybackStatePaused );
}

-(BOOL)isStop
{
    return ( [_musicPlayer playbackState] == MPMusicPlaybackStateStopped );
}

@end
