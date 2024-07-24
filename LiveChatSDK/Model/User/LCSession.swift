//
//  LCSession.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

public class LCSession {
    public var sessionId: String
    public var visitorJid: String
    
    public init(sessionId: String, visitorJid: String) {
        self.sessionId = sessionId
        self.visitorJid = visitorJid
    }
}
