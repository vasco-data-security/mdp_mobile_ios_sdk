//
//  mdp_mobile_sdkTests.m
//  mdp_mobile_sdkTests
//
//  Created by Tim Vandecasteele on 29/11/13.
//  Copyright (c) 2014 VASCO Data Security International GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDPMobile.h"
#import <UIKit/UIKit.h>
#import <OCMock/OCMock.h>

@interface MDPMobileTests : XCTestCase

@end

static OCMockObject *mockUIApplication = nil;

@implementation UIApplication (UIApplicationTestAdditions)
+(id)sharedApplication {
    return mockUIApplication;
}
@end

@implementation MDPMobileTests

- (void)setUp
{
    [super setUp];
    mockUIApplication = [OCMockObject mockForClass:[UIApplication class]];
    [[[mockUIApplication stub] andReturnValue:@YES] canOpenURL:[OCMArg any]];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [(OCMockObject *)mockUIApplication stopMocking];
}

- (void)testInformationFromURL
{
    [MDPMobile setSharedSessionRedirectUri:@"redirect://me.please" clientId:@"abcdef"];
    MDPMobile *session = [MDPMobile sharedSession];
    NSDictionary *dictionary = [session informationFromURL:[NSURL URLWithString:@"redirect://me.please?code=theCode&state=theState"]];

    XCTAssertEqualObjects([dictionary objectForKey:@"code"], @"theCode");
    XCTAssertEqualObjects([dictionary objectForKey:@"state"],@"theState");
}

- (void)testCanHandleURL
{
    [MDPMobile setSharedSessionRedirectUri:@"protocol://host/path" clientId:@"abcdef"];
    MDPMobile *session = [MDPMobile sharedSession];

    XCTAssert([session canHandleURL:[NSURL URLWithString:@"protocol://host/path?some=parameters&some_more=parameters"]]);
    XCTAssertFalse([session canHandleURL:[NSURL URLWithString:@"protocol://wronghost/path?some=parameters&some_more=parameters"]]);
    XCTAssertFalse([session canHandleURL:[NSURL URLWithString:@"protocol://host/wrongpath?some=parameters&some_more=parameters"]]);
}

- (void)testAuthenticateWithStateWithAppInstalled
{
    [MDPMobile setSharedSessionRedirectUri:@"redirect://me.please" clientId:@"abcdef"];
    MDPMobile *session = [MDPMobile sharedSession];

    NSString *expectedUrl = @"mydigipass-oauth://x-callback-url/2.0/authenticate?x-success=redirect%3A%2F%2Fme.please&client_id=abcdef&state=someState";
    [[[mockUIApplication stub] andReturnValue:@YES] canOpenURL:[OCMArg any]];

    [[mockUIApplication expect] openURL:[OCMArg checkWithBlock:^BOOL(NSURL *url){
        XCTAssertEqualObjects([url absoluteString], expectedUrl);
    }]];

    [session authenticateWithState:@"someState"];
}

- (void)testAuthenticateWithStateWithAppNotInstalled
{
    [MDPMobile setSharedSessionRedirectUri:@"redirect://me.please" clientId:@"abcdef"];
    MDPMobile *session = [MDPMobile sharedSession];

    NSString *expectedUrl = @"http://localhost:3000/oauth/authenticate.html?response_type=code&redirect_uri=redirect%3A%2F%2Fme.please&client_id=abcdef&state=someState";
    mockUIApplication = [OCMockObject mockForClass:[UIApplication class]];
    [[[mockUIApplication stub] andReturnValue:@NO] canOpenURL:[OCMArg any]];

    [[mockUIApplication expect] openURL:[OCMArg checkWithBlock:^BOOL(NSURL *url){
        XCTAssertEqualObjects([url absoluteString], expectedUrl);
    }]];

    [session authenticateWithState:@"someState"];
}

@end
