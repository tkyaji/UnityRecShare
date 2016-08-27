//
//  RecShareAppController.m
//  Unity-iPhone
//
//  Created by tkyaji on 2016/05/06.
//
//

#import "RecShareAppController.h"

@implementation RecShareAppController

- (void)shouldAttachRenderDelegate {
    self.renderDelegate = [RecShareManager new];
}


@end

IMPL_APP_CONTROLLER_SUBCLASS(RecShareAppController)
