Pod::Spec.new do |spec|
spec.name = "LiveChatSDK"
spec.version = "1.0.5"
spec.summary = "My Library to learn"
spec.description = "It is a library only for learning purpose"
spec.homepage = "https://github.com/ldev1710/live-chat-sdk-ios"
spec.license = { :type => "MIT", :file => "LICENSE" }
spec.author = { "LDev" => "luongdien1211@gmail.com" }
spec.platform = :ios, "14.0"
spec.swift_version = '5.0'
spec.source = { :git => "https://github.com/ldev1710/live-chat-sdk-ios.git", :tag => '1.0.5' }
spec.source_files = "LiveChatSDK/**/*.{swift}"
spec.dependency 'Firebase'
spec.dependency 'SocketIO'
end