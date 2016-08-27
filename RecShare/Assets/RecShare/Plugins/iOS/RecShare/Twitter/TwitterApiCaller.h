//
//  TwitterApiCaller.h
//  Unity-iPhone
//
//  Created by tkyaji on 2016/05/14.
//
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface TwitterApiCaller : NSObject

typedef enum {
    TwitterApiCallerErrorResponseEmpty,
    TwitterApiCallerErrorDoesNotGrantAccess,
    TwitterApiCallerErrorCanNotAccessAccount,
    TwitterApiCallerErrorNoAccount,
} TwitterApiCallerErrorCode;


+ (void)getTwitterAccounts:(void (^)(NSArray<ACAccount *> *accountArr, NSError *error))completion;

+ (void)tweetWithVideo:(NSString *)tweetText videoUrl:(NSURL *)videoUrl account:(ACAccount *)account
            completion:(void (^)(NSError *error))completion;

@end
