//
//  LCMessageSend.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

public class LCMessageSend {
    public var content: String
    public var lcSession: LCSession
    
    public init(content: String, lcSession: LCSession) {
        self.content = content
        self.lcSession = lcSession
    }
}
