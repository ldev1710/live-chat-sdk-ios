//
//  LCParseUtil.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 23/07/2024.
//

import Foundation

public class LCParseUtil {
    public static func contentFrom(contentRaw: [String:Any]) -> LCContent {
        let contentType = contentRaw["content-type"] as! String
        if(contentType == "file" || contentType == "image"){
            var lcAttachments:[LCAttachment] = []
            let rawAttachments = contentRaw["content-message"] as! [Any]
            for rawAttachment in rawAttachments {
                let jsonAttachment = rawAttachment as! [String:String]
                let fileName = jsonAttachment["file-name"]! as String
                let fileExtension = fileName.components(separatedBy: ".").last
                lcAttachments.append(
                    LCAttachment(
                        url: jsonAttachment["url"]! as String,
                        fileName: fileName,
                        fileExtension: fileExtension!
                    )
                )
            }
            return LCContent(contentType: contentType, contentMessage: lcAttachments)
        } else {
            return LCContent(contentType: contentType, contentMessage: contentRaw["content-message"] as! String)
        }
    }
    
    public static func convertToDictionary(text: String) -> [String: Any] {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return [:]
    }
}
