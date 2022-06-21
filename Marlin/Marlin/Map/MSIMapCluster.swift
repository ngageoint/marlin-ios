//
//  MSIMapCluster.swift
//  Marlin
//
//  Created by Daniel Barela on 6/21/22.
//

import Foundation
import MapKit

final class ClusterAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// - Tag: CustomCluster
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        updateImage()
    }
    
    override var annotation: MKAnnotation? { didSet { updateImage() } }
    
    private func updateImage() {
        if let cluster = annotation as? MKClusterAnnotation {
            let totalBikes = cluster.memberAnnotations.count
            let counts = cluster.memberAnnotations.reduce(into: [UIColor:Int]()) { partialResult, annotation in
                if let annotation = annotation as? AnnotationWithView {
                    partialResult[annotation.color] = (partialResult[annotation.color] ?? 0)+1
                }
            }
            
            image = drawRatios(ratios: counts, totalCount: totalBikes) //drawRatioAsamToModu(asamCount, to: totalBikes)
            displayPriority = .defaultHigh
        }
    }
    
    private func drawRatios(ratios: [UIColor: Int], totalCount: Int) -> UIImage {
        let wholeColor = UIColor.white
        let diameter: CGFloat = {
            if totalCount < 10 {
                return 40.0
            } else if totalCount < 100 {
                return 50.0
            } else {
                return 60.0
            }
        }()
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter+4, height: diameter+4))
        return renderer.image { _ in
            // Fill full circle with wholeColor
            wholeColor.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: diameter+4, height: diameter+4)).fill()
            
            var startAngle: CGFloat = 0.0
            
            for fraction in ratios {
                let endAngle = startAngle + ((CGFloat.pi * 2.0 * CGFloat(fraction.value)) / CGFloat(totalCount))
                // Fill pie with fractionColor
                fraction.key.setFill()
                let piePath = UIBezierPath()
                piePath.addArc(withCenter: CGPoint(x: 2 + diameter/2.0, y: 2 + diameter/2.0), radius: (diameter/2.0),
                               startAngle: startAngle, endAngle: endAngle,
                               clockwise: true)
                piePath.addLine(to: CGPoint(x: diameter/2.0, y: diameter/2.0))
                piePath.close()
                piePath.fill()
                startAngle = endAngle
            }
            
            // Fill inner circle with white color
            let innerColor: UIColor = {
                if totalCount < 20 {
                    return .systemBlue
                } else if totalCount < 100 {
                    return .systemTeal
                } else if totalCount < 500 {
                    return .systemMint
                } else {
                    return .systemRed
                }
            }()
            innerColor.setFill()
            UIBezierPath(ovalIn: CGRect(x: 10, y: 10, width: diameter - 16, height: diameter - 16)).fill()
            
            // Finally draw count text vertically and horizontally centered
            let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.white,
                               NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)]
            let text = "\(totalCount)"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: 2.0 + (diameter/2.0) - size.width / 2, y: 2.0 + (diameter/2.0) - size.height / 2, width: size.width, height: size.height)
            text.draw(in: rect, withAttributes: attributes)

        }
    }
}
