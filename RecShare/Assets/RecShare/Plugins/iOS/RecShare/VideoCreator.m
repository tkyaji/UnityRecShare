//
//  VideoCreator.m
//  Unity-iPhone
//
//  Created by tkyaji on 2016/06/19.
//
//

#import "VideoCreator.h"

#define ErrorDomain @"com.tkyaji.videocreator"
#define MAX_SIDE_LENGTH 640

@implementation VideoCreator {
    AVAssetWriter *_videoWriter;
    AVAssetWriterInput *_videoInput;
    AVAssetWriterInput *_audioInput;
    AVAssetWriterInputPixelBufferAdaptor *_adaptor;
    int _frameCount;
    CIContext *_ciContext;
}

- (id)initWithOptions:(NSString *)outputFilePath fps:(int)fps {
    if (self = [super init]) {
        self.outputFilePath = outputFilePath;
        self.fps = fps;
    }
    return self;
}

- (void)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [self appendPixelBuffer:pixelBuffer frameCounter:1];
}

- (void)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer frameCounter:(int)frameCounter {
    CMTime frameTime = CMTimeMake(_frameCount, self.fps);
    
    if (!_adaptor.assetWriterInput.readyForMoreMediaData) {
        return;
    }
    
    if (![_adaptor appendPixelBuffer:pixelBuffer withPresentationTime:frameTime]) {
        NSLog(@"[RecShareManager] AVAssetWriterInputPixelBufferAdaptor appendPixelBuffer -> failed");
    }
    
    _frameCount += frameCounter;
}

- (void)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer overlayImage:(CIImage *)overlayImage overlayFrame:(CGRect)overlayFrame {
    [self appendPixelBuffer:pixelBuffer overlayImage:overlayImage overlayFrame:overlayFrame frameCounter:1];
}

- (void)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer overlayImage:(CIImage *)overlayImage overlayFrame:(CGRect)overlayFrame frameCounter:(int)frameCounter {
    
    int bufferW = (int)CVPixelBufferGetWidth(pixelBuffer);
    int bufferH = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    CVPixelBufferRef pixelBufferCopy = NULL;
    if (CVPixelBufferCreate(kCFAllocatorDefault, bufferW, bufferH, kCVPixelFormatType_32BGRA, NULL, &pixelBufferCopy) == kCVReturnSuccess) {
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        CVPixelBufferLockBaseAddress(pixelBufferCopy, 0);
        
        uint8_t *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
        uint8_t *copyBaseAddress = CVPixelBufferGetBaseAddress(pixelBufferCopy);
        memcpy(copyBaseAddress, baseAddress, bufferH * CVPixelBufferGetBytesPerRow(pixelBuffer));
        
        [_ciContext render:overlayImage toCVPixelBuffer:pixelBufferCopy bounds:overlayFrame colorSpace:CGColorSpaceCreateDeviceRGB()];
        
        [self appendPixelBuffer:pixelBufferCopy frameCounter:frameCounter];
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        CVPixelBufferUnlockBaseAddress(pixelBufferCopy, 0);
        
        CVPixelBufferRelease(pixelBufferCopy);
        
    } else {
        [self appendPixelBuffer:pixelBuffer frameCounter:frameCounter];
    }
}

- (void)initWriter:(int)width height:(int)height {
    if (width < height) {
        width = round((double)MAX_SIDE_LENGTH / 10 / height * width) * 10;
        height = MAX_SIDE_LENGTH;
    } else {
        height = round((double)MAX_SIDE_LENGTH / 10 / width * height) * 10;
        width = MAX_SIDE_LENGTH;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.outputFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.outputFilePath error:nil];
    }
    NSURL *url = [NSURL fileURLWithPath:self.outputFilePath];
    
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeMPEG4 error:&error];
    if (error) {
        NSLog(@"[RecShareManager] %@", error.localizedDescription);
        return;
    }
    
    AVAssetWriterInput *videoInput =
    [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                       outputSettings:@{
                                                        AVVideoCodecKey : AVVideoCodecH264,
                                                        AVVideoWidthKey : @(width),
                                                        AVVideoHeightKey: @(height),
                                                        }];
    [videoWriter addInput:videoInput];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor =
    [AVAssetWriterInputPixelBufferAdaptor
     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoInput
     sourcePixelBufferAttributes:@{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
                                   (NSString *)kCVPixelBufferWidthKey: @(width),
                                   (NSString *)kCVPixelBufferHeightKey: @(height),
                                   }];
    videoInput.expectsMediaDataInRealTime = YES;
    
    // slow in the first call
    if (![videoWriter startWriting]) {
        NSLog(@"[RecShareManager] AVAssetWriter startWriting -> failed");
        return;
    }
    
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    _videoWriter = videoWriter;
    _videoInput = videoInput;
    _adaptor = adaptor;
    
    NSDictionary *contextOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO],kCIContextUseSoftwareRenderer,nil];
    _ciContext = [CIContext contextWithOptions:contextOptions];
    
    return;
}

- (void)finalizeWriter:(void (^)(void))completion {
    if (!_adaptor) {
        return;
    }
    
    [_videoInput markAsFinished];
    [_audioInput markAsFinished];
    
    CMTime frameTime = CMTimeMake(_frameCount, self.fps);
    [_videoWriter endSessionAtSourceTime:frameTime];
    
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    [_videoWriter finishWritingWithCompletionHandler:^{
        if (osVersion >= 9.0) {
            [self finalizeVars:completion];
        }
    }];
    
    CVPixelBufferPoolRelease(_adaptor.pixelBufferPool);
    
    if (osVersion < 9.0) {
        [self checkFinalizeWriter:completion];
    }
}

- (void)checkFinalizeWriter:(void (^)(void))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_videoWriter.status == AVAssetExportSessionStatusExporting || _videoWriter.status == AVAssetExportSessionStatusCompleted) {
            [self finalizeVars:completion];
        } else {
            [self checkFinalizeWriter:completion];
        }
    });
}

- (void)finalizeVars:(void (^)(void))completion {
    if (completion) {
        completion();
    }
    _adaptor = nil;
    _videoWriter = nil;
    _videoInput = nil;
    _frameCount = 0;
}

- (BOOL)isInitialized {
    return (_adaptor != nil);
}

+ (CVPixelBufferRef)getPixelBufferFromCGImage:(CGImageRef)image imageRect:(CGRect)imageRect bgColor:(UIColor *)bgColor {
    
    CGSize screenSize = [UIScreen mainScreen].nativeBounds.size;
    
    NSDictionary *options = @{(__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey: @(NO),
                              (__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @(NO)
                              };
    
    CVPixelBufferRef pixelBuffer;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, screenSize.width, screenSize.height,
                                          kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options,
                                          &pixelBuffer);
    if (status != kCVReturnSuccess) {
        return NULL;
    }
    
    [VideoCreator writeImageToPixelBuffer:image imageRect:imageRect bgColor:bgColor pixelBuffer:pixelBuffer];
    
    return pixelBuffer;
}

+ (void)writeImageToPixelBuffer:(CGImageRef)image imageRect:(CGRect)imageRect bgColor:(UIColor *)bgColor pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *data = CVPixelBufferGetBaseAddress(pixelBuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, width, height,
                                                 8, CVPixelBufferGetBytesPerRow(pixelBuffer),
                                                 rgbColorSpace, kCGImageAlphaPremultipliedFirst);
    
    if (bgColor) {
        CGContextSetFillColorWithColor(context, bgColor.CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, width, height));
    }
    
    CGContextDrawImage(context, imageRect, image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

@end
