//
//  LCMessageEntity.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 19/08/2024.
//

import Foundation

public class LCMessageEntity : Identifiable{
    public var lcMessage: LCMessage
    public var status: LCStatusMessage
    
    public init(lcMessage: LCMessage, status: LCStatusMessage) {
        self.lcMessage = lcMessage
        self.status = status
    }
}
