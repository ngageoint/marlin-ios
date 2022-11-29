//
//  ImageCache.swift
//  Marlin
//
//  Created by Daniel Barela on 11/15/22.
//

import Foundation
import UIKit
import SwiftUI

//struct ImageCacheKey: EnvironmentKey {
//    static let defaultValue: ImageCache = TemporaryImageCache()
//}
//
//extension EnvironmentValues {
//    var imageCache: ImageCache {
//        get { self[ImageCacheKey.self] }
//        set { self[ImageCacheKey.self] = newValue }
//    }
//}

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

struct BoundedImageCache: ImageCache {
    static let shared: BoundedImageCache = BoundedImageCache()
    
    private init() {
    }
    
    private let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100 // 100 items
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        return cache
    }()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}
