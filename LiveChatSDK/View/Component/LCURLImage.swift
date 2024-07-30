//
//  LCURLImage.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 30/07/2024.
//

import Foundation
import SwiftUI

struct URLImage: View {
    @StateObject private var loader: LCImageLoader
    let placeholder: UIImage

    init(url: URL, placeholder: UIImage = UIImage(systemName: "photo")!) {
        _loader = StateObject(wrappedValue: LCImageLoader())
        self.placeholder = placeholder
        loader.load(from: url)
    }

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    private var image: Image {
        if let uiImage = loader.image {
            return Image(uiImage: uiImage)
        } else {
            return Image(uiImage: placeholder)
        }
    }
}
