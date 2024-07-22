//
//  LCContent.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

public class LCContent {
    public var contentType: String
    public var contentMessage: Any
    
    init(contentType: String, contentMessage: Any) {
        self.contentType = contentType
        self.contentMessage = contentMessage
    }
}
