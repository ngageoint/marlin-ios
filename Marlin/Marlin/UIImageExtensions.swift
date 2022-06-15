//
//  UIImageExtensions.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import UIKit
import AVKit

extension UIImage {
    
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    @objc func aspectResize(to size: CGSize) -> UIImage {
        let scaledRect = AVMakeRect(aspectRatio: self.size, insideRect: CGRect(x: 0, y: 0, width: size.width, height: size.height));
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: scaledRect)
        }
    }
    
    @objc func aspectResizeJpeg(to size: CGSize) -> Data? {
        let scaledRect = AVMakeRect(aspectRatio: self.size, insideRect: CGRect(x: 0, y: 0, width: size.width, height: size.height));
        return UIGraphicsImageRenderer(size: size).jpegData(withCompressionQuality: 1.0) { ctx in
            
            draw(in: scaledRect)
        }
    }
}
