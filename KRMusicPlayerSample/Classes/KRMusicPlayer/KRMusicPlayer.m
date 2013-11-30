//
//  KMusicPlayer.m
//  V0.6.7 Beta
//
//  Created by Kalvar on 13/7/05.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "KRMusicPlayer.h"

static NSString *_kKRMusicPlayerSongList = @"_kKRMusicPlayerSongList";


@interface KRMusicPlayer ()


@end

@implementation KRMusicPlayer (fixDefaults)

#pragma --mark Gets NSDefault Values
/*
 * @ 取出萬用型態
 */
-(id)_defaultValueForKey:(NSString *)_key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:_key];
}

/*
 * @ 取出 String
 */
-(NSString *)_defaultStringValueForKey:(NSString *)_key
{
    return [NSString stringWithFormat:@"%@", [self _defaultValueForKey:_key]];
}

/*
 * @ 取出 BOOL
 */
-(BOOL)_defaultBoolValueForKey:(NSString *)_key
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:_key];
}

#pragma --mark Saves NSDefault Values
/*
 * @ 儲存萬用型態
 */
-(void)_saveDefaultValue:(id)_value forKey:(NSString *)_forKey
{
    [[NSUserDefaults standardUserDefaults] setObject:_value forKey:_forKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 * @ 儲存 String
 */
-(void)_saveDefaultValueForString:(NSString *)_value forKey:(NSString *)_forKey
{
    [self _saveDefaultValue:_value forKey:_forKey];
}

/*
 * @ 儲存 BOOL
 */
-(void)_saveDefaultValueForBool:(BOOL)_value forKey:(NSString *)_forKey
{
    [self _saveDefaultValue:[NSNumber numberWithBool:_value] forKey:_forKey];
}

#pragma --mark Removes NSDefault Values
-(void)_removeDefaultValueForKey:(NSString *)_key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:_key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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
    if( !self.isPlaying )
    {
        [_musicPlayer prepareToPlay];
        [_musicPlayer play];
    }
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
    return [_musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle] ? [_musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle] : @"";
}

//取得正在播放專輯
-(NSString *)getPlayingAlbum
{
    return [_musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle] ? [_musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle] : @"";
}

//取得正在播放的歌曲總播放時間長度 ( 歌曲長度 ; 秒 )
-(CGFloat)getPlayingSongDuration
{
    return [[_musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
}

//取得當前歌曲目前正播放到第幾秒的位置
-(CGFloat)getPlayingSongCurrentTime
{
    return _musicPlayer.currentPlaybackTime ? _musicPlayer.currentPlaybackTime : 0.0f;
}

//取得演唱者
-(NSString *)getSonger
{
    return [_musicPlayer.nowPlayingItem valueForKey:MPMediaItemPropertyAlbumArtist] ? [_musicPlayer.nowPlayingItem valueForKey:MPMediaItemPropertyAlbumArtist] : @"";
}

//儲存歌曲
-(BOOL)savePlaylistWithPersistentId:(NSString *)_persistenId
{
    return [self savePlaylistWithPersistentId:_persistenId songInfo:nil];
}

//儲存歌曲與自訂的 Info
-(BOOL)savePlaylistWithPersistentId:(NSString *)_persistenId songInfo:(NSDictionary *)_songInfo
{
    NSData *_playListsData          = [self _defaultValueForKey:_kKRMusicPlayerSongList];
    NSMutableDictionary *_playLists = [NSMutableDictionary dictionaryWithCapacity:0];
    if( _playListsData )
    {
        _playLists = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:_playListsData];
        if( [_playLists objectForKey:_persistenId] )
        {
            return NO;
        }
    }
    if( _songInfo )
    {
        [_playLists setObject:_songInfo forKey:_persistenId];
    }
    else
    {
        [_playLists setObject:[NSNumber numberWithLongLong:[_persistenId longLongValue]] forKey:_persistenId];
    }
    NSData *_archivedData = [NSKeyedArchiver archivedDataWithRootObject:_playLists];
    [self _saveDefaultValue:_archivedData forKey:_kKRMusicPlayerSongList];
    return YES;
}

//播放儲存的歌曲列表
-(void)playSavedSongLists
{
    NSData *_playListsData = [self _defaultValueForKey:_kKRMusicPlayerSongList];
    if( _playListsData )
    {
        NSMutableDictionary *_playLists = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:_playListsData];
        //NSLog(@"_playLists : %@", _playLists);
        NSMutableArray *_songs          = [[NSMutableArray alloc] initWithCapacity:0];
        [_playLists enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {
            NSNumber *_persistenId   = (NSNumber *)key;
            //NSLog(@"_persistenId : %@", _persistenId);
            MPMediaQuery *_songQuery = [MPMediaQuery songsQuery];
            [_songQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:_persistenId
                                                                            forProperty:MPMediaItemPropertyPersistentID]];
            [_songs addObjectsFromArray:[_songQuery items]];
        }];
        //NSLog(@"_songs : %@\n\n", _songs);
        MPMediaItemCollection *_currentItemCollection = [[MPMediaItemCollection alloc] initWithItems:_songs];
        [self.musicPlayer setQueueWithItemCollection:_currentItemCollection];
        [self stop];
        [self play];
    }
}

//依照歌曲 ID 播放歌曲
-(void)playSongWithPersistenId:(NSString *)_persistenId
{
    MPMediaQuery *_songQuery = [MPMediaQuery songsQuery];
    [_songQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:(NSNumber *)_persistenId
                                                                    forProperty:MPMediaItemPropertyPersistentID]];
    MPMediaItemCollection *_currentItemCollection = [[MPMediaItemCollection alloc] initWithItems:@[[_songQuery items]]];
    [self.musicPlayer setQueueWithItemCollection:_currentItemCollection];
    [self stop];
    [self play];
}

//取得儲存的歌曲列表
-(NSDictionary *)getSavedSongLists
{
    NSData *_playListsData = [self _defaultValueForKey:_kKRMusicPlayerSongList];
    if( _playListsData )
    {
        return (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:_playListsData];
    }
    return nil;
}

//開啟歌曲循環模式
-(void)turnOnRepeatMode
{
    self.musicPlayer.repeatMode = MPMusicRepeatModeAll;
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
