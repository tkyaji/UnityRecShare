//
//  TweetViewController.m
//  LayoutTest
//
//  Created by tkyaji on 2016/05/24.
//  Copyright © 2016年 tkyaji. All rights reserved.
//

#import "TweetViewController.h"

#define USER_DEFAULT_KEY_SELECTED_ACCOUNT @"twitter_selected_account"

@implementation TweetViewController {
    NSArray<ACAccount *> *_accountArr;
    Float64 _videoDuration;
    CGImageRef _screenShot;
    NSString *_tweetText;
    NSURL *_videoUrl;
}

- (id)init {
    self = [super init];
    
    self.modalTransitionStyle = UIModalPresentationCustom;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    
    return self;
}

- (id)initWithTweet:(NSString *)tweetText videoUrl:(NSURL *)videoUrl {
    _videoUrl = videoUrl;
    _tweetText = tweetText;
    
    AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetImageGenerator *imageGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    _videoDuration = CMTimeGetSeconds([asset duration]);
    _screenShot = [imageGen copyCGImageAtTime:CMTimeMakeWithSeconds(0.0, NSEC_PER_SEC) actualTime:nil error:nil];

    return [self init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.postButtonBarItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0f]} forState:UIControlStateNormal];
    
    [self.textView becomeFirstResponder];
    [self.textView setText:_tweetText];
    [self.textView setDelegate:self];
    
    [self setTweetTextCount];
    
    int tm = (int)_videoDuration;
    [self.timeLabel setText:[NSString stringWithFormat:@"%d:%02d", (tm / 60), (tm % 60)]];
    
    [self.imageView setImage:[UIImage imageWithCGImage:_screenShot]];
    
    [TwitterApiCaller getTwitterAccounts:^(NSArray<ACAccount *> *accountArr, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentAccountAlert:error.localizedDescription message:error.localizedRecoverySuggestion completion:^(BOOL isCanceled) {
                    [self dismissViewControllerAnimated:isCanceled completion:nil];
                }];
            });
            
        } else {
            _accountArr = accountArr;
            ACAccount *account = [self selectAccount:accountArr];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.accountButton setTitle:account.username forState:UIControlStateNormal];
                [self.postButtonBarItem setEnabled:YES];
                if (accountArr.count > 1) {
                    [self.accountButton setEnabled:YES];
                    [self.accountArrow setHidden:NO];
                }
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)presentAccountAlert:(NSString *)title message:(NSString *)message completion:(void (^)(BOOL isCanceled))completion {
    UIAlertController * alertController =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Settings"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
                                                          completion(NO);
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completion(YES);
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (ACAccount *)selectAccount:(NSArray<ACAccount *> *)accountArr {
    NSString *selectedAccountName = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULT_KEY_SELECTED_ACCOUNT];
    
    for (ACAccount *ac in accountArr) {
        if ([ac.username isEqualToString:selectedAccountName]) {
            return ac;
        }
    }
    
    return accountArr[0];
}

- (void)presentSelectAccountAlert:(NSArray<ACAccount *> *)accountArr {
    UIAlertController * alertController =
    [UIAlertController alertControllerWithTitle:@"Select Account"
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (ACAccount *ac in accountArr) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"@%@", ac.username]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [self.accountButton setTitle:ac.username forState:UIControlStateNormal];
                                                           [[NSUserDefaults standardUserDefaults] setObject:ac.username forKey:USER_DEFAULT_KEY_SELECTED_ACCOUNT];
                                                       }];
        [alertController addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                         }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setTweetTextCount {
    NSInteger len = TWITTER_TEXT_MAX_LENGTH - self.textView.text.length;
    if (len < 0) {
        [self.textCount setTextColor:[UIColor redColor]];
    } else {
        [self.textCount setTextColor:[UIColor lightGrayColor]];
    }
    [self.textCount setText:@(len).stringValue];
}


#pragma mark - IBAction

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonClicked:(id)sender {
    ACAccount *account = [self selectAccount:_accountArr];
    [TwitterApiCaller tweetWithVideo:self.textView.text videoUrl:_videoUrl account:account completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"[RecShareManager] Tweet Error : %@", error);
            }
        });
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)accountButtonClicked:(id)sender {
    [self presentSelectAccountAlert:_accountArr];
}



#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source {
    return [[TweetPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self setTweetTextCount];
}


@end
