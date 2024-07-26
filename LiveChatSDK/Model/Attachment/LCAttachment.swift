//
//  LCAttachment.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

public class LCAttachment: LCFile {
    public var url: String
    
    public init(url: String,fileName: String, fileExtension: String) {
        self.url = url
        super.init(fileName: fileName, fileExtension: fileExtension)
    }
}
