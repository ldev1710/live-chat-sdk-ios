//
//  LCMessageSend.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

public class LCMessageSend:Identifiable {
    public var content: String
    
    public init(content: String) {
        self.content = content
    }
}
