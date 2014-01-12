//
//  KMusicPlayer.m
//  V0.8.5 Beta
//
//  Created by Kalvar on 13/7/05.
//  Copyright (c) 2013 - 2014年 Kuo-Ming Lin. All rights reserved.
//

#import "KRMusicPlayer.h"

static NSString *_kKRMusicPlayerSongList = @"_kKRMusicPlayerSongList";

const NSString *kKRMusicPlayerAlbumIdentifier = @"albumId";
const NSString *kKRMusicPlayerAlbumName       = @"albumName";
const NSString *kKRMusicPlayerAlbumImage      = @"albumImage";
const NSString *kKRMusicPlayerSongerName      = @"songer";
const NSString *kKRMusicPlayerSongIdentifier  = @"songId";
const NSString *kKRMusicPlayerSongName        = @"songName";

#pragma --mark Implementation Private Methods
@interface KRMusicPlayer ()

@property (nonatomic, strong) NSTimer *_sliderTimer;
@property (nonatomic, assign) BOOL _isNextSong;

@end

@implementation KRMusicPlayer (fixMethods)

-(void)_initWithVars
{
    //Publics
    self.playbackChangeHandler         = nil;
    self.playingItemChangeHandler      = nil;
    self.startPlayCompletion           = nil;
    self.nextSongChangeCompletion      = nil;
    self.previousSongChangeCompletion  = nil;
    self.volumeChangeHandler           = nil;
    self.playingTimeChangeHandler      = nil;
    isPlaying                          = NO;
    isPause                            = NO;
    isStop                             = NO;
    volume                             = 0.0f;
    songIndex                          = -1;
    playbackState                      = PlaybackStateNone;
    self.playbackSlider                = nil;
    self.playbackSliderRefreshInterval = 1.0f;
    
    //Privates
    self._sliderTimer = nil;
    self._isNextSong  = NO;
}

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

@implementation KRMusicPlayer (fixPlaybackSlider)

//Play          => 恢復成預設並啟動 Slider Timer
//Pause / Stop  => 恢復成預設並停止 Slider Timer
//PlaySeeking   => 改成快速模式並啟動 Slider Timer ( 快轉、倒轉 )
//StopSeeking   => 恢復成預設的並啟動 Slider Timer

#pragma --mark Slider Methods
//滑動 Slider
-(void)_glideSlider
{
    if( self.playbackSlider )
    {
        //NSLog(@"_glideSlider");
        CGFloat _playbackTime     = [self getCurrentPlaybackTime];
        self.playbackSlider.value = _playbackTime;
        if( self.playingTimeChangeHandler )
        {
            self.playingTimeChangeHandler( _playbackTime, [self convertPlayingTime:_playbackTime] );
        }
    }
}

-(void)_glideSlider:(NSTimer *)_timer
{
    //NSDictionary *_userInfo = [_timer userInfo];
    [self _glideSlider];
}

#pragma --mark SliderTimer Methods
-(void)_startSliderTimer
{
    [self _stopSliderTimer];
    if( !self._sliderTimer && self.isPlaying )
    {
        [self _glideSlider];
        self._sliderTimer = [NSTimer scheduledTimerWithTimeInterval:self.playbackSliderRefreshInterval
                                                             target:self
                                                           selector:@selector(_glideSlider:)
                                                           userInfo:nil
                                                            repeats:YES];
    }
}

-(void)_continueSliderTimer
{
    [self _startSliderTimer];
}

-(void)_pauseSliderTimer
{
    if( self._sliderTimer )
    {
        [self._sliderTimer invalidate];
    }
}

-(void)_stopSliderTimer
{
    if( self._sliderTimer )
    {
        [self._sliderTimer invalidate];
        self._sliderTimer = nil;
    }
}

//將 SliderTimer 改成每 0.1 秒觸發更新並主即啟動
-(void)_startAndResetFireSliderTimerToFast
{
    self.playbackSliderRefreshInterval = 0.1f;
    [self _startSliderTimer];
}

//將 SliderTimer 改成每 1.0 秒觸發更新並立即啟動
-(void)_startAndResetFireSliderTimerToDefault
{
    self.playbackSliderRefreshInterval = 1.0f;
    [self _startSliderTimer];
}

//將 Slider 恢復成預設模式
-(void)_restoreSliderToDefault
{
    [self _stopSliderTimer];
    [self setPlaybackSliderParameters];
}

@end

@interface KRMusicPlayer (fixNotifications)

#pragma --mark Notifcations
-(void)_registerNotifcations;
-(void)_unregisterNofications;

#pragma --mark NotificationHandlers
-(void)_didPlaybackStateChanged:(NSNotification *)notification;
-(void)_didPlayingItemChanged:(NSNotification *)notification;
-(void)_didVolumeChanged:(NSNotification *)notification;

@end

@implementation KRMusicPlayer (fixNotifications)

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
    //這裡是避免 SliderTimer 沒有被啟動而設計
    if( self.playbackSlider )
    {
        if( self.isPlaying && self.playbackState == PlaybackStatePlay )
        {
            if( ![self._sliderTimer isValid] )
            {
                [self _startAndResetFireSliderTimerToDefault];
            }
        }
    }
    
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

//找出現在播放的是第幾首歌
-(NSUInteger)getCurrentSongIndex
{
    return [self.musicPlayer indexOfNowPlayingItem];
}

-(void)_didPlayingItemChanged:(NSNotification *)notification
{
    NSNumber *_songId = (NSNumber *)[notification.userInfo objectForKey:@"MPMusicPlayerControllerNowPlayingItemPersistentIDKey"];
    if( self.playingItemChangeHandler )
    {
        self.playingItemChangeHandler( _songId, self.songIndex );
    }
    
    if( self.startPlayCompletion && self.playbackState == PlaybackStatePlay )
    {
        self.startPlayCompletion( _songId, self.songIndex );
    }
    
    if( self.nextSongChangeCompletion && self.playbackState == PlaybackStateNext )
    {
        self.nextSongChangeCompletion( _songId, self.songIndex );
    }
    
    if( self.previousSongChangeCompletion && self.playbackState == PlaybackStatePrevious )
    {
        self.previousSongChangeCompletion( _songId, self.songIndex );
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

@implementation KRMusicPlayer (fixTime)

//將播放時間轉換成 00:00:00 格式
-(NSString *)_convertToFormatStringWithPlayingTime:(CGFloat)_playingTime
{
    /*
    //No need this.
    if( _playingTime < 1.0f )
    {
        //_playingTime = 0.0f;
    }
    else
    {
        //_playingTime += 0.5f;
    }
    */
    
    NSString *_formatedTotalDuration = @"";
    NSString *_convertTotalDuration  = [NSString stringWithFormat:@"%.0f", _playingTime];
    NSInteger _hours                 = 0;
    NSInteger _minutes               = [_convertTotalDuration integerValue] / 60;
    NSInteger _seconds               = [_convertTotalDuration integerValue] % 60;
    if( _minutes >= 60 )
    {
        _hours   = _minutes / 60;
        _minutes = _minutes % 60;
        _formatedTotalDuration = [NSString stringWithFormat:@"%i:%i:%i", _hours, _minutes, _seconds];
    }
    else
    {
        _formatedTotalDuration = [NSString stringWithFormat:@"%i:%i", _minutes, _seconds];
    }
    return _formatedTotalDuration;
}

@end

#pragma --mark Implementation Public Methods
@implementation KRMusicPlayer (PlayerFetchs)

//喚醒播放器
-(void)awakePlayer
{
    if( !self.isPlayerWoken )
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
    //寬高其中之一 <= 0 就代表要 Full Size 封面圖
    BOOL _isFullSize = ( _imageSize.width <= 0.0f || _imageSize.height <= 0.0f );
    NSMutableArray *_albums = [[NSMutableArray alloc] initWithCapacity:0];
    //取得全部歌曲
    MPMediaQuery *_mediaQuery     = [MPMediaQuery albumsQuery];
    NSArray *_items               = [_mediaQuery items];
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
        UIImage *_albumImage         = [_artwork imageWithSize:_theSize]; //[_artwork imageWithSize:CGSizeMake(120.0f, 120.0f)];
        NSDictionary *_albumInfo = @{kKRMusicPlayerAlbumIdentifier : _albumId,
                                     kKRMusicPlayerAlbumName       : [_eachAlbum valueForProperty:MPMediaItemPropertyAlbumTitle],
                                     kKRMusicPlayerAlbumImage      : _albumImage};
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
        NSDictionary *_songInfo = @{kKRMusicPlayerSongIdentifier  : [_eachSong valueForProperty:MPMediaItemPropertyPersistentID],
                                    kKRMusicPlayerSongName        : [_eachSong valueForProperty:MPMediaItemPropertyTitle],
                                    kKRMusicPlayerSongerName      : [_eachSong valueForProperty:MPMediaItemPropertyAlbumArtist],
                                    kKRMusicPlayerAlbumIdentifier : [_eachSong valueForProperty:MPMediaItemPropertyAlbumPersistentID],
                                    kKRMusicPlayerAlbumName       : [_eachSong valueForProperty:MPMediaItemPropertyAlbumTitle]};
        [_songs addObject:_songInfo];
    }
    return _songs;
}

//依照 Album Id 取出該 Album 底下的所有歌曲
-(NSArray *)fetchSongsWithAlbumId:(NSNumber *)_albumId
{
    MPMediaPropertyPredicate *_predicate = [MPMediaPropertyPredicate predicateWithValue:_albumId
                                                                            forProperty:MPMediaItemPropertyAlbumPersistentID];
    MPMediaQuery *_songsQuery = [MPMediaQuery songsQuery];
    [_songsQuery addFilterPredicate:_predicate];
    return [self fetchSongsWithQuery:_songsQuery];
}

//依照 Song Id 取出該 Song 的音樂 Item 物件
-(MPMediaItem *)fetchSongItemWithSongId:(NSNumber *)_songId
{
    MPMediaItem *_songItem = nil;
    MPMediaPropertyPredicate *_predicate = [MPMediaPropertyPredicate predicateWithValue:_songId
                                                                            forProperty:MPMediaItemPropertyPersistentID];
    MPMediaQuery *_songsQuery = [MPMediaQuery songsQuery];
    [_songsQuery addFilterPredicate:_predicate];
    NSArray *_items = [_songsQuery items];
    if( _items )
    {
        if( [_items count] > 0 )
        {
            _songItem = [_items firstObject];
        }
    }
    return _songItem;
}

//依照 Song Id 取得該 Song 的所有資訊
-(NSDictionary *)fetchSongInfoWithSongId:(NSNumber *)_songId
{
    NSDictionary *_songInfo = nil;
    MPMediaItem *_songItem  = [self fetchSongItemWithSongId:_songId];
    if ( _songItem )
    {
        //取得專輯圖片
        _songInfo = @{kKRMusicPlayerSongIdentifier : [_songItem valueForProperty:MPMediaItemPropertyPersistentID],
                      kKRMusicPlayerSongName       : [_songItem valueForProperty:MPMediaItemPropertyTitle],
                      kKRMusicPlayerSongerName     : [_songItem valueForProperty:MPMediaItemPropertyAlbumArtist]};
    }
    return _songInfo;
}

//取得所有歌曲
-(NSArray *)fetchAllSongs
{
    return [self fetchSongsWithQuery:nil];
}

//依照 Album ID 取出該 Album 的資訊
-(NSDictionary *)fetchAlbumInfoWithAlbumId:(NSNumber *)_albumId imageSize:(CGSize)_imageSize
{
    NSDictionary *_albumInfo = nil;
    MPMediaPropertyPredicate *_predicate = [MPMediaPropertyPredicate predicateWithValue:_albumId
                                                                            forProperty:MPMediaItemPropertyAlbumPersistentID];
    MPMediaQuery *_albumsQuery = [MPMediaQuery albumsQuery];
    [_albumsQuery addFilterPredicate:_predicate];
    NSArray *_items = [_albumsQuery items];
    for (MPMediaItem *_eachAlbum in _items)
    {
        //取得專輯圖片
        MPMediaItemArtwork *_artwork = [_eachAlbum valueForProperty:MPMediaItemPropertyArtwork];
        CGSize _theSize              = ( _imageSize.width <= 0.0f || _imageSize.height <= 0.0f ) ? _artwork.bounds.size : _imageSize;
        UIImage *_albumImage         = [_artwork imageWithSize:_theSize];
        _albumInfo = @{kKRMusicPlayerAlbumIdentifier : [_eachAlbum valueForProperty:MPMediaItemPropertyAlbumPersistentID],
                       kKRMusicPlayerAlbumName       : [_eachAlbum valueForProperty:MPMediaItemPropertyAlbumTitle],
                       kKRMusicPlayerAlbumImage      : _albumImage,
                       kKRMusicPlayerSongerName      : [_eachAlbum valueForProperty:MPMediaItemPropertyAlbumArtist]};
        break;
    }
    return _albumInfo;
}

-(NSDictionary *)fetchAlbumInfoWithAlbumId:(NSNumber *)_albumId
{
    return [self fetchAlbumInfoWithAlbumId:_albumId imageSize:CGSizeMake(0.0f, 0.0f)];
}

@end

@implementation KRMusicPlayer (IdentifierConvert)

-(NSNumber *)convertAlbumIdOfString:(NSString *)_idString
{
    NSNumber *_albumId = nil;
    if( _idString && [_idString isKindOfClass:[NSString class]] )
    {
        if( [_idString length] > 0 )
        {
            _albumId = [NSNumber numberWithLongLong:[_idString longLongValue]];
        }
    }
    return _albumId;
}

@end

@implementation KRMusicPlayer (PlayerQueueQuery)

//設定播放器的播放歌曲隊列，之後就能直接播放音樂曲目 ( 可參考 wakePlayer 的方法 )
-(void)setQueueWithQuery:(MPMediaQuery *)_mediaQuery
{
    [self.musicPlayer setQueueWithQuery:_mediaQuery];
}

//設定播放器的播放歌曲隊列，之後就能直接播放音樂曲目
-(void)setQueueWithItemCollection:(MPMediaItemCollection *)_itemCollection
{
    [self.musicPlayer setQueueWithItemCollection:_itemCollection];
}

//設定目前要播放的指定專輯
-(void)setQueueWithAlbumId:(NSNumber *)_albumId
{
    MPMediaPropertyPredicate *_predicate = [MPMediaPropertyPredicate predicateWithValue:_albumId
                                                                            forProperty:MPMediaItemPropertyAlbumPersistentID];
    MPMediaQuery *_songsQuery = [MPMediaQuery songsQuery];
    [_songsQuery addFilterPredicate:_predicate];
    [self setQueueWithQuery:_songsQuery];
}

@end

@implementation KRMusicPlayer

@synthesize musicPlayer                   = _musicPlayer;
@synthesize isPlaying                     = _isPlaying;
@synthesize isPause                       = _isPause;
@synthesize isStop                        = _isStop;
@synthesize isPlayerWoken                 = _isPlayerWoken;
@synthesize volume                        = _volume;
@synthesize songIndex                     = _songIndex;
@synthesize repeatMode                    = _repeatMode;
@synthesize playbackState                 = _playbackState;
@synthesize playbackSlider                = _playbackSlider;
@synthesize playbackSliderRefreshInterval = _playbackSliderRefreshInterval;

@synthesize playbackChangeHandler         = _playbackChangeHandler;
@synthesize playingItemChangeHandler      = _playingItemChangeHandler;
@synthesize startPlayCompletion           = _startPlayCompletion;
@synthesize nextSongChangeCompletion      = _nextSongChangeCompletion;
@synthesize previousSongChangeCompletion  = _previousSongChangeCompletion;
@synthesize volumeChangeHandler           = _volumeChangeHandler;
@synthesize playingTimeChangeHandler      = _playingTimeChangeHandler;

+(instancetype)sharedPlayer
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
        _playbackState = PlaybackStatePrepared;
        [_musicPlayer prepareToPlay];
    }
}

//播放
-(void)play
{
    if( !self.isPlaying )
    {
        [self preparedToPlay];
        _playbackState = PlaybackStatePlay;
        [_musicPlayer play];
    }
    //_playbackState = PlaybackStatePlay;
    [self setPlaybackSliderParameters];
    [self _startAndResetFireSliderTimerToDefault];
}

-(void)playWithCompletion:(PlayingItemChangeHandler)_completion
{
    _startPlayCompletion = _completion;
    [self play];
}

//播放並繼續執行通知
-(void)playAndKeepNotifications
{
    [self _registerNotifcations];
    [self play];
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

//暫停
-(void)pause
{
    _playbackState = PlaybackStatePause;
    [_musicPlayer pause];
    [self _restoreSliderToDefault];
}

//停止
-(void)stop
{
    [self pause];
    // Apple 的官方 Bug : 別用 stop，會無法再次啟動 Music.
    //_playbackState = PlaybackStateStop;
    //[_musicPlayer stop];
}

//停止並清除通知
-(void)stopAndClearNotifications
{
    [self stop];
    [self _unregisterNofications];
}

#pragma --mark Changes Song
//下一首歌
-(void)nextSong
{
    _playbackState = PlaybackStateNext;
    [_musicPlayer skipToNextItem];
    [self setPlaybackSliderParameters];
    [self _startAndResetFireSliderTimerToDefault];
}

-(void)nextSongWithCompletion:(PlayingItemChangeHandler)_completion
{
    _nextSongChangeCompletion = _completion;
    [self nextSong];
}

//上一首歌
-(void)previousSong
{
    _playbackState = PlaybackStatePrevious;
    [_musicPlayer skipToPreviousItem];
    [self setPlaybackSliderParameters];
    [self _startAndResetFireSliderTimerToDefault];
}

-(void)previousSongWithCompletion:(PlayingItemChangeHandler)_completion
{
    _previousSongChangeCompletion = _completion;
    [self previousSong];
}

//回到第 1 首歌
-(void)turnToBegining
{
    _playbackState = PlaybackStateBeginning;
    [_musicPlayer skipToBeginning];
    [self _startAndResetFireSliderTimerToDefault];
}

#pragma --mark Gets Any Infomation
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

//取得並轉換當前歌曲總播放時間
-(NSString *)getConvertedPlayingSongDuration
{
    return [self _convertToFormatStringWithPlayingTime:[self getPlayingSongDuration]];
}

//取得並轉換當前歌曲目前播放時間
-(NSString *)getConvertedPlayingSongCurrentTime
{
    return [self _convertToFormatStringWithPlayingTime:[self getCurrentPlaybackTime]];
}

-(NSString *)convertPlayingTime:(CGFloat)_playingTime
{
    return [self _convertToFormatStringWithPlayingTime:_playingTime];
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

#pragma --mark Saving Songs
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

#pragma --mark Playing Repeat Modes
//開啟歌曲全循環模式
-(void)turnOnRepeatModeForAll
{
    _musicPlayer.repeatMode = MPMusicRepeatModeAll;
}

//開啟歌曲單首循環模式
-(void)turnOnRepeatModeForOne
{
    _musicPlayer.repeatMode = MPMusicRepeatModeOne;
}

//歌曲不循環
-(void)turnOffRepeatMode
{
    _musicPlayer.repeatMode = MPMusicRepeatModeNone;
}

//恢復成 iOS 系統判斷 User 原先喜好的循環模式
-(void)turnOnRepeatModeForDefault
{
    _musicPlayer.repeatMode = MPMusicRepeatModeDefault;
}

#pragma --mark Playing Shuffle Modes
//依照歌曲隨機播放
-(void)turnOnShuffleModeForSongs
{
    _musicPlayer.shuffleMode = MPMusicShuffleModeSongs;
}

//依照專輯隨機播放
-(void)turnOnShuffleModeForAlbums
{
    _musicPlayer.shuffleMode = MPMusicShuffleModeAlbums;
}

//關閉隨機播放模式
-(void)turnOffShuffleMode
{
    _musicPlayer.shuffleMode = MPMusicShuffleModeOff;
}

//恢復成 iOS 系統判斷 User 原先喜好的隨機模式
-(void)turnOnShuffleModeForDefault
{
    _musicPlayer.shuffleMode = MPMusicShuffleModeDefault;
}

#pragma --mark Playing State Methods
//依照 Song Id 設為當前準備播放的歌曲
-(void)setCurrentSongWithSongId:(NSNumber *)_songId
{
    self.musicPlayer.nowPlayingItem = [self fetchSongItemWithSongId:_songId];
}

-(void)setCurrentPlaybackTime:(CGFloat)_playbackTime
{
    if( _playbackTime >= 0.0f )
    {
        [_musicPlayer setCurrentPlaybackTime:_playbackTime];
    }
    if( _playingTimeChangeHandler )
    {
        _playingTimeChangeHandler( _playbackTime, [self convertPlayingTime:_playbackTime] );
    }
}

//跳至 x 秒處開始播放
-(void)slideToPlaybackTime:(CGFloat)_playbackTime
{
    [self setCurrentPlaybackTime:_playbackTime];
}

//取得現在播放到哪一秒
-(CGFloat)getCurrentPlaybackTime
{
    return _musicPlayer.currentPlaybackTime;
}

-(void)playSeekingForward
{
    _playbackState = PlaybackStateForward;
    //邊快轉邊播放
    [_musicPlayer beginSeekingForward];
    [self _startAndResetFireSliderTimerToFast];
}

-(void)playSeekingBackward
{
    _playbackState = PlaybackStateBackward;
    //邊倒轉邊播放
    [_musicPlayer beginSeekingBackward];
    [self _startAndResetFireSliderTimerToFast];
}

-(void)stopSeeking
{
    _playbackState = PlaybackStateStopSeeking;
    //停止快倒轉
    [_musicPlayer endSeeking];
    [self _startAndResetFireSliderTimerToDefault];
}

#pragma --mark Playback Sliders
//設定 PlaybackSlider 的參數值
-(void)setPlaybackSliderParameters
{
    if( _playbackSlider )
    {
        CGFloat _playingTime         = [self getCurrentPlaybackTime];
        _playbackSlider.minimumValue = 0.0f;
        _playbackSlider.maximumValue = [self getPlayingSongDuration];
        _playbackSlider.value        = _playingTime;
        if( _playingTimeChangeHandler )
        {
            _playingTimeChangeHandler( _playingTime, [self convertPlayingTime:_playingTime] );
        }
    }
}

//繼續執行 PlaybackSlider 的事件
-(void)continuePlaybackSliderEvents
{
    [self _startAndResetFireSliderTimerToDefault];
}

//移除所有關於 PlaybackSlider 的事件
-(void)removePlaybackSliderEvents
{
    [self _stopSliderTimer];
}

#pragma --mark Blocks
-(void)setPlaybackChangeHandler:(PlaybackChangeHandler)_thePlaybackChangeHandler
{
    _playbackChangeHandler = _thePlaybackChangeHandler;
}

-(void)setPlayingItemChangeHandler:(PlayingItemChangeHandler)_thePlayingItemChangeHandler
{
    _playingItemChangeHandler = _thePlayingItemChangeHandler;
}

-(void)setNextSongChangeCompletion:(PlayingItemChangeHandler)_theNextSongChangeCompletion
{
    _nextSongChangeCompletion = _theNextSongChangeCompletion;
}

-(void)setPreviousSongChangeCompletion:(PlayingItemChangeHandler)_thePreviousSongChangeCompletion
{
    _previousSongChangeCompletion = _thePreviousSongChangeCompletion;
}

-(void)setVolumeChangeHandler:(VolumeChangeHandler)_theVolumeChangeHandler
{
    _volumeChangeHandler = _theVolumeChangeHandler;
}

-(void)setPlayingTimeChangeHandler:(PlayingTimeChangeHandler)_thePlayingTimeChangeHandler
{
    _playingTimeChangeHandler = _thePlayingTimeChangeHandler;
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

-(BOOL)isPlayerWoken
{
    return ( [[self getPlayingSongName] length] > 0 );
    //return ( [[self getPlayingSongName] length] > 0 && _musicPlayer.isPreparedToPlay && [self getPlayingSongDuration] > 0.0f );
}

-(CGFloat)volume
{
    return [_musicPlayer volume];
}

-(NSUInteger)songIndex
{
    return [_musicPlayer indexOfNowPlayingItem];
}

-(MPMusicRepeatMode)repeatMode
{
    return _musicPlayer.repeatMode;
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

-(void)setPlaybackSlider:(UISlider *)_thePlaybackSlider
{
    _playbackSlider = _thePlaybackSlider;
    [self setPlaybackSliderParameters];
}


@end
