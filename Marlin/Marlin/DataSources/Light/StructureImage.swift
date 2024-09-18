//
//  StructureImage.swift
//  Marlin
//
//  Created by Daniel Barela on 8/12/22.
//

import Foundation
import UIKit

enum StructureType {
    case pillar
    case spar
    case conical
    case can
    case unknown
}

class StructureImage: UIImage, @unchecked Sendable {
    
    static let unknownBouyColor = 0x5587978B
    
    // structure passed in for future differentiation of structure types
    convenience init?(frame: CGRect, structure: String?, darkMode: Bool = false) {
        let strokeWidth = 0.5

        let radius = min(frame.width / 2.0, frame.height / 2.0) - (strokeWidth / 2.0)
        let diameter = radius * 2.0
        let center = CGPoint(x: (frame.width / 2.0), y: frame.height / 2.0)
        
        let borderColor = UIColor.label

        let renderer = UIGraphicsImageRenderer(size: frame.size)
        let image = renderer.image { _ in
            borderColor.setStroke()
            let outerBoundary = UIBezierPath(
                ovalIn: CGRect(x: strokeWidth / 2.0, y: strokeWidth / 2.0, width: diameter, height: diameter )
            )
            outerBoundary.lineWidth = strokeWidth
            outerBoundary.stroke()
            let fillColor = UIColor(rgbValue: StructureImage.unknownBouyColor)
            fillColor.setFill()
            outerBoundary.fill()
            
            let centralPath = UIBezierPath()
            centralPath.addArc(withCenter: center, radius: 0.25,
                               startAngle: 0, endAngle: 360 * (CGFloat.pi / 180.0),
                               clockwise: true)
            centralPath.lineWidth = 0.5
            borderColor.setStroke()
            centralPath.stroke()
        }
        
        guard  let cgImage = image.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
