//
//  LightCircle.swift
//  Marlin
//
//  Created by Daniel Barela on 7/8/22.
//

import Foundation
import SwiftUI
import UIKit

struct LightSector {
    var startDegrees: Double
    var endDegrees: Double
    var color: UIColor
    var text: String
}

class LightColorImage : UIImage {
    convenience init?(frame: CGRect, sectors: [LightSector], arcWidth: CGFloat? = nil, arcRadius: CGFloat? = nil, includeSectorDashes: Bool = false, includeLetters: Bool = true, darkMode: Bool = false) {
        let strokeWidth = 0.5
        let rect = frame
        let radius = arcRadius ?? min(rect.width / 2.0, rect.height / 2.0) - ((arcWidth ?? strokeWidth) / 2.0)
        let sectorDashLength = includeSectorDashes ? min(rect.width / 2.0, rect.height / 2.0) : 0.0
        let wholeColor = UIColor.lightGray
        let diameter = radius * 2.0
        
        let renderer = UIGraphicsImageRenderer(size: frame.size)
        let image = renderer.image { _ in
            // Fill full circle with wholeColor
            if arcWidth == nil {
                wholeColor.setStroke()
                let outerBoundary = UIBezierPath(ovalIn: CGRect(x: strokeWidth / 2.0, y: strokeWidth / 2.0, width: diameter, height: diameter ))
                outerBoundary.lineWidth = strokeWidth
                outerBoundary.stroke()
            }
            
            let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
            
            for sector in sectors {
                let startAngle = CGFloat(sector.startDegrees + 90) * (CGFloat.pi / 180.0)
                let endAngle = CGFloat(sector.endDegrees + 90) * (CGFloat.pi / 180.0)
                let piePath = UIBezierPath()
                piePath.addArc(withCenter: center, radius: radius,
                               startAngle: startAngle, endAngle: endAngle,
                               clockwise: true)
            
                if arcWidth == nil {
                    piePath.addLine(to: CGPoint(x: radius, y: radius))
                }
                if let arcWidth = arcWidth {
                    piePath.lineWidth = arcWidth
                    sector.color.setStroke()
                    piePath.stroke()
                } else {
                    piePath.close()
                    sector.color.setFill()
                    piePath.fill()
                }
                
                if includeSectorDashes {
                    let dashColor = UIColor.label.resolvedColor(with:UITraitCollection(traitsFrom: [.init(userInterfaceStyle: darkMode ? .dark : .light)])).withAlphaComponent(0.87)
                    
                    let sectorDash = UIBezierPath()
                    sectorDash.move(to: center)

                    sectorDash.addLine(to: CGPoint(x: center.x + sectorDashLength, y: center.y))
                    sectorDash.apply(CGAffineTransform(translationX: -center.x, y: -center.y))
                    sectorDash.apply(CGAffineTransform(rotationAngle: CGFloat(sector.startDegrees + 90) * .pi / 180))
                    sectorDash.apply(CGAffineTransform(translationX: center.x, y: center.y))
                    
                    sectorDash.lineWidth = 0.2
                    let  dashes: [ CGFloat ] = [ 2.0, 1.0 ]
                    sectorDash.setLineDash(dashes, count: dashes.count, phase: 0.0)
                    sectorDash.lineCapStyle = .butt
                    dashColor.setStroke()
                    sectorDash.stroke()
                    
                    let sectorEndDash = UIBezierPath()
                    sectorEndDash.move(to: center)

                    sectorEndDash.addLine(to: CGPoint(x: center.x + sectorDashLength, y: center.y))
                    sectorEndDash.apply(CGAffineTransform(translationX: -center.x, y: -center.y))
                    sectorEndDash.apply(CGAffineTransform(rotationAngle: CGFloat(sector.endDegrees + 90) * .pi / 180))
                    sectorEndDash.apply(CGAffineTransform(translationX: center.x, y: center.y))

                    sectorEndDash.lineWidth = 0.2
                    sectorEndDash.setLineDash(dashes, count: dashes.count, phase: 0.0)
                    sectorEndDash.lineCapStyle = .butt
                    dashColor.setStroke()
                    sectorEndDash.stroke()
                }
                
                if includeLetters {
                    // We want black letters when the circle is filled
                    let color = UIColor.label.resolvedColor(with:UITraitCollection(traitsFrom: [.init(userInterfaceStyle: darkMode && arcWidth != nil ? .dark : .light)]))
                    // Color text
                    let attributes = [ NSAttributedString.Key.foregroundColor: color,
                                       NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: arcWidth ?? 3)]
                    let text = sector.text
                    let size = text.size(withAttributes: attributes)
                    
                    let midPointAngle = CGFloat(sector.startDegrees) + CGFloat(sector.endDegrees - sector.startDegrees) / 2.0
                    var textRadius = radius
                    if let arcWidth = arcWidth{
                        textRadius -= arcWidth * 1.75
                    } else {
                        textRadius -= size.height
                    }
                    text.drawWithBasePoint(basePoint: center, radius: textRadius, andAngle: midPointAngle * .pi / 180, andAttributes: attributes)
                }
            }
        }
        
        guard  let cgImage = image.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
        
    }
    
    static func dynamicAsset(frame: CGRect, sectors: [LightSector], arcWidth: CGFloat? = nil, arcRadius: CGFloat? = nil, includeSectorDashes: Bool = false, includeLetters: Bool = true) -> UIImage {
        let imageAsset = UIImageAsset()
        
        let lightMode = UITraitCollection(traitsFrom: [.init(userInterfaceStyle: .light)])
        if let lightImage = LightColorImage(frame: frame, sectors: sectors, arcWidth: arcWidth, arcRadius: arcRadius, includeSectorDashes: includeSectorDashes, includeLetters: includeLetters, darkMode: false) {
            imageAsset.register(lightImage, with: lightMode)
        }
            
        let darkMode = UITraitCollection(traitsFrom: [.init(userInterfaceStyle: .dark)])
        if let darkImage = LightColorImage(frame: frame, sectors: sectors, arcWidth: arcWidth, arcRadius: arcRadius, includeSectorDashes: includeSectorDashes, includeLetters: includeLetters, darkMode: true) {
            imageAsset.register(darkImage, with: darkMode)
        }
        return imageAsset.image(with: .current)
    }
}

extension String {
    func drawWithBasePoint(basePoint: CGPoint,
                           radius: CGFloat,
                           andAngle angle: CGFloat,
                           andAttributes attributes: [NSAttributedString.Key : Any]) {
        let size: CGSize = self.size(withAttributes: attributes)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        let t: CGAffineTransform = CGAffineTransform(translationX: basePoint.x, y: basePoint.y)
        let r: CGAffineTransform = CGAffineTransform(rotationAngle: angle)
        context.concatenate(t)
        context.concatenate(r)
        let rect = CGRect(x: -(size.width / 2), y: radius, width: size.width, height: size.height)
        self.draw(in: rect, withAttributes: attributes)
        context.concatenate(r.inverted())
        context.concatenate(t.inverted())
    }
}

