//
//  RecShareManager.m
//  Unity-iPhone
//
//  Created by tkyaji on 2016/05/06.
//
//

#import "RecShareManager.h"
#import "CVTextureCache.h"

#define TMP_RECORDING_FILE_NAME @"RecShare_Recording.mp4"
#define TMP_COMPLETE_FILE_NAME @"RecShare_Complete.mp4"


@implementation RecShareManager {
    AVAssetWriter *_videoWriter;
    AVAssetWriterInput *_videoInput;
    AVAssetWriterInput *_audioInput;
    AVAssetWriterInputPixelBufferAdaptor *_adaptor;
    BOOL _recording;
    BOOL _recorded;
    BOOL _paused;
    int _frameInterval;
    int _tmpInterval;
    VideoCreator *_videoCreator;
    
    CVPixelBufferRef _firstImagePixelbuffer;
    int _firstImageFrames;
    CVPixelBufferRef _lastImagePixelbuffer;
    int _lastImageFrames;
    
    CIImage *_overlayImage;
    CGRect _overlayFrame;
}

- (void)initialize {
    @synchronized(self) {
        if (_videoCreator) {
            return;
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)mainDisplaySurface->cvPixelBuffer;
            int bufferW = (int)CVPixelBufferGetWidth(pixelBuffer);
            int bufferH = (int)CVPixelBufferGetHeight(pixelBuffer);
            
            if (_frameInterval <= 0) {
                _frameInterval = 1;
            }
            
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:TMP_RECORDING_FILE_NAME];
            int fps = UnityGetTargetFPS() / _frameInterval;
            _videoCreator = [[VideoCreator alloc] initWithOptions:filePath fps:fps];
            
            [_videoCreator initWriter:bufferW height:bufferH];
        });
    }
}

- (void)startRecoding {
    @synchronized(self) {
        NSLog(@"[RecShareManager] startRecoding");
        
        if (_recording) {
            NSLog(@"[RecShareManager] already started.");
            return;
        }
        
        if (!_videoCreator) {
            NSLog(@"[RecShareManager] did not initialized");
            return;
        }
        
        if (_firstImagePixelbuffer) {
            [_videoCreator appendPixelBuffer:_firstImagePixelbuffer frameCounter:_firstImageFrames];
        }

        _recording = YES;
        _recorded = NO;
        _paused = NO;
        _tmpInterval = 0;
    }
}

- (void)stopRecording:(void (^)(bool ret))completion {
    NSLog(@"[RecShareManager] stopRecording");
    
    if (!_videoCreator) {
        return;
    }
    
    _recording = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_lastImagePixelbuffer) {
            if (_lastImageFrames > 1) {
                [_videoCreator appendPixelBuffer:_lastImagePixelbuffer frameCounter:_lastImageFrames - 1];
            }
            [_videoCreator appendPixelBuffer:_lastImagePixelbuffer];
        }
        
        [_videoCreator finalizeWriter:^{
            _paused = NO;
            _recorded = YES;
            _videoCreator = nil;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self getVideoFilePath]]) {
                [[NSFileManager defaultManager] removeItemAtPath:[self getVideoFilePath] error:nil];
            }
            [[NSFileManager defaultManager] moveItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:TMP_RECORDING_FILE_NAME]
                                                    toPath:[self getVideoFilePath]
                                                     error:nil];
            [self initialize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(true);
            });
        }];
    });
}

- (void)pauseRecording {
    NSLog(@"[RecShareManager] pauseRecording");
    
    if (!_recording) {
        return;
    }
    
    _paused = YES;
}

- (void)resumeRecording {
    NSLog(@"[RecShareManager] resumeRecording");
    
    if (!_recording) {
        return;
    }
    
    _paused = NO;
}

- (BOOL)isRecording {
    return _recording;
}

- (BOOL)isPaused {
    return _paused;
}

- (void)showSharingModal:(NSString *)tweetText {
    NSLog(@"[RecShareManager] showSharingModal");
    
    if (_recording || !_recorded) {
        return;
    }
    
    NSURL *videoFileUrl = [NSURL fileURLWithPath:[self getVideoFilePath]];
    
    NSArray* actItems = @[tweetText, videoFileUrl];
    UIActivity *twitterActivity = [TwitterActivity new];
    NSArray *activities = @[twitterActivity];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:actItems applicationActivities:activities];
    activityViewController.popoverPresentationController.sourceView = UnityGetGLViewController().view;
    
    [UnityGetGLViewController() presentViewController:activityViewController animated:YES completion:nil];
}

- (NSString *)getVideoFilePath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:TMP_COMPLETE_FILE_NAME];
}

- (float)getVideoDuration {
    if (_recording || !_recorded) {
        return 0;
    }
    
    NSString *filePath = [self getVideoFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return 0.0f;
    }
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:fileUrl options:nil];
    Float64 duration = CMTimeGetSeconds([asset duration]);
    
    return (float)duration;
}

- (void)showVideoPlayer {
    NSLog(@"[RecShareManager] showVideoPlayer");
    
    NSURL *fileUrl =  [NSURL fileURLWithPath:[self getVideoFilePath]];
    AVPlayerViewController *viewController = [AVPlayerViewController new];
    viewController.player = [AVPlayer playerWithURL:fileUrl];
    [UnityGetGLViewController() presentViewController:viewController animated:YES completion:nil];
}

- (NSData *)getScreenShotImage:(Float64)seconds {
    NSURL *fileUrl =  [NSURL fileURLWithPath:[self getVideoFilePath]];
    AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:fileUrl options:nil];
    AVAssetImageGenerator *imageGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CGImageRef screenShot = [imageGen copyCGImageAtTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) actualTime:nil error:nil];
    
    return UIImagePNGRepresentation([UIImage imageWithCGImage:screenShot]);
}

- (void)setFrameInterval:(int)frameInterval {
    _frameInterval = frameInterval;
}

- (void)setFirstImage:(UIImage *)image imageSize:(CGSize)imageSize bgColor:(UIColor *)bgColor frames:(int)frames {
    CGRect center = [self getCenterRectForPixelBuffer:image size:imageSize];
    _firstImagePixelbuffer = [VideoCreator getPixelBufferFromCGImage:image.CGImage imageRect:center bgColor:bgColor];
    _firstImageFrames = frames;
}

- (void)setLastImage:(UIImage *)image imageSize:(CGSize)imageSize bgColor:(UIColor *)bgColor frames:(int)frames {
    CGRect center = [self getCenterRectForPixelBuffer:image size:imageSize];
    _lastImagePixelbuffer = [VideoCreator getPixelBufferFromCGImage:image.CGImage imageRect:center bgColor:bgColor];
    _lastImageFrames = frames;
}

- (void)setOverlayImage:(UIImage *)image imageSize:(CGSize)imageSize alignment:(VideoCreatorImageAlignment)alignment {
    CGRect center = [self getCenterRectForPixelBuffer:image size:imageSize];
    
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    screenSize.width *= screenScale;
    screenSize.height *= screenScale;
    
    center.origin.x =screenSize.width / 2 - center.size.width / 2;
    CVPixelBufferRef pixelBuffer = [VideoCreator getPixelBufferFromCGImage:image.CGImage imageRect:center bgColor:nil];
    _overlayImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];

    CGFloat offsetY = screenSize.height / 2 - center.size.height / 2;
    CGFloat offsetX = screenSize.width / 2 - center.size.width / 2;

    switch (alignment) {
        case VideoCreatorImageAlignmentTopCenter:
            _overlayFrame = CGRectMake(0, -offsetY, screenSize.width, screenSize.height);
            break;
            
        case VideoCreatorImageAlignmentTopLeft:
            _overlayFrame = CGRectMake(-offsetX, -offsetY, screenSize.width, screenSize.height);
            break;
            
        case VideoCreatorImageAlignmentTopRight:
            _overlayFrame = CGRectMake(offsetX, -offsetY, screenSize.width, screenSize.height);
            break;
            
        case VideoCreatorImageAlignmentBottomCenter:
            _overlayFrame = CGRectMake(0, offsetY, screenSize.width, screenSize.height);
            break;
            
        case VideoCreatorImageAlignmentBottomLeft:
            _overlayFrame = CGRectMake(offsetX, offsetY, screenSize.width, screenSize.height);
            break;
            
        case VideoCreatorImageAlignmentBottomRight:
            _overlayFrame = CGRectMake(-offsetX, offsetY, screenSize.width, screenSize.height);
            break;
    }
}


# pragma - RenderPluginDelegate

- (void)onBeforeMainDisplaySurfaceRecreate:(struct RenderingSurfaceParams *)params {
    params->useCVTextureCache = true;
}

- (void)onFrameResolved {
    if (!_recording || _paused) {
        return;
    }
    
    if (++_tmpInterval < _frameInterval) {
        return;
    }

    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)mainDisplaySurface->cvPixelBuffer;
    
    if (_overlayImage) {
        [_videoCreator appendPixelBuffer:pixelBuffer overlayImage:_overlayImage overlayFrame:_overlayFrame];
        
    } else {
        [_videoCreator appendPixelBuffer:pixelBuffer];
    }

    _tmpInterval = 0;
}


#pragma - Private Methods

- (CGRect)getCenterRectForPixelBuffer:(UIImage *)image size:(CGSize)size {
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    screenSize.width *= screenScale;
    screenSize.height *= screenScale;
    
    size.width *= screenScale;
    size.height *= screenScale;
    
    CGPoint point = CGPointMake(screenSize.width / 2 - size.width / 2, screenSize.height / 2 - size.height / 2);
    return CGRectMake(point.x, point.y, size.width, size.height);
}


@end
