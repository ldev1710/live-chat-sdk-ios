//
//  LCUser.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

public class LCUser {
    public var fullName: String
    public var email: String
    public var phone: String
    public var deviceName: String
    
    init(fullName: String, email: String, phone: String, deviceName: String) {
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.deviceName = deviceName
    }
}
