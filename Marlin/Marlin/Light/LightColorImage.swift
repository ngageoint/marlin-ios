//
//  LightCircle.swift
//  Marlin
//
//  Created by Daniel Barela on 7/8/22.
//

import Foundation
import UIKit

struct LightSector {
    var startDegrees: Double
    var endDegrees: Double
    var color: UIColor
    var text: String
}

class LightColorImage : UIImage {
    
    convenience init?(frame: CGRect, colors: [UIColor], arcWidth: CGFloat? = nil, outerStroke: Bool = true, arcRadius: CGFloat? = nil, drawTower: Bool = true, darkMode: Bool = false) {
        let strokeWidth = 0.5
        let rect = frame
        let radius = arcRadius ?? min(rect.width / 2.0, rect.height / 2.0) - ((arcWidth ?? strokeWidth) / 2.0)
        let wholeColor = UIColor.lightGray
        let diameter = radius * 2.0
        
        let renderer = UIGraphicsImageRenderer(size: frame.size)
        let image = renderer.image { _ in
            // Fill full circle with wholeColor
            if arcWidth == nil {
                if outerStroke {

                    wholeColor.setStroke()
                    let outerBoundary = UIBezierPath(ovalIn: CGRect(x: strokeWidth / 2.0, y: strokeWidth / 2.0, width: diameter, height: diameter ))
                    outerBoundary.lineWidth = strokeWidth
                    outerBoundary.stroke()
                }
            }
            
            let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
            var count = 0
            let degreesPerColor = 360.0 / CGFloat(colors.count)
            for color in colors {
                let startAngle = degreesPerColor * CGFloat(count) * (CGFloat.pi / 180.0)
                let endAngle = degreesPerColor * (CGFloat(count) + 1.0) * (CGFloat.pi / 180.0)
                let piePath = UIBezierPath()
                piePath.addArc(withCenter: center, radius: radius,
                               startAngle: startAngle, endAngle: endAngle,
                               clockwise: true)
                

                if let arcWidth = arcWidth {
                    piePath.lineWidth = arcWidth
                    color.setStroke()
                    piePath.stroke()
                    if drawTower {
                        let towerLine = UIBezierPath()
                        towerLine.move(to: center)
                        
                        towerLine.addLine(to: CGPoint(x: center.x, y: center.y - radius))
                        towerLine.lineWidth = arcWidth
                        towerLine.stroke()
                    }
                } else {
                    piePath.close()
                    color.setFill()
                    piePath.fill()
                }
                count += 1
            }
        }
        
        guard  let cgImage = image.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
        
    }
    
    convenience init?(frame: CGRect, sectors: [LightSector], arcWidth: CGFloat? = nil, arcRadius: CGFloat? = nil, outerStroke: Bool = true, includeSectorDashes: Bool = false, includeLetters: Bool = true, darkMode: Bool = false) {
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
                if outerStroke {
                    wholeColor.setStroke()

                    let outerBoundary = UIBezierPath(ovalIn: CGRect(x: strokeWidth / 2.0, y: strokeWidth / 2.0, width: diameter, height: diameter ))
                    outerBoundary.lineWidth = strokeWidth
                    outerBoundary.stroke()
                }
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
                    
                    let endDegrees = sector.endDegrees > sector.startDegrees ? sector.endDegrees : sector.endDegrees + 360.0
                    let midPointAngle = CGFloat(sector.startDegrees) + CGFloat(endDegrees - sector.startDegrees) / 2.0
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
    
}
