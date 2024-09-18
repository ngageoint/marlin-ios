//
//  RaconImage.swift
//  Marlin
//
//  Created by Daniel Barela on 7/13/22.
//

import Foundation
import UIKit

class RaconImage: UIImage, @unchecked Sendable {

    convenience init?(
        frame: CGRect,
        sectors: [ImageSector]? = nil,
        arcWidth: Double = 2,
        arcRadius: Double = 8,
        text: String? = "Racon",
        darkMode: Bool = false) {
        let rect = frame
        
        let centralDot = CircleImage(color: UIColor.label, radius: 0.5, fill: true)
        let innerPath = CircleImage(color: UIColor.label, radius: 1.5, arcWidth: 0.5)
        let outerPath = CircleImage(
            suggestedFrame: rect,
            sectors: sectors ?? [
                ImageSector(startDegrees: 0, endDegrees: 360, color: Light.raconColor)
            ],
            radius: arcRadius,
            fill: false,
            arcWidth: arcWidth)

        guard let centralDot = centralDot, let innerPath = innerPath, let outerPath = outerPath else {
            return nil
        }
        var size: CGSize = CGSize(width: outerPath.size.width, height: outerPath.size.height)
        
        var textImage: UIImage?
        if let text = text {
            textImage = CircleImage(
                imageSize: CGSize(width: arcRadius * 2, height: arcRadius * 2),
                sideText: text,
                fontSize: arcWidth * 2)
            size.width = max(textImage?.size.width ?? 0.0, size.width)
            size.height = max(textImage?.size.height ?? 0.0, size.height)
        }
        
        UIGraphicsBeginImageContext(size)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        centralDot.draw(at: CGPoint(x: center.x - centralDot.size.width / 2, y: center.y - centralDot.size.height / 2))

        innerPath.draw(at: CGPoint(x: center.x - innerPath.size.width / 2, y: center.y - innerPath.size.height / 2))
        
        outerPath.draw(at: CGPoint(x: center.x - outerPath.size.width / 2, y: center.y - outerPath.size.height / 2))
        
        if let textImage = textImage {
            textImage.draw(at: CGPoint(x: center.x - textImage.size.width / 2, y: center.y - textImage.size.height / 2))
        }
        
        let raconCircle: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()

        guard  let cgImage = raconCircle.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
