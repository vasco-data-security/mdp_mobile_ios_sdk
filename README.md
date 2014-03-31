# MYDIGIPASS.COM Mobile App Authentication SDK for iOS

## About the SDK

The SDK connects your mobile application with the MYDIGIPASS.COM Authenticator for Mobile
allowing you to reuse your server integration of the Secure Connect API in your mobile app.

* Learn more about MYDIGIPASS.COM:
    * https://www.mydigipass.com/
    * https://developer.mydigipass.com/
* Learn more about the SDK and the Secure Connect API:
    * https://developer.mydigipass.com/getting_started
    * https://developer.mydigipass.com/mobile_app_authentication

## Installation

### Using Cocoapods

Install Cocoapods Ruby gem, also see http://cocoapods.org/

	sudo gem install cocoapods

Configure Podfile

	platform :ios, '7.0'
	pod 'mdp_mobile_sdk', :git => 'git@github.com:vasco-data-security/mdp_mobile_ios_sdk.git'

Pod install

	pod install

Make sure to always open the Xcode workspace instead of the project file from now on.

## Code

To configure the MDPMobile instance you need to use a MYDIGIPASS.COM production client id and registered mobile app redirect URI. See https://developer.mydigipass.com for more info.

Registering your mobile redirect URL as a custom URL scheme in your _xxx-Info.plist_:


	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLName</key>
			<string>com.yourcompany.your-app</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>your-app</string>
			</array>
		</dict>
	</array>

Configuring your mobile redirect URI and client id in your _xAppDelegate.m_:

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	    [MDPMobile setSharedSessionRedirectUri:@"your-app://x-callback-url/mdp_callback" clientId:@"bnvmxzawde1yuqgea6w6kd49n"];
	    // ...
	}

## Performing an authentication request

Performing the actual authentication, also passing server-side generated OAuth state:

    [[MDPMobile sharedSession] authenticateWithState:@"xyzabc1234567"];

Review [this sequence diagram](https://developer.mydigipass.com/mobile_app_authentication) and
the [OAuth 2.0 spec](http://tools.ietf.org/html/rfc6749#section-10.12) for more info about the state parameter.

Handling the SDK callback in your _xAppDelegate.m_:

	- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	    MDPMobile *mdpSession = [MDPMobile sharedSession];
	
	    if ([mdpSession canHandleURL:url]) {
	        NSDictionary *queryDictionary = [mdpSession informationFromURL:url];
	
	        // Pass authorizationCode to your server-side implementation of the Secure Connect API
    		// See https://developer.mydigipass.com/mobile_app_authentication
	
	        return YES;
	    }
	    
	    ...
	    
	}
