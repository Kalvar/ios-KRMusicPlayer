//
//  KMusicPlayer.h
//  V0.7.0 Beta
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
    CGFloat volume;
}

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPause;
@property (nonatomic, assign) BOOL isStop;
//播放器是否已被喚醒準備好播音樂
@property (nonatomic, assign) BOOL isPlayerWoke;
@property (nonatomic, assign) CGFloat volume;

// Posted when the playback state changes, either programatically or by the user.
// 當播放狀態的變化，無論是編程或由用戶發表。
@property (nonatomic, copy) void (^playbackChangeHandler)(BOOL stop, MPMusicPlaybackState playbackState);

// Posted when the currently playing media item changes.
// 發布時，當前播放的媒體項目的變化。
@property (nonatomic, copy) void (^playingItemChangeHandler)(NSString *itemPersistentId);

// Posted when the current volume changes.
// 發布當前的音量變化。
@property (nonatomic, copy) void (^volumeChangeHandler)(CGFloat volume);


+(KRMusicPlayer *)sharedManager;
-(id)init;
-(void)initialize;

#pragma --mark Player
-(void)preparedToPlay;
-(void)play;
-(void)playAndKeepNotifications;
-(void)pause;
-(void)stop;
-(void)stopAndClearNotifications;
-(void)nextSong;
-(void)previousSong;
-(void)turnToBegining;

#pragma --mark Gets Infomation
-(NSString *)getPlayingSongName;
-(NSString *)getPlayingAlbumName;
-(CGFloat)getPlayingSongDuration;
-(CGFloat)getPlayingSongCurrentTime;
-(NSString *)getPlayingSonger;

#pragma --mark Save Songs
-(BOOL)savePlaylistWithPersistentId:(NSString *)_persistenId;
-(BOOL)savePlaylistWithPersistentId:(NSString *)_persistenId songInfo:(NSDictionary *)_songInfo;
-(void)playSavedSongLists;
-(void)playSongWithPersistenId:(NSString *)_persistenId;
-(NSDictionary *)fetchtSavedSongLists;
-(void)turnOnRepeatMode;


@end


@interface KRMusicPlayer (PlayerFetchs)

-(void)awakePlayer;
-(NSArray *)fetchAllAlbums;
-(NSArray *)fetchAllAlbumsWithinImageSize:(CGSize)_imageSize;
-(NSArray *)fetchSongsWithQuery:(MPMediaQuery *)_query;
-(NSArray *)fetchAlbumSongsWithAlbumId:(NSNumber *)_albumId;
-(NSArray *)fetchAllSongs;

@end


@interface KRMusicPlayer (PlayerQueueQuery)

-(void)setQueueWithQuery:(MPMediaQuery *)_mediaQuery;
-(void)setQueueWithItemCollection:(MPMediaItemCollection *)_itemCollection;

@end

