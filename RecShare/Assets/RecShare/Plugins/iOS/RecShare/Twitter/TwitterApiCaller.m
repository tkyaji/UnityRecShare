//
//  TwitterApiCaller.m
//  Unity-iPhone
//
//  Created by tkyaji on 2016/05/14.
//
//

#import "TwitterApiCaller.h"

#define TWITTER_UPLOAD_URL @"https://upload.twitter.com/1.1/media/upload.json"
#define TWITTER_STATUSES_URL @"https://api.twitter.com/1.1/statuses/update.json"

#define ErrorDomain @"com.tkyaji.twitterapicaller"


@implementation TwitterApiCaller


+ (void)getTwitterAccounts:(void (^)(NSArray<ACAccount *> *accountArr, NSError *error))completion {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (!granted) {
            NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
            NSString *description = @"Can't access Twitter Accounts";
            NSString *recoverySuggestion = [NSString stringWithFormat:@"Can't access Twitter Accounts. You can allow access to Twitter accounts to \"%@\" in Settings.",
                                 appName];
            NSError *error = [NSError errorWithDomain:ErrorDomain
                                                 code:TwitterApiCallerErrorCanNotAccessAccount
                                             userInfo:@{NSLocalizedDescriptionKey:description,
                                                        NSLocalizedRecoverySuggestionErrorKey:recoverySuggestion}];
            completion(nil, error);
            
        } else {
            NSArray<ACAccount *> *accountArr = [accountStore accountsWithAccountType:accountType];
            if (accountArr.count == 0) {
                NSString *description = @"No Twitter Accounts";
                NSString *recoverySuggestion = @"There are no Twitter accounts configured. You can add or create a Twitter account in Settings.";
                NSError *error = [NSError errorWithDomain:ErrorDomain
                                                     code:TwitterApiCallerErrorCanNotAccessAccount
                                                 userInfo:@{NSLocalizedDescriptionKey:description,
                                                            NSLocalizedRecoverySuggestionErrorKey:recoverySuggestion}];
                completion(nil, error);
                
            } else {
                completion(accountArr, nil);
            }
        }
    }];
}


+ (void)tweetWithVideo:(NSString *)tweetText videoUrl:(NSURL *)videoUrl account:(ACAccount *)account
            completion:(void (^)(NSError *error))completion {
    [self command_INIT:videoUrl account:account completion:^(NSString *mediaId, NSError *error) {
        [self command_APPEND:videoUrl account:account mediaId:mediaId completion:^(NSError *error) {
            [self command_FINALIZE:account mediaId:mediaId completion:^(NSError *error) {
                [self tweetWithMeidaId:account mediaId:mediaId tweetText:tweetText completion:^(NSError *error) {
                    completion(error);
                }];
            }];
        }];
    }];
}

+ (void)command_INIT:(NSURL *)videoUrl account:(ACAccount *)account completion:(void (^)(NSString *mediaId, NSError *error))completion {
    NSData *data = [NSData dataWithContentsOfURL:videoUrl];
    
    NSDictionary *postParams = @{@"command": @"INIT",
                                 @"media_type": [NSString stringWithFormat:@"video/%@", videoUrl.pathExtension],
                                 @"total_bytes": [NSString stringWithFormat:@"%@", @([data length])]
                                 };
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:TWITTER_UPLOAD_URL];
    
    [TwitterApiCaller sendPostRequest:requestUrl postParams:postParams account:account command:@"INIT" completion:
     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
         if (error) {
             completion(nil, error);
             return;
         }
         
         NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
         NSLog(@"[TwitterApiCaller] INIT response %@",responseStr);
         
         NSError *jsonError = nil;
         NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
         
         if (jsonError) {
             NSLog(@"[TwitterApiCaller] INIT error :%@",jsonError);
             completion(nil, jsonError);
             
         } else {
             NSLog(@"[TwitterApiCaller] INIT succeed %@", jsonDict);
             completion(jsonDict[@"media_id_string"], nil);
         }
     }];
}

+ (void)command_APPEND:(NSURL *)videoUrl account:(ACAccount *)account mediaId:(NSString *)mediaId completion:(void(^)(NSError *error))completion {
    NSData *data = [NSData dataWithContentsOfURL:videoUrl];
    NSArray *separatedDataArr = [TwitterApiCaller separateData:data maxLength:5242880]; // 5MB

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();

    [separatedDataArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dispatch_group_async(group,queue, ^{
            NSData *separatedData = obj;
            NSURL *requestUrl = [[NSURL alloc] initWithString:TWITTER_UPLOAD_URL];
            NSDictionary *postParams = @{@"command": @"APPEND",
                                         @"media_id": mediaId,
                                         @"media_data": [separatedData base64Encoding],
                                         @"segment_index": [NSString stringWithFormat:@"%d", (int)idx],
                                         };
            
            [TwitterApiCaller sendPostRequest:requestUrl postParams:postParams account:account command:@"APPEND" completion:
             ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                 completion(error);
             }];
        });
    }];
    
    dispatch_group_wait(group,DISPATCH_TIME_FOREVER);
}

+ (void)command_FINALIZE:(ACAccount *)account mediaId:(NSString *)mediaId completion:(void(^)(NSError *))completion {
    NSDictionary *postParams = @{@"command": @"FINALIZE",
                                 @"media_id": mediaId,
                                 };
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:TWITTER_UPLOAD_URL];
    
    [TwitterApiCaller sendPostRequest:requestUrl postParams:postParams account:account command:@"FINALIZE" completion:
     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
         completion(error);
     }];
}

+ (void)tweetWithMeidaId:(ACAccount *)account mediaId:(NSString *)mediaId tweetText:(NSString *)tweetText completion:(void(^)(NSError *error))completion {
    NSDictionary *postParams = @{@"media_ids": mediaId,
                                 @"status": tweetText,
                                 };
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:TWITTER_STATUSES_URL];

    [TwitterApiCaller sendPostRequest:requestUrl postParams:postParams account:account command:@"Tweet" completion:
     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
         completion(error);
     }];
    
}

+ (void)sendPostRequest:(NSURL *)requestUrl postParams:(NSDictionary *)postParams
                account:(ACAccount *)account command:(NSString *)command
             completion:(void (^)(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))completion {
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodPOST
                                                          URL:requestUrl parameters:postParams];
    postRequest.account = account;
    
    NSLog(@"[TwitterApiCaller] %@ request-url:%@", command, requestUrl);
    NSLog(@"[TwitterApiCaller] %@ request-params:%@", command, postParams);
    
    [postRequest performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
         NSLog(@"[TwitterApiCaller] %@ response-content:%@", command, responseData);
         NSLog(@"[TwitterApiCaller] %@ response-http:%@", command, urlResponse);
         
         if (error || !responseData) {
             if (!error) {
                 NSString *description = [NSString stringWithFormat:@"%@ command error. response data is empty.", command];
                 error = [NSError errorWithDomain:ErrorDomain
                                             code:TwitterApiCallerErrorResponseEmpty
                                         userInfo:@{NSLocalizedDescriptionKey: description}];
             }
         }
         NSLog(@"[TwitterApiCaller] %@ error:%@", command, error);
         
         completion(responseData, urlResponse, error);
     }];
}

+ (NSArray *)separateData:(NSData*)data maxLength:(NSInteger)maxLength {
    NSMutableArray<NSData *> *dataArr = [NSMutableArray<NSData *> new];
    
    NSInteger dataLength = data.length;
    
    if (dataLength <= maxLength) {
        [dataArr addObject:data];
        
    } else {
        NSRange range = NSMakeRange(0, maxLength);
        while (range.location <= dataLength) {
            [dataArr addObject:[data subdataWithRange:range]];
            
            range.location = range.location + maxLength;
            range.length = MIN(maxLength, dataLength - range.location);
        }
    }
    
    return dataArr;
}

@end
