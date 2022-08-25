//
//  RaconImage.swift
//  Marlin
//
//  Created by Daniel Barela on 7/13/22.
//

import Foundation
import UIKit

class RaconImage : UIImage {

    convenience init?(frame: CGRect, sectors: [LightSector]? = nil, arcWidth: Double = 2, arcRadius: Double = 8, text: String? = "Racon", darkMode: Bool = false) {
        var rect = frame
        let circleColor = Light.raconColor
        let labelColor = UIColor.label.resolvedColor(with:UITraitCollection(traitsFrom: [.init(userInterfaceStyle: darkMode ? .dark : .light)]))
        
        if let text = text {
            // Color text
            let attributes = [ NSAttributedString.Key.foregroundColor: labelColor,
                               NSAttributedString.Key.font: UIFont.systemFont(ofSize: arcWidth + 4)]
            
            let size = text.size(withAttributes: attributes)
            // expand the rect to fit the text
            let largestWidth = arcRadius + arcWidth + size.width
            rect = largestWidth < (rect.width / 2.0) ? rect : CGRect(x: rect.origin.x, y: rect.origin.y, width: largestWidth * 2, height: rect.size.height)
        }
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        let image = renderer.image { _ in
            let center = CGPoint(x: (rect.width / 2.0), y: rect.height / 2.0)

            let outerPath = UIBezierPath()
            if let sectors = sectors {
                for sector in sectors {
                    outerPath.addArc(withCenter: center, radius: arcRadius,
                                     startAngle: (sector.startDegrees + 90) * (CGFloat.pi / 180.0), endAngle: (sector.endDegrees + 90) * (CGFloat.pi / 180.0),
                                     clockwise: true)
                }
            } else {
                outerPath.addArc(withCenter: center, radius: arcRadius,
                           startAngle: 0, endAngle: 360 * (CGFloat.pi / 180.0),
                           clockwise: true)
            }
            outerPath.lineWidth = arcWidth
            circleColor.setStroke()
            outerPath.stroke()
            
            let innerPath = UIBezierPath()
            innerPath.addArc(withCenter: center, radius: 1.5,
                             startAngle: 0, endAngle: 360 * (CGFloat.pi / 180.0),
                             clockwise: true)
            innerPath.lineWidth = 0.5
            labelColor.setStroke()
            innerPath.stroke()
            
            let centralPath = UIBezierPath()
            centralPath.addArc(withCenter: center, radius: 0.25,
                             startAngle: 0, endAngle: 360 * (CGFloat.pi / 180.0),
                             clockwise: true)
            centralPath.lineWidth = 0.5
            labelColor.setStroke()
            centralPath.stroke()
            
            if let text = text {
                // Color text
                let attributes = [ NSAttributedString.Key.foregroundColor: labelColor,
                                   NSAttributedString.Key.font: UIFont.systemFont(ofSize: arcWidth + 4)]
                
                let size = text.size(withAttributes: attributes)
                let rect = CGRect(x: center.x + arcRadius + arcWidth, y: center.y - size.height / 2, width: size.width, height: size.height)
                text.draw(in: rect, withAttributes: attributes)
            }
        }
        
        guard  let cgImage = image.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
        
    }
}
