//
//  KMusicPlayer.h
//  V0.6.7 Beta
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
-(void)play;
-(void)playAndKeepNotifications;
-(void)pause;
-(void)stop;
-(void)stopAndClearNotifications;
-(void)nextSong;
-(void)previousSong;
-(void)turnToBegining;
-(NSString *)getPlayingSong;
-(NSString *)getPlayingAlbum;
-(CGFloat)getPlayingSongDuration;
-(BOOL)savePlaylistWithPersistentId:(NSString *)_persistenId;
-(void)playSavedSongLists;
-(NSDictionary *)getSavedSongLists;

@end
