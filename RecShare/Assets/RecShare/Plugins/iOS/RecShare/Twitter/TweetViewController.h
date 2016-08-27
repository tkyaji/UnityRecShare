//
//  TweetViewController.h
//  LayoutTest
//
//  Created by tkyaji on 2016/05/24.
//  Copyright © 2016年 tkyaji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TwitterApiCaller.h"
#import "TweetPresentationController.h"
#import "TwitterConfig.h"


@interface TweetViewController : UIViewController <UIViewControllerTransitioningDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButtonBarItem;
@property (weak, nonatomic) IBOutlet UIButton *accountButton;
@property (weak, nonatomic) IBOutlet UILabel *accountArrow;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *textCount;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


- (id)initWithTweet:(NSString *)tweetText videoUrl:(NSURL *)videoUrl;

- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)postButtonClicked:(id)sender;
- (IBAction)accountButtonClicked:(id)sender;

@end
