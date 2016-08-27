//
//  RecSharePlugin.mm
//  Unity-iPhone
//
//  Created by tkyaji on 2016/05/06.
//
//

#import "RecShareManager.h"

extern "C" {
    
    typedef void *_CS_RecShare_Instance;
    typedef void (*_CS_RecShare_Completion)(_CS_RecShare_Instance, bool);
    
    RecShareManager *__RecSharePlugin_getManager() {
        UnityAppController *unityAppController = (UnityAppController*)[UIApplication sharedApplication].delegate;
        if (unityAppController.renderDelegate && [unityAppController.renderDelegate isKindOfClass:[RecShareManager class]]) {
            return (RecShareManager *)unityAppController.renderDelegate;
        }
        return nil;
    }
    
    UIImage *__RecSharePlugin_getUIImage(Byte *bytes, int length) {
        NSData *data = [NSData dataWithBytes:bytes length:length];
        return [UIImage imageWithData:data];
    }
    

    void _RecSharePlugin_initialize() {
        [__RecSharePlugin_getManager() initialize];
    }
    
    void _RecSharePlugin_startRecoding() {
        [__RecSharePlugin_getManager() startRecoding];
    }
    
    void _RecSharePlugin_stopRecording(_CS_RecShare_Instance instance, _CS_RecShare_Completion completion) {
        [__RecSharePlugin_getManager() stopRecording:^(bool ret) {
            completion(instance, ret);
        }];
    }
    
    void _RecSharePlugin_pauseRecording() {
        [__RecSharePlugin_getManager() pauseRecording];
    }
    
    void _RecSharePlugin_resumeRecording() {
        [__RecSharePlugin_getManager() resumeRecording];
    }
    
    bool _RecSharePlugin_isRecording() {
        return [__RecSharePlugin_getManager() isRecording];
    }
    
    bool _RecSharePlugin_isPaused() {
        return [__RecSharePlugin_getManager() isPaused];
    }
    
    void _RecSharePlugin_showSharingModal(const char *text) {
        [__RecSharePlugin_getManager() showSharingModal:[NSString stringWithUTF8String:text]];
    }
    
    void _RecSharePlugin_showVideoPlayer() {
        [__RecSharePlugin_getManager() showVideoPlayer];
    }
    
    const char *_RecSharePlugin_getVideoFilePath() {
        NSString *path = [__RecSharePlugin_getManager() getVideoFilePath];
        const char *str = [path UTF8String];
        char* retStr = (char*)malloc(strlen(str) + 1);
        strcpy(retStr, str);
        return retStr;
    }
    
    float _RecSharePlugin_getVideoDuration() {
        return [__RecSharePlugin_getManager() getVideoDuration];
    }
    
    void _RecSharePlugin_getScreenShotImage(float seconds, Byte **byteArrPtr, int *size) {
        NSData *data = [__RecSharePlugin_getManager() getScreenShotImage:seconds];
        NSUInteger len = [data length];
        Byte *byteArr = (Byte*)malloc(len);
        memcpy(byteArr, [data bytes], len);
        
        *byteArrPtr = byteArr;
        *size = (int)len;
    }
    
    void _RecSharePlugin_setFrameInterval(int frameInterval) {
        [__RecSharePlugin_getManager() setFrameInterval:frameInterval];
    }
    
    void _RecSharePlugin_setFirstImage_data(Byte *bytes, int length, float width, float height, float r, float g, float b, float displayTime) {
        UIImage *image = __RecSharePlugin_getUIImage(bytes, length);
        UIColor *bgColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        int frames = roundf(displayTime * UnityGetTargetFPS());
        
        [__RecSharePlugin_getManager() setFirstImage:image imageSize:CGSizeMake(width, height) bgColor:bgColor frames:frames];
    }
    
    void _RecSharePlugin_setFirstImage_imageName(const char *imageName, float width, float height, float r, float g, float b, float displayTime) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithUTF8String:imageName]];
        UIColor *bgColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        int frames = roundf(displayTime * UnityGetTargetFPS());
        
        [__RecSharePlugin_getManager() setFirstImage:image imageSize:CGSizeMake(width, height) bgColor:bgColor frames:frames];
    }
    
    void _RecSharePlugin_setLastImage_data(Byte *bytes, int length, float width, float height, float r, float g, float b, float displayTime) {
        UIImage *image = __RecSharePlugin_getUIImage(bytes, length);
        UIColor *bgColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        int frames = roundf(displayTime * UnityGetTargetFPS());
        
        [__RecSharePlugin_getManager() setLastImage:image imageSize:CGSizeMake(width, height) bgColor:bgColor frames:frames];
    }
    
    void _RecSharePlugin_setLastImage_imageName(const char *imageName, float width, float height, float r, float g, float b, float displayTime) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithUTF8String:imageName]];
        UIColor *bgColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        int frames = roundf(displayTime * UnityGetTargetFPS());
        
        [__RecSharePlugin_getManager() setLastImage:image imageSize:CGSizeMake(width, height) bgColor:bgColor frames:frames];
    }
    
    void _RecSharePlugin_setOverlayImage_data(Byte *bytes, int length, float width, float height, int alignment) {
        UIImage *image = __RecSharePlugin_getUIImage(bytes, length);
        [__RecSharePlugin_getManager() setOverlayImage:image imageSize:CGSizeMake(width, height) alignment:(VideoCreatorImageAlignment)alignment];
    }
    
    void _RecSharePlugin_setOverlayImage_imageName(const char *imageName, float width, float height, int alignment) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithUTF8String:imageName]];
        [__RecSharePlugin_getManager() setOverlayImage:image imageSize:CGSizeMake(width, height) alignment:(VideoCreatorImageAlignment)alignment];
    }

}
