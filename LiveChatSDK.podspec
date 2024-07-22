Pod::Spec.new do |spec|
spec.name = "LiveChatSDK"
spec.version = "1.0.0"
spec.summary = "LiveChatSDK Framework"
spec.description = "LiveChatSDK easy to create chat bot and support customer"
spec.homepage = "https://github.com/ldev1211/micall-sdk-ios"
spec.license = { :type => "MIT", :file => "LICENSE" }
spec.author = { 'LDev' => 'luongdien1211@gmail.com' }
spec.platform = :ios, "13.0"
spec.swift_version = '5.0'
spec.source = { :git => "https://github.com/ldev1211/micall-sdk-ios.git", :tag => spec.version.to_s }
spec.source_files = "MiCallSDK/MiCallSDK/**/**"
spec.public_header_files = 'MiCallSDK/MiCallSDK/*.h'
spec.frameworks = 'VideoToolbox', 'AudioToolbox', 'AVFoundation', 'CoreMedia','Foundation'
# Add C++ standard library settings
  spec.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
    #'VALID_ARCHS' => 'x86_64',
    'OTHER_LDFLAGS' => '-ObjC'
  }
spec.user_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }
end
