//
//  TweetPresentationController.m
//  LayoutTest
//
//  Created by tkyaji on 2016/05/23.
//  Copyright © 2016年 tkyaji. All rights reserved.
//

#import "TweetPresentationController.h"

@implementation TweetPresentationController {
    UIView *_overlayView;
}


- (void)presentationTransitionWillBegin {
    _overlayView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    _overlayView.backgroundColor = [UIColor blackColor];
    _overlayView.alpha = 0.0f;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onOverlayTapped:)];
    [_overlayView addGestureRecognizer:recognizer];
    [self.containerView insertSubview:_overlayView atIndex:0];
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        _overlayView.alpha = 0.5f;
    } completion:nil];
    
}

- (void)onOverlayTapped:(UITapGestureRecognizer *)recognizer {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (CGRect)frameOfPresentedViewInContainerView {
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) {
        CGSize size = CGSizeMake(400.0f, 230.0f);
        return CGRectMake((self.containerView.frame.size.width - size.width) / 2.0f,
                          (self.containerView.frame.size.height - size.height) / 2.0f - 130.0f,
                          size.width, size.height);
        
    } else {
        CGSize size = CGSizeMake(self.containerView.frame.size.width - 30.0f, 230.0f);
        return CGRectMake((self.containerView.frame.size.width - size.width) / 2.0f,
                          (self.containerView.frame.size.height - size.height) / 2.0f - 110.0f,
                          size.width, size.height);
    }
}

@end
