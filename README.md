# MYDIGIPASS Mobile App Authentication SDK for iOS

## About the SDK

The SDK connects your mobile application with the MYDIGIPASS Authenticator for Mobile
allowing you to reuse your server integration of the Secure Connect API in your mobile app.

* Learn more about MYDIGIPASS:
    * [https://www.mydigipass.com/](https://www.mydigipass.com/)
    * [https://developer.mydigipass.com/](https://developer.mydigipass.com/)
* Learn more about the SDK and the Secure Connect API:
    * [https://developer.mydigipass.com/introduction](https://developer.mydigipass.com/introduction)
    * [https://developer.mydigipass.com/mobile_integration](https://developer.mydigipass.com/mobile_integration)

## Installation

### Using Cocoapods

Install Cocoapods Ruby gem, also see [http://cocoapods.org/](http://cocoapods.org/)

	sudo gem install cocoapods

Configure Podfile

	platform :ios, '7.0'
	pod 'mdp_mobile_sdk', :git => 'git@github.com:vasco-data-security/mdp_mobile_ios_sdk.git'

Pod install

	pod install

Make sure to always open the Xcode workspace instead of the project file from now on.

## Code

### Client ID and redirect URI for your mobile app

To configure the MDPMobile instance you need a MYDIGIPASS **client id** and register your **bundle identifier** and a **redirect URI** specific to your mobile app.

1. Create an application at [https://developer.mydigipass.com](https://developer.mydigipass.com/) to get a **client id**.
2. Register the **bundle identifier* of your mobile app and **redirect URI* by editing the *OAuth URIs* of your application.

Example:

* Identifier: `com.yourcompany.com.your-app`
* Redirect URI: `your-app://mydigipass-login`

### Configuring the mobile app redirect URI via the URL schemes of your mobile app

Once you have done the above, it's time to configure your iOS project by registering your mobile redirect URL as a custom URL scheme in your applications `xxx-Info.plist`:
Tip: If you know nothing about URL schemes in iOS, search for **Using URL Schemes to Communicate with Apps** in Apple's developer documentation.

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

### Using your Client ID and mobile app redirect URI with the SDK

Configuring your mobile redirect URI and client id in your _xAppDelegate.m_:

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	    [MDPMobile setSharedSessionRedirectUri:@"your-app://mydigipass-login" clientId:@"bnvmxzawde1yuqgea6w6kd49n"];
	    // ...
	}
	
### Performing an authentication request

To perform an authentication request you need use `authenticateWithState:scope:andParameters`.
The parameter values mirror the ones you can configure for the (Secure Login Button)[https://developer.mydigipass.com/reference_guide_button] 

Parameter overview:

* `state`, **mandatory**. To track state, e.g. to remember that a user pressed the Secure Login Button on your application’s user profile page and to prevent CSRF attacks. 
* `scope`, **optional**. The scope of the user data you want to retrieve (e.g. `email`). Learn more about scopes on our [developer site](https://developer.mydigipass.com/quick_start#secure_login_button)
* `parameters`, **optional**. Any other parameters you want use to pass information and/or state to your server's redirect endpoint.

Review [this sequence diagram](https://developer.mydigipass.com/mobile_integration) and
the [OAuth 2.0 spec](http://tools.ietf.org/html/rfc6749#section-10.12) for more info about the state parameter.

Example:

    [[MDPMobile sharedSession] authenticateWithState:@"xyzabc1234567" scope:@"email phone" andParameters:@{@"return_to" : "dashboard", @"new_user" : "yes"}];

### Using the authorisation code in _xAppDelegate.m_ via `application:openURL:sourceApplication:annotation`:

The MYDIGIPASS app will call your application and will pass your app the OAuth authorisation code you can then pass to your server integration:

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

## One more thing: iOS 9 and canOpenURL

iOS 9 changed the behaviour of `canOpenURL`. When compiling your app against the iOS 9 SDK you have to declare the URL schemes you'll want to run `canOpenURL` on.
To learn more about these changes see [WWDC 2015 video of Session 703, “Privacy and Your App”](https://developer.apple.com/videos/wwdc/2015/?id=703).

So to declare that your app will open the MYDIGIPASS app you have to add our `mydigipass-oauth` URL scheme in your Info plist:

	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>mydigipass-oauth</string>
	</array>

If you do not declare the `mydigipass-oauth` URL scheme in your application you will see the following in syslog:

    canOpenURL: failed for URL: "urlscheme://" - error: "This app is not allowed to query for scheme mydigipass-oauth"