//
//  ModuAnnotation.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import Foundation
import MapKit

class ModuAnnotationView: MKAnnotationView {
    static let ReuseID = "modu"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        if let annotation = annotation as? AnnotationWithView {
            self.clusteringIdentifier = annotation.clusteringIdentifier
        }
        let image = UIImage(named: "modu_marker")
        self.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? EnlargableAnnotation else {
                if let annotation = newValue as? AnnotationWithView {
                    clusteringIdentifier = annotation.clusteringIdentifier
                }
                return
            }
            clusteringIdentifier = ((annotation.enlarged || annotation.shouldEnlarge) && !annotation.shouldShrink) ? nil : annotation.clusteringIdentifierWhenShrunk
            if let image = image {
                self.centerOffset = CGPoint(x: 0, y: -(image.size.height/2.0))
            } else {
                self.center = CGPoint(x: 0, y: self.center.y / 2.0)
            }
        }
    }
}
