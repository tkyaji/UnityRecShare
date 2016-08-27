//
//  TwitterActivity.m
//  Unity-iPhone
//
//  Created by tkyaji on 2016/05/16.
//
//

#import "TwitterActivity.h"


@implementation TwitterActivity {
    NSString *_tweetText;
    NSURL *_videoFileUrl;
}

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return @"com.tkyaji.TwitterActivity";
}

- (NSString *)activityTitle {
    return @"Twitter";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"twitter_icon"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (id activityItem in activityItems) {
        if (![activityItem isKindOfClass:[NSURL class]]) {
            continue;
        }
        
        NSURL *url = activityItem;
        if ([url.absoluteString hasSuffix:@".mp4"] || [url.absoluteString hasSuffix:@".mov"]) {
            AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:url options:nil];
            Float64 duration = CMTimeGetSeconds([asset duration]);
            if (duration > TWITTER_VIDEO_MAX_SEC) {
                return NO;
            }
            AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo][0];
            if (track.nominalFrameRate > TWITTER_VIDEO_MAX_FPS) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    [activityItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            _tweetText = obj;
        } else if ([obj isKindOfClass:[NSURL class]]) {
            _videoFileUrl = obj;
        }
    }];
}

- (void)performActivity {
    UIViewController *viewController = [[TweetViewController alloc] initWithTweet:_tweetText videoUrl:_videoFileUrl];
    [UnityGetGLViewController() presentViewController:viewController animated:YES completion:nil];
}


@end
