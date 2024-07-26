//
//  LCMessage.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

public class LCMessage:Identifiable {
    public var id: Int
    public var content: LCContent
    public var from: LCSender
    public var timeCreated: String
    
    public init(id: Int, content: LCContent, from: LCSender, timeCreated: String) {
        self.id = id
        self.content = content
        self.from = from
        self.timeCreated = timeCreated
    }
}
