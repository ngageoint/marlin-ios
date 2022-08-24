//
//  FogSignalImage.swift
//  Marlin
//
//  Created by Daniel Barela on 7/18/22.
//

import Foundation
import UIKit

class FogSignalImage : UIImage {
    
    convenience init?(frame: CGRect, arcWidth: CGFloat? = nil, arcRadius: CGFloat? = nil, drawArcs: Bool = true, darkMode: Bool = false) {
        let strokeWidth = 0.5
        let rect = frame
        let radius = arcRadius ?? min(rect.width / 2.0, rect.height / 2.0) - ((arcWidth ?? strokeWidth) / 2.0)
        let finalArcWidth = arcWidth ?? 2.0
        
        let circleColor = Light.raconColor
        let labelColor = UIColor.label.resolvedColor(with:UITraitCollection(traitsFrom: [.init(userInterfaceStyle: darkMode ? .dark : .light)]))
        
        let renderer = UIGraphicsImageRenderer(size: frame.size)
        let image = renderer.image { _ in
            let center = CGPoint(x: (rect.width / 2.0), y: rect.height / 2.0)
            
            if drawArcs {
                let outerPath = UIBezierPath()
                outerPath.addArc(withCenter: center, radius: radius,
                                 startAngle: 315 * (CGFloat.pi / 180.0), endAngle: 0 * (CGFloat.pi / 180.0),
                                 clockwise: true)
                outerPath.lineWidth = finalArcWidth
                circleColor.setStroke()
                outerPath.stroke()
                
                let middlePath = UIBezierPath()
                middlePath.addArc(withCenter: center, radius: radius - (radius / 3),
                                  startAngle: 315 * (CGFloat.pi / 180.0), endAngle: 0 * (CGFloat.pi / 180.0),
                                  clockwise: true)
                middlePath.lineWidth = finalArcWidth
                circleColor.setStroke()
                middlePath.stroke()
                
                let innerSignalPath = UIBezierPath()
                innerSignalPath.addArc(withCenter: center, radius: radius - (radius / 1.5),
                                       startAngle: 315 * (CGFloat.pi / 180.0), endAngle: 0 * (CGFloat.pi / 180.0),
                                       clockwise: true)
                innerSignalPath.lineWidth = finalArcWidth
                circleColor.setStroke()
                innerSignalPath.stroke()
            }
            
            let innerPath = UIBezierPath()
            innerPath.addArc(withCenter: center, radius: 1.5,
                             startAngle: 0, endAngle: 360 * (CGFloat.pi / 180.0),
                             clockwise: true)
            innerPath.lineWidth = drawArcs ? 0.5 : 2
            labelColor.setStroke()
            innerPath.stroke()
            
            let centralPath = UIBezierPath()
            centralPath.addArc(withCenter: center, radius: 0.25,
                               startAngle: 0, endAngle: 360 * (CGFloat.pi / 180.0),
                               clockwise: true)
            centralPath.lineWidth = 0.5
            labelColor.setStroke()
            centralPath.stroke()
        }
        
        guard  let cgImage = image.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
        
    }
}
