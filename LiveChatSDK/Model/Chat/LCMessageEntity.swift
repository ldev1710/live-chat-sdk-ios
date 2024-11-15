//
//  LCMessageEntity.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 19/08/2024.
//

import Foundation

public class LCMessageEntity : Identifiable, ObservableObject{
    public var id: UUID = UUID()
    @Published public var lcMessage: LCMessage?
    @Published public var status: LCStatusMessage?
    @Published public var errorMessage: String? = nil
    
    public init(lcMessage: LCMessage?, status: LCStatusMessage?,errormessage: String?) {
        self.lcMessage = lcMessage
        self.status = status
        self.errorMessage = errormessage
    }
}
