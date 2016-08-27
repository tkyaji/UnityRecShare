//
//  RecShareManager.h
//  Unity-iPhone
//
//  Created by tkyaji on 2016/05/06.
//
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <CoreImage/CoreImage.h>
#import "UnityAppController.h"
#import "DisplayManager.h"
#import "VideoCreator.h"
#import "TwitterActivity.h"


@interface RecShareManager : RenderPluginDelegate

- (void)initialize;
- (void)startRecoding;
- (void)stopRecording:(void (^)(bool ret))completion;
- (void)pauseRecording;
- (void)resumeRecording;
- (BOOL)isRecording;
- (BOOL)isPaused;
- (void)showSharingModal:(NSString *)tweetText;
- (void)showVideoPlayer;
- (NSString *)getVideoFilePath;
- (float)getVideoDuration;
- (NSData *)getScreenShotImage:(Float64)seconds;
- (void)setFrameInterval:(int)frameInterval;

- (void)setFirstImage:(UIImage *)image imageSize:(CGSize)imageSize bgColor:(UIColor *)bgColor frames:(int)frames;
- (void)setLastImage:(UIImage *)image imageSize:(CGSize)imageSize bgColor:(UIColor *)bgColor frames:(int)frames;
- (void)setOverlayImage:(UIImage *)image imageSize:(CGSize)imageSize alignment:(VideoCreatorImageAlignment)alignment;

@end
