//
//  AsyncImage.swift
//  Marlin
//
//  Created by Daniel Barela on 11/15/22.
//

import Foundation
import SwiftUI

struct AsyncImage<Placeholder: View>: View {
    @StateObject var loader: ImageLoader
    private let placeholder: Placeholder
    let image: (UIImage) -> Image
    private let name: String
    
    init(
        url: URL,
        name: String = "image.png",
        @ViewBuilder placeholder: () -> Placeholder,
        @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)
    ) {
        self.placeholder = placeholder()
        self.image = image
        self.name = name
        
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: BoundedImageCache.shared))
    }
    
    var body: some View {
        content
            .onAppear(perform: loader.load)
    }
    
    private var content: some View {
        Group {
            if loader.image != nil {
                image(loader.image!)
            } else {
                placeholder
            }
        }
        .onTapGesture {
            if let image = loader.image, let imageData = image.pngData(), let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

                let filename = docsUrl.appendingPathComponent(name)
                try? imageData.write(to: filename)
                NotificationCenter.default.post(name: .DocumentPreview, object: filename)
            }
            
            
        }
    }
}
