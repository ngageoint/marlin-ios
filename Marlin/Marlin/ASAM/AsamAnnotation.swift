//
//  AsamAnnotation.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MapKit

class AsamAnnotationView: MKAnnotationView {
    static let ReuseID = "asam"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        if let annotation = annotation as? EnlargableAnnotation, !annotation.shouldEnlarge {
            self.clusteringIdentifier = annotation.clusteringIdentifier
        }
        let image = UIImage(named: "asam_marker")
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
