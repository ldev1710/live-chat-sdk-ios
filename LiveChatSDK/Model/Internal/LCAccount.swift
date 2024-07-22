//
//  LCAccount.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

public class LCAccount {
    public var id: Int
    public var groupId: Int
    public var groupName: String
    public var socketDomain: String
    public var hostName: String
    public var supportType: [LCSupportType]
    
    init(id: Int, groupId: Int, groupName: String, socketDomain: String, hostName: String, supportType: [LCSupportType]) {
        self.id = id
        self.groupId = groupId
        self.groupName = groupName
        self.socketDomain = socketDomain
        self.hostName = hostName
        self.supportType = supportType
    }
}
