//
//  KMusicPlayer.m
//  V0.7.0 Beta
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

@implementation KRMusicPlayer (PlayerFetchs)

//喚醒播放器
-(void)awakePlayer
{
    if( !self.isPlayerWoke )
    {
        MPMediaQuery *_songsQuery = [MPMediaQuery songsQuery];
        
        //設置播放器的歌曲佇列
        [self.musicPlayer setQueueWithQuery:_songsQuery];
        //[self.musicPlayer setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:[_songsQuery items]]];
        
        NSArray *_songs = [_songsQuery items];
        for (MPMediaItem *_eachSong in _songs)
        {
            /*
             //今天再試試這樣行不行，用這裡方法的原因，是因為 Watch 在初始選擇 Music Icon 時，手機竟然發出了極短的音樂聲 ... ( 這不對 XD )
             CGFloat _sourceValume = _musicPlayer.volume;
             //靜音喚醒
             [self setValume:0.0f];
             _musicPlayer.nowPlayingItem = _eachSong;
             [self stopMusic];
             //寫回原音量
             [self setValume:_sourceValume];
             */
            self.musicPlayer.nowPlayingItem = _eachSong;
            break;
        }
    }
}

//取得所有的專輯資訊
-(NSArray *)fetchAllAlbums
{
    return [self fetchAllAlbumsWithinImageSize:CGSizeMake(0.0f, 0.0f)];
}

//取得所有專輯資訊，並且限定專輯圖片的呎吋
-(NSArray *)fetchAllAlbumsWithinImageSize:(CGSize)_imageSize
{
    BOOL _isFullSize = ( _imageSize.width > 0.0f && _imageSize.height > 0.0f );
    NSMutableArray *_albums = [[NSMutableArray alloc] initWithCapacity:0];
    //取得全部歌曲
    MPMediaQuery *_mediaQuery = [MPMediaQuery albumsQuery];
    NSArray *_items = [_mediaQuery items];
    NSMutableDictionary *_ignores = [NSMutableDictionary dictionaryWithCapacity:0];
    for (MPMediaItem *_eachAlbum in _items)
    {
        NSNumber *_albumId = [_eachAlbum valueForProperty:MPMediaItemPropertyAlbumPersistentID];
        //已經取出過的資料就忽略
        if( [_ignores objectForKey:_albumId] )
        {
            continue;
        }
        //取得專輯圖片
        MPMediaItemArtwork *_artwork = [_eachAlbum valueForProperty:MPMediaItemPropertyArtwork];
        CGSize _theSize              = ( _isFullSize ) ? _artwork.bounds.size : _imageSize;
        UIImage *_albumFullImage     = [_artwork imageWithSize:_theSize]; //[_artwork imageWithSize:CGSizeMake(120.0f, 120.0f)];
        
        NSDictionary *_albumInfo = @{@"id"        : _albumId,
                                     @"name"      : [_eachAlbum valueForProperty:MPMediaItemPropertyAlbumTitle],
                                     @"fullImage" : _albumFullImage};
        [_albums addObject:_albumInfo];
        [_ignores setObject:_albumId forKey:_albumId];
    }
    return _albums;
}

//依照 Query 設定集合來取得所有的歌曲
-(NSArray *)fetchSongsWithQuery:(MPMediaQuery *)_query
{
    NSMutableArray *_songs = [[NSMutableArray alloc] initWithCapacity:0];
    MPMediaQuery *_mediaQuery= nil;
    //取得該 Query 底下的全部歌曲
    if( _query )
    {
        _mediaQuery = _query;
    }
    else
    {
        //取得全部歌曲
        //_mediaQuery = [[MPMediaQuery alloc] init];
        _mediaQuery = [MPMediaQuery songsQuery];
    }
    NSArray *_items = [_mediaQuery items];
    for (MPMediaItem *_eachSong in _items)
    {
        /*
         * @ 屬性說明
         *   - MPMediaItemPropertyAlbumPersistentID       : 專輯 ID       ( NSNumber, longlongValue )
         *   - MPMediaItemPropertyAlbumArtistPersistentID : 專輯的歌手 ID  ( NSNumber, longlongValue )
         */
        NSDictionary *_songInfo = @{@"songId"    : [_eachSong valueForProperty:MPMediaItemPropertyPersistentID],
                                    @"songName"  : [_eachSong valueForProperty:MPMediaItemPropertyTitle],
                                    @"songer"    : [_eachSong valueForProperty:MPMediaItemPropertyAlbumArtist],
                                    @"albumId"   : [_eachSong valueForProperty:MPMediaItemPropertyAlbumPersistentID],
                                    @"albumName" : [_eachSong valueForProperty:MPMediaItemPropertyAlbumTitle]};
        [_songs addObject:_songInfo];
    }
    return _songs;
}

//依照 Album Id 取出該 Album 底下的所有歌曲
-(NSArray *)fetchAlbumSongsWithAlbumId:(NSNumber *)_albumId
{
    MPMediaPropertyPredicate *_predicate = [MPMediaPropertyPredicate predicateWithValue:_albumId
                                                                            forProperty:MPMediaItemPropertyAlbumPersistentID];
    MPMediaQuery *_songsQuery = [MPMediaQuery songsQuery];
    [_songsQuery addFilterPredicate:_predicate];
    return [self fetchSongsWithQuery:_songsQuery];
}

//取得所有歌曲
-(NSArray *)fetchAllSongs
{
    return [self fetchSongsWithQuery:nil];
}

@end

@implementation KRMusicPlayer (PlayerQueueQuery)

//設定播放器的播放砍曲隊列，之後就能直接播放音樂曲目 ( 可參考 wakePlayer 的方法 )
-(void)setQueueWithQuery:(MPMediaQuery *)_mediaQuery
{
    [self.musicPlayer setQueueWithQuery:_mediaQuery];
}

//設定播放器的播放砍曲隊列，之後就能直接播放音樂曲目
-(void)setQueueWithItemCollection:(MPMediaItemCollection *)_itemCollection
{
    [self.musicPlayer setQueueWithItemCollection:_itemCollection];
}

@end

@implementation KRMusicPlayer

@synthesize musicPlayer  = _musicPlayer;
@synthesize isPlaying    = _isPlaying;
@synthesize isPause      = _isPause;
@synthesize isStop       = _isStop;
@synthesize isPlayerWoke = _isPlayerWoke;
@synthesize volume       = _volume;
@synthesize playbackChangeHandler    = _playbackChangeHandler;
@synthesize playingItemChangeHandler = _playingItemChangeHandler;
@synthesize volumeChangeHandler      = _volumeChangeHandler;


+(instancetype)sharedManager
{
    static dispatch_once_t pred;
    static KRMusicPlayer *_object = nil;
    dispatch_once(&pred, ^{
        _object = [[KRMusicPlayer alloc] init];
        [_object initialize];
    });
    return _object;
}

-(id)init
{
    self = [super init];
    if( self )
    {
        [self initialize];
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
    [self _unregisterNofications];
    [self _registerNotifcations];
}

#pragma --mark Player
/*
 * @ 準備播放
 *   - 當 MusicPlayer ( 音樂播放器 ) 尚未啟動準備好可以播音樂時，
 *     使用本函式即可啟動 MusicPlayer。
 */
-(void)preparedToPlay
{
    if( !_musicPlayer.isPreparedToPlay )
    {
        [_musicPlayer prepareToPlay];
    }
}

//播放
-(void)play
{
    if( !self.isPlaying )
    {
        [self preparedToPlay];
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

#pragma --mark Gets Infomation
//取得正在播放歌名
-(NSString *)getPlayingSongName
{
    return [_musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle] ? [_musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle] : @"";
}

//取得正在播放專輯
-(NSString *)getPlayingAlbumName
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
-(NSString *)getPlayingSonger
{
    return [_musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumArtist] ? [_musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumArtist] : @"";
}

#pragma --mark Save Songs
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
-(NSDictionary *)fetchtSavedSongLists
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
    _musicPlayer.repeatMode = MPMusicRepeatModeAll;
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

-(BOOL)isPlayerWoke
{
    return ( [[self getPlayingSongName] length] > 0 );
    //return ( [[self getPlayingSongName] length] > 0 && _musicPlayer.isPreparedToPlay && [self getPlayingSongDuration] > 0.0f );
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
