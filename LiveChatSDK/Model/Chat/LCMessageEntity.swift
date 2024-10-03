//
//  LCMessageEntity.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 19/08/2024.
//

import Foundation

public class LCMessageEntity : Identifiable, ObservableObject{
    public var id: UUID = UUID()
    @Published public var lcMessage: LCMessage
    @Published public var status: LCStatusMessage
    
    public init(lcMessage: LCMessage, status: LCStatusMessage) {
        self.lcMessage = lcMessage
        self.status = status
    }
}
