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

static id mockUIApplication;

@implementation UIApplication (UIApplicationTestAdditions)
+(id)sharedApplication {
    return mockUIApplication;
}
@end

@implementation MDPMobileTests

- (void)setUp
{
    [super setUp];
    mockUIApplication = OCMClassMock([UIApplication class]); //[OCMockObject mockForClass:[UIApplication class]];
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

    NSURL *expectedUrl = [NSURL URLWithString:@"mydigipass-oauth://x-callback-url/2.0/authenticate?x-success=redirect%3A%2F%2Fme.please&client_id=abcdef&state=someState"];

    OCMStub([mockUIApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    OCMExpect([mockUIApplication openURL:expectedUrl]);

    [session authenticateWithState:@"someState"];

    OCMVerifyAll(mockUIApplication);
}

// This test is commented because we don't automatically open the URL in the browser but ask the user what to do instead.
// This also means it's not a quick-fix of a failing test but needs a rethink how to do this properly.
//- (void)testAuthenticateWithStateWithAppNotInstalled
//{
//    [MDPMobile setSharedSessionRedirectUri:@"redirect://me.please" clientId:@"abcdef"];
//    MDPMobile *session = [MDPMobile sharedSession];
//
//    NSURL *expectedUrl = [NSURL URLWithString:@"http://localhost:3000/oauth/authenticate.html?response_type=code&redirect_uri=redirect%3A%2F%2Fme.please&client_id=abcdef&state=someState"];
//
//    OCMStub([mockUIApplication canOpenURL:[OCMArg any]]).andReturn(NO);
//
//    OCMExpect([mockUIApplication openURL:expectedUrl]);
//
//    [session authenticateWithState:@"someState"];
//
//    OCMVerifyAll(mockUIApplication);
//}


- (void)testAuthenticateWithStateScopeAndParametersWithAppInstalled
{
    [MDPMobile setSharedSessionRedirectUri:@"redirect://me.please" clientId:@"abcdef"];
    MDPMobile *session = [MDPMobile sharedSession];

    NSURL *expectedUrl = [NSURL URLWithString:@"mydigipass-oauth://x-callback-url/2.0/authenticate?client_id=abcdef&OPAQUE=TRUE&state=someState&scope=eid_profile&x-success=redirect%3A%2F%2Fme.please&WHY=SO%20SERIOUS%3F"];
    OCMStub([mockUIApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    OCMExpect([mockUIApplication openURL:expectedUrl]);

    NSDictionary *opaqueParams = @{ @"OPAQUE" : @"TRUE", @"WHY" : @"SO SERIOUS?" };
    [session authenticateWithState:@"someState" scope: @"eid_profile" andParameters:opaqueParams];

    OCMVerifyAll(mockUIApplication);
}

- (void)testAuthenticateWithStateScopeButWithoutAnyOtherParametersWithAppInstalled
{
    [MDPMobile setSharedSessionRedirectUri:@"redirect://me.please" clientId:@"abcdef"];
    MDPMobile *session = [MDPMobile sharedSession];

    NSURL *expectedUrl = [NSURL URLWithString:@"mydigipass-oauth://x-callback-url/2.0/authenticate?client_id=abcdef&scope=eid_profile&state=someState&x-success=redirect%3A%2F%2Fme.please"];

    OCMStub([mockUIApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    OCMExpect([mockUIApplication openURL:expectedUrl]);

    [session authenticateWithState:@"someState" scope: @"eid_profile" andParameters:nil];

    OCMVerifyAll(mockUIApplication);
}

- (void)testAuthenticateWithStateScopeAndParametersGoesKaputWhenNoStateGiven
{

    [MDPMobile setSharedSessionRedirectUri:@"redirect://me.please" clientId:@"abcdef"];
    MDPMobile *session = [MDPMobile sharedSession];

    XCTAssertThrows([session authenticateWithState:@"" scope: @"eid_profile" andParameters:nil], @"The usage of the state parameter is mandatory for CSRF prevention.");
    XCTAssertThrows([session authenticateWithState:nil scope: @"eid_profile" andParameters:nil], @"The usage of the state parameter is mandatory for CSRF prevention.");
}


@end
