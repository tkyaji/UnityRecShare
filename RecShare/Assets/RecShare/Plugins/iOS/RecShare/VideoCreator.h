//
//  VideoCreator.h
//  Unity-iPhone
//
//  Created by tkyaji on 2016/06/19.
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
#import "TwitterActivity.h"


@interface VideoCreator : NSObject

typedef enum {
    VideoCreatorErrorVideoAssetEmpty,
    VideoCreatorErrorStatusError,
} VideoCreatorErrorCode;

typedef enum {
    VideoCreatorImageAlignmentTopCenter = 1,
    VideoCreatorImageAlignmentTopLeft,
    VideoCreatorImageAlignmentTopRight,
    VideoCreatorImageAlignmentBottomCenter,
    VideoCreatorImageAlignmentBottomLeft,
    VideoCreatorImageAlignmentBottomRight,
} VideoCreatorImageAlignment;


@property (nonatomic) NSString *outputFilePath;
@property (nonatomic) int fps;
@property (nonatomic) int frameCounter;

- (id)initWithOptions:(NSString *)outputFilePath fps:(int)fps;

- (void)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer frameCounter:(int)frameCounter;
- (void)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer overlayImage:(CIImage *)overlayImage overlayFrame:(CGRect)overlayFrame;
- (void)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer overlayImage:(CIImage *)overlayImage overlayFrame:(CGRect)overlayFrame frameCounter:(int)frameCounter;
- (void)initWriter:(int)width height:(int)height;
- (void)finalizeWriter:(void (^)(void))completion;
- (BOOL)isInitialized;

+ (CVPixelBufferRef)getPixelBufferFromCGImage:(CGImageRef)image imageRect:(CGRect)imageRect bgColor:(UIColor *)bgColor;

@end
