Pod::Spec.new do |s|
  s.name         = "mdp_mobile_sdk"
  s.version      = "1.1.0"
  s.summary      = "MYDIGIPASS.COM Mobile App Authentication SDK for iOS."
  s.description  = <<-DESC
                   The SDK connects your mobile application with the MYDIGIPASS.COM Authenticator
                   for Mobile allowing you to reuse your server integration of the
                   MYDIGIPASS.COM Secure Connect API in your mobile app.
                   DESC
  s.homepage     = "https://www.mydigipass.com"
  s.documentation_url = "https://developer.mydigipass.com"
  s.license      = { :type => 'Vasco', :text => 'Copyright (c) 2015 VASCO Data Security International GmbH. All rights reserved.' }
  s.author       = "VASCO Data Security International GmbH"
  s.platform     = :ios
  s.source       = { :git => "git@github.com:vasco-data-security/mdp_mobile_ios_sdk.git", :tag => "1.1.0" }
  s.source_files  = 'mdp_mobile_sdk/*.{h,m}'
  s.requires_arc = true
  s.resource_bundle = { 'MDPMobileSDK' => 'mdp_mobile_sdk/MDPMobileSDK.bundle/*' }
end
