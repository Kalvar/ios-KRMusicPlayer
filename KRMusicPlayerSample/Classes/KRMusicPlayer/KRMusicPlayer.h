//
//  KMusicPlayer.h
//  V0.8.6 Beta
//
//  Created by Kalvar on 13/7/05.
//  Copyright (c) 2013 - 2014年 Kuo-Ming Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

extern const NSString *kKRMusicPlayerAlbumIdentifier; //NSNumber
extern const NSString *kKRMusicPlayerAlbumName;       //NSString
extern const NSString *kKRMusicPlayerAlbumImage;      //UIImage
extern const NSString *kKRMusicPlayerSongerName;      //NSString
extern const NSString *kKRMusicPlayerSongIdentifier;  //NSNumber
extern const NSString *kKRMusicPlayerSongName;        //NSString

typedef void(^PlaybackChangeHandler)(BOOL stop, MPMusicPlaybackState playbackState);
typedef void(^PlayingItemChangeHandler)(NSNumber *itemPersistentId, NSUInteger songIndex);
typedef void(^VolumeChangeHandler)(CGFloat volume);
typedef void(^PlayingTimeChangeHandler)(CGFloat playingTime, NSString *timeString);

typedef enum PlaybackStates
{
    //初始狀態
    PlaybackStateNone = 0,
    //準備播放
    PlaybackStatePrepared,
    //第一首歌
    PlaybackStateBeginning,
    //下一首
    PlaybackStateNext,
    //上一首
    PlaybackStatePrevious,
    //播放
    PlaybackStatePlay,
    //停止
    PlaybackStateStop,
    //暫停
    PlaybackStatePause,
    //快轉
    PlaybackStateForward,
    //倒轉
    PlaybackStateBackward,
    //停止快倒轉
    PlaybackStateStopSeeking
}PlaybackStates;

@interface KRMusicPlayer : NSObject
{
@public
    MPMusicPlayerController *musicPlayer;
    BOOL isPlaying;
    BOOL isPause;
    BOOL isStop;
    BOOL isPlayerWoken;
    CGFloat volume;
    NSUInteger songIndex;
    PlaybackStates playbackState;
    UISlider *playbackSlider;
    MPMusicRepeatMode repeatMode;
}

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPause;
@property (nonatomic, assign) BOOL isStop;
//播放器是否已被喚醒準備好播音樂
@property (nonatomic, assign) BOOL isPlayerWoken;
@property (nonatomic, assign) CGFloat volume;
//當前歌曲是第幾首歌
@property (nonatomic, assign) NSUInteger songIndex;
@property (nonatomic, assign) PlaybackStates playbackState;
@property (nonatomic, assign) MPMusicRepeatMode repeatMode;
//音樂播放進度列
//Playback Slider
@property (nonatomic, strong) UISlider *playbackSlider;
//音樂播放進度列的重更新時間
@property (nonatomic, assign) NSTimeInterval playbackSliderRefreshInterval;

// Posted when the playback state changes, either programatically or by the user.
// 當播放狀態的變化，無論是編程或由用戶發表。
@property (nonatomic, copy) PlaybackChangeHandler playbackChangeHandler;

// Posted when the currently playing media item changes.
// 發布時，當前播放的媒體項目的變化。
@property (nonatomic, copy) PlayingItemChangeHandler playingItemChangeHandler;
@property (nonatomic, copy) PlayingItemChangeHandler startPlayCompletion;
@property (nonatomic, copy) PlayingItemChangeHandler nextSongChangeCompletion;
@property (nonatomic, copy) PlayingItemChangeHandler previousSongChangeCompletion;

// Posted when the current volume changes.
// 發布當前的音量變化。
@property (nonatomic, copy) VolumeChangeHandler volumeChangeHandler;

// 播放時間改變時
@property (nonatomic, copy) PlayingTimeChangeHandler playingTimeChangeHandler;


+(instancetype)sharedPlayer;
-(id)init;
-(void)initialize;

#pragma --mark Player
-(void)preparedToPlay;
-(void)play;
-(void)playAndKeepNotifications;
-(void)playSavedSongLists;
-(void)playSongWithPersistenId:(NSString *)_persistenId;
-(void)pause;
-(void)stop;
-(void)stopAndClearNotifications;

#pragma --mark Changes Song
-(void)nextSong;
-(void)nextSongWithCompletion:(PlayingItemChangeHandler)_completion;
-(void)previousSong;
-(void)previousSongWithCompletion:(PlayingItemChangeHandler)_completion;
-(void)turnToBegining;

#pragma --mark Gets Any Infomation
-(NSString *)getPlayingSongName;
-(NSString *)getPlayingAlbumName;
-(CGFloat)getPlayingSongDuration;
-(NSString *)getConvertedPlayingSongDuration;
-(NSString *)getConvertedPlayingSongCurrentTime;
-(NSString *)convertPlayingTime:(CGFloat)_playingTime;
-(CGFloat)getPlayingSongCurrentTime;
-(NSString *)getPlayingSonger;

#pragma --mark Saving Songs
-(BOOL)savePlaylistWithPersistentId:(NSString *)_persistenId;
-(BOOL)savePlaylistWithPersistentId:(NSString *)_persistenId songInfo:(NSDictionary *)_songInfo;
-(NSDictionary *)fetchtSavedSongLists;

#pragma --mark Playing Repeat Modes
-(void)turnOnRepeatModeForAll;
-(void)turnOnRepeatModeForOne;
-(void)turnOffRepeatMode;
-(void)turnOnRepeatModeForDefault;

#pragma --mark Playing Shuffle Modes
-(void)turnOnShuffleModeForSongs;
-(void)turnOnShuffleModeForAlbums;
-(void)turnOffShuffleMode;
-(void)turnOnShuffleModeForDefault;

#pragma --mark Playing State Methods
-(void)setCurrentSongWithSongId:(NSNumber *)_songId;
-(void)setCurrentPlaybackTime:(CGFloat)_playbackTime;
-(void)slideToPlaybackTime:(CGFloat)_playbackTime;
-(CGFloat)getCurrentPlaybackTime;
-(void)playSeekingForward;
-(void)playSeekingBackward;
-(void)stopSeeking;

#pragma --mark Playback Sliders
-(void)setPlaybackSliderParameters;
-(void)continuePlaybackSliderEvents;
-(void)removePlaybackSliderEvents;

#pragma --mark Blocks
-(void)setPlaybackChangeHandler:(PlaybackChangeHandler)_thePlaybackChangeHandler;
-(void)setPlayingItemChangeHandler:(PlayingItemChangeHandler)_thePlayingItemChangeHandler;
-(void)setNextSongChangeCompletion:(PlayingItemChangeHandler)_theNextSongChangeCompletion;
-(void)setPreviousSongChangeCompletion:(PlayingItemChangeHandler)_thePreviousSongChangeCompletion;
-(void)setVolumeChangeHandler:(VolumeChangeHandler)_theVolumeChangeHandler;
-(void)setPlayingTimeChangeHandler:(PlayingTimeChangeHandler)_thePlayingTimeChangeHandler;

@end


@interface KRMusicPlayer (PlayerFetchs)

-(void)awakePlayer;
-(NSArray *)fetchAllAlbums;
-(NSArray *)fetchAllAlbumsWithinImageSize:(CGSize)_imageSize;
-(NSArray *)fetchSongsWithQuery:(MPMediaQuery *)_query;
-(NSArray *)fetchSongsWithAlbumId:(NSNumber *)_albumId;
-(MPMediaItem *)fetchSongItemWithSongId:(NSNumber *)_songId;
-(NSDictionary *)fetchSongInfoWithSongId:(NSNumber *)_songId;
-(NSArray *)fetchAllSongs;
-(NSDictionary *)fetchAlbumInfoWithAlbumId:(NSNumber *)_albumId imageSize:(CGSize)_imageSize;
-(NSDictionary *)fetchAlbumInfoWithAlbumId:(NSNumber *)_albumId;

@end

@interface KRMusicPlayer (IdentifierConvert)

-(NSNumber *)convertAlbumIdOfString:(NSString *)_idString;

@end

@interface KRMusicPlayer (PlayerQueueQuery)

-(void)setQueueWithQuery:(MPMediaQuery *)_mediaQuery;
-(void)setQueueWithItemCollection:(MPMediaItemCollection *)_itemCollection;
-(void)setQueueWithAlbumId:(NSNumber *)_albumId;

@end


