//
//  mdp_mobile_sdk.h
//  mdp_mobile_sdk
//
//  Created by Tim Vandecasteele on 29/11/13.
//  Copyright (c) 2014 VASCO Data Security International GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MDPMobile : NSObject <UIActionSheetDelegate>

@property (nonatomic, copy) NSString *redirectUri;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *oauthEndpoint;

+ (MDPMobile *)sharedSession;

+ (void)setSharedSessionRedirectUri:(NSString *)redirectUri clientId:(NSString *)clientId;

+ (void)setSharedSessionHost:(NSString *)host;

- (void)authenticateWithState:(NSString *) state __deprecated_msg("Please use authenticateWithState:scope:andParameters: instead.");

- (void)authenticateWithState:(NSString *)state scope:(NSString*)scope andParameters:(NSDictionary *)parameters;

- (BOOL)canHandleURL:(NSURL *)url;

- (NSDictionary *)informationFromURL:(NSURL *)url;
@end
