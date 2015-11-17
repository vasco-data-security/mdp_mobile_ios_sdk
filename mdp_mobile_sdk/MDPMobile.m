//
//  mdp_mobile_sdk.m
//  mdp_mobile_sdk
//
//  Created by Tim Vandecasteele on 29/11/13.
//  Copyright (c) 2014 VASCO Data Security International GmbH. All rights reserved.
//

#import "MDPMobile.h"
#import <UIKit/UIKit.h>
#import "NSDictionary+UrlEncoding.h"

#define MDPHOST @"https://www.mydigipass.com/oauth/authenticate.html"

@implementation MDPMobile {
    NSString *mydigipassUrlString;
}

@synthesize redirectUri = _redirectUri;
@synthesize clientId = _clientId;
@synthesize oauthEndpoint = _oauthEndpoint;

+ (MDPMobile *)sharedSession
{
    static MDPMobile *_sharedSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSession = [[MDPMobile alloc] init];
    });

    return _sharedSession;
}

+ (void)setSharedSessionRedirectUri:(NSString *)redirectUri clientId:(NSString *)clientId
{
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:redirectUri]]) {
        [NSException raise:@"Invalid Redirect Uri" format:@"The redirect uri %@ is not registered.", redirectUri];
    }

    MDPMobile *session = [self sharedSession];
    session.redirectUri = redirectUri;
    session.clientId = clientId;
    session.oauthEndpoint = MDPHOST;
}

+ (void)setSharedSessionHost:(NSString *)host
{
    [self sharedSession].oauthEndpoint = host;
}

- (void)authenticateWithState:(NSString *) state
{
    if ([self isMdpInstalled]) {
        // Authenticate with MDP-app
        mydigipassUrlString = @"mydigipass-oauth://x-callback-url/2.0/authenticate?x-success=";
    } else {
        // Authenticate through browser
        mydigipassUrlString = [NSString stringWithFormat:@"%@%@", _oauthEndpoint, @"?response_type=code&redirect_uri="];
    }

    mydigipassUrlString = [mydigipassUrlString stringByAppendingString:[self encodeString:_redirectUri]];
    mydigipassUrlString = [mydigipassUrlString stringByAppendingString:@"&"];

    mydigipassUrlString = [mydigipassUrlString stringByAppendingString:@"client_id="];
    mydigipassUrlString = [mydigipassUrlString stringByAppendingString:[self encodeString:_clientId]];
    mydigipassUrlString = [mydigipassUrlString stringByAppendingString:@"&"];

    mydigipassUrlString = [mydigipassUrlString stringByAppendingString:@"state="];
    mydigipassUrlString = [mydigipassUrlString stringByAppendingString:[self encodeString:state]];

    if ([self isMdpInstalled]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mydigipassUrlString]];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:LocalizedString(@"CANCEL", @"cancel")
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:LocalizedString(@"INSTALL_APP", @"Install MYDIGIPASS"), LocalizedString(@"LOGIN_WITH_BROWSER", @"Login via browser"), nil];
        [actionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
    }
}


- (void)authenticateWithState:(NSString *)state scope:(NSString*)scope andParameters:(NSDictionary *)parameters
{

    if (state == nil || [state isEqualToString:@""]) {
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                         reason:@"The usage of the state parameter is mandatory for CSRF prevention."
                                                       userInfo:nil];
        [exception raise];
    }

    NSMutableDictionary *oauthParameters;
    if(parameters) {
        oauthParameters = [[NSDictionary dictionaryWithDictionary:parameters] mutableCopy];
    } else {
        oauthParameters = [@{} mutableCopy];
    }

    oauthParameters[@"client_id"] = _clientId;
    oauthParameters[@"state"] = state;

    if(scope) {
        oauthParameters[@"scope"] = scope;
    }

    if ([self isMdpInstalled]) { // Authenticate with MDP-app
        oauthParameters[@"x-success"] = _redirectUri;
        mydigipassUrlString = [NSDictionary addQueryStringToUrlString:@"mydigipass-oauth://x-callback-url/2.0/authenticate" withDictionary:oauthParameters];
    } else { // Authenticate through browser
        oauthParameters[@"redirect_uri"] = _redirectUri;
        oauthParameters[@"response_type"] = @"code";
        mydigipassUrlString = [NSDictionary addQueryStringToUrlString:_oauthEndpoint withDictionary:oauthParameters];
    }

    if ([self isMdpInstalled]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mydigipassUrlString]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/mydigipass.com-authenticator/id514349476"]];
    }
}

- (BOOL)canHandleURL:(NSURL *)url {
    NSURL *redirectURL = [NSURL URLWithString:_redirectUri];
    return ([[url host] isEqualToString:[redirectURL host]] && [[url path] isEqualToString:[redirectURL path]]);
}

- (NSDictionary *)informationFromURL:(NSURL *)url {
    return [self dictionaryFromQueryComponents:[url query]];
}

#pragma mark uiactionsheetdelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // download mydigipass
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/mydigipass.com-authenticator/id514349476"]];
    }else if (buttonIndex == 1) { // open in browser
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mydigipassUrlString]];
    }
}


#pragma mark Private

- (NSString *)encodeString:(NSString *)str
{
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (CFStringRef)str,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 ));
}

- (NSMutableDictionary *)dictionaryFromQueryComponents:(NSString *)query {
    if ([query length] == 0) return nil;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for (NSString *parameter in [query componentsSeparatedByString:@"&"]) {
        NSRange range = [parameter rangeOfString:@"="];
        if (range.location != NSNotFound)
            [parameters setValue:[[parameter substringFromIndex:range.location + range.length] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding] forKey:[[parameter substringToIndex:range.location] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        else [parameters setValue:[[NSString alloc] init] forKey:[parameter stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    }
    return parameters;
}

- (BOOL)isMdpInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mydigipass-oauth://x-callback-url"]];
}

NSString *LocalizedString(NSString* key, NSString* comment) {
    static NSBundle* bundle = nil;
    if (!bundle) {
        NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MDPMobileSDK.bundle"];
        bundle = [NSBundle bundleWithPath:path];
    }

    return [bundle localizedStringForKey:key value:key table:nil];
}

@end
