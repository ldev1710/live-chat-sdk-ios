# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'LiveChatSDK' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'FirebaseCore', :git => 'https://github.com/firebase/firebase-ios-sdk.git', :branch => 'main'
  pod 'FirebaseMessaging', :git => 'https://github.com/firebase/firebase-ios-sdk.git', :branch => 'main'
  pod 'FirebaseInstallations', :git => 'https://github.com/firebase/firebase-ios-sdk.git', :branch => 'main'
  pod 'FirebaseCoreInternal', :git => 'https://github.com/firebase/firebase-ios-sdk.git', :branch => 'main'
  # Pods for LiveChatSDK
    post_install do |installer|
     installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
       config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
     end
    end
end

#target 'Pods' do

#end
