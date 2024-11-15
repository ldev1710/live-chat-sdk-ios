Pod::Spec.new do |spec|
spec.name = "LiveChatSDK"
spec.version = "1.2.6"
spec.summary = "LiveChatSDK to make message to MITEK Ecosystem easily"
spec.description = "It is a library only for learning purpose"
spec.homepage = "https://gitlab.mitek.vn/mitek-public/sdk/michat/live-chat-sdk-ios.git"
spec.license = { :type => "MIT", :file => "LICENSE" }
spec.author = { "LDev" => "luongdien1211@gmail.com" }
spec.swift_version = '5.0'
spec.source = { :git => "https://gitlab.mitek.vn/mitek-public/sdk/michat/live-chat-sdk-ios.git", :tag => spec.version }
spec.source_files = "LiveChatSDK/**/*.{swift}"
spec.dependency 'Socket.IO-Client-Swift'
spec.ios.deployment_target = '14.0'
end
