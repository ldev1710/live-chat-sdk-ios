//
//  LCContent.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

public class LCContent:Identifiable {
    public var contentType: String
    public var contentMessage: Any
    
    public init(contentType: String, contentMessage: Any) {
        self.contentType = contentType
        self.contentMessage = contentMessage
    }
}
