//
//  NSObject+NSDictionary_UrlEncoding.h
//  mdp_mobile_sdk
//
//  Created by Raphael on 12/10/2015.
//  Copyright © 2015 Vasco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (UrlEncoding)
+ (NSString *)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary;
@end
