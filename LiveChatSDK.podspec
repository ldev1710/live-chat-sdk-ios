Pod::Spec.new do |spec|
spec.name = "LiveChatSDK"
spec.version = "1.0.0"
spec.summary = "LiveChatSDK Framework"
spec.description = "LiveChatSDK easy to create chat bot and support customer"
spec.homepage = "https://github.com/ldev1710/live-chat-sdk-ios"
spec.license = { :type => "MIT", :file => "LICENSE" }
spec.author = { 'LDev' => 'luongdien1211@gmail.com' }
spec.platform = :ios, "11.0"
spec.swift_version = '5.0'
spec.source = { :git => "https://github.com/ldev1710/live-chat-sdk-ios.git", :tag => spec.version.to_s }
spec.source_files = "LiveChatSDK/**/**"
spec.dependency 'SocketIO'
spec.dependency 'Starscream'

end
