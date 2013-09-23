//
//  KMusicPlayer.m
//  V0.65 Beta
//
//  Created by Kalvar on 13/7/05.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "KRMusicPlayer.h"


@interface KRMusicPlayer ()


@end

@interface KRMusicPlayer (fixPrivate)

-(void)_initWithVars;

#pragma --mark Notifcations
-(void)_registerNotifcations;
-(void)_unregisterNofications;

#pragma --mark NotificationHandlers
-(void)_didPlaybackStateChanged:(NSNotification *)notification;
-(void)_didPlayingItemChanged:(NSNotification *)notification;
-(void)_didVolumeChanged:(NSNotification *)notification;

@end

@implementation KRMusicPlayer (fixPrivate)

-(void)_initWithVars
{
    self.playbackChangeHandler    = nil;
    self.playingItemChangeHandler = nil;
    self.volumeChangeHandler      = nil;
    isPlaying = NO;
    isPause   = NO;
    isStop    = NO;
    volume    = 0.0f;
}

#pragma --mark Notifcations
-(void)_registerNotifcations
{
    dispatch_async(dispatch_get_main_queue(),^{
        [self.musicPlayer beginGeneratingPlaybackNotifications];
        NSNotificationCenter *_notificationCenter = [NSNotificationCenter defaultCenter];
        [_notificationCenter addObserver:self
                                selector:@selector(_didPlaybackStateChanged:)
                                    name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                  object:nil];
        [_notificationCenter addObserver:self
                                selector:@selector(_didPlayingItemChanged:)
                                    name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                  object:nil];
        [_notificationCenter addObserver:self
                                selector:@selector(_didVolumeChanged:)
                                    name:MPMusicPlayerControllerVolumeDidChangeNotification
                                  object:nil];
        
    });
}

-(void)_unregisterNofications
{
    dispatch_async(dispatch_get_main_queue(),^{
        NSNotificationCenter *_notificationCenter = [NSNotificationCenter defaultCenter];
        [_notificationCenter removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
        [_notificationCenter removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
        [_notificationCenter removeObserver:self name:MPMusicPlayerControllerVolumeDidChangeNotification object:nil];
        [self.musicPlayer endGeneratingPlaybackNotifications];
    });
}

#pragma --mark NotificationHandlers
-(void)_didPlaybackStateChanged:(NSNotification *)notification
{
    if( self.playbackChangeHandler )
    {
        self.playbackChangeHandler(self.isStop, self.musicPlayer.playbackState);
    }
    /*
    NSNumber *_playbackState = [notification.userInfo objectForKey:@"MPMusicPlayerControllerPlaybackStateKey"];
    switch ( [_playbackState integerValue] )
    {
        case MPMusicPlaybackStateStopped:
            
            break;
        case MPMusicPlaybackStatePlaying:
            
            break;
        case MPMusicPlaybackStatePaused:
            
            break;
        case MPMusicPlaybackStateInterrupted:
            
            break;
        case MPMusicPlaybackStateSeekingForward:
            
            break;
        case MPMusicPlaybackStateSeekingBackward:
            
            break;
        default:
            break;
    }
     */
}

-(void)_didPlayingItemChanged:(NSNotification *)notification
{
    if( self.playingItemChangeHandler )
    {
        self.playingItemChangeHandler( (NSString *)[notification.userInfo objectForKey:@"MPMusicPlayerControllerNowPlayingItemPersistentIDKey"] );
    }
}

-(void)_didVolumeChanged:(NSNotification *)notification
{
    if( self.volumeChangeHandler )
    {
        self.volumeChangeHandler(self.volume);
    }
}

@end

@implementation KRMusicPlayer

@synthesize musicPlayer = _musicPlayer;
@synthesize isPlaying   = _isPlaying;
@synthesize isPause     = _isPause;
@synthesize isStop      = _isStop;
@synthesize volume      = _volume;
@synthesize playbackChangeHandler    = _playbackChangeHandler;
@synthesize playingItemChangeHandler = _playingItemChangeHandler;
@synthesize volumeChangeHandler      = _volumeChangeHandler;


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
    if( !_musicPlayer )
    {
        _musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    }
    [self _initWithVars];
    [self _registerNotifcations];
}

#pragma --mark Player
//播放
-(void)play
{
    [_musicPlayer prepareToPlay];
    [_musicPlayer play];
}

//播放並繼續執行通知
-(void)playAndKeepNotifications
{
    [self _registerNotifcations];
    [self play];
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
    //[_musicPlayer stop];
}

//停止並清除通知
-(void)stopAndClearNotifications
{
    [self stop];
    [self _unregisterNofications];
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

//回到第 1 首歌
-(void)turnToBegining
{
    [_musicPlayer skipToBeginning];
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

-(CGFloat)volume
{
    return [_musicPlayer volume];
}

#pragma --mark Setters
//設定聲音大小 0.0 ( 靜音 ) ~ 1.0 ( 最大聲 )
-(void)setValume:(CGFloat)_theValume
{
    if( _theValume <= 0.0f )
    {
        _theValume = 0.0f;
    }
    [_musicPlayer setVolume:_theValume];
}


@end
