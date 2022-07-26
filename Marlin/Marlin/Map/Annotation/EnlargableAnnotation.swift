//
//  EnlargableAnnotation.swift
//  Marlin
//
//  Created by Daniel Barela on 7/26/22.
//

import Foundation
import MapKit

protocol EnlargableAnnotation: AnnotationWithView {
    var enlarged: Bool { get set }
    var shouldEnlarge: Bool { get set }
    var shouldShrink: Bool { get set }
    var clusteringIdentifierWhenShrunk: String? { get }
    var clusteringIdentifier: String? { get set }
    func enlargeAnnoation()
    func shrinkAnnotation()
    func markForEnlarging()
}

extension EnlargableAnnotation {
    func markForEnlarging() {
        clusteringIdentifier = nil
        shouldEnlarge = true
    }
    
    func markForShrinking() {
        clusteringIdentifier = clusteringIdentifierWhenShrunk
        shouldShrink = true
    }
    
    func enlargeAnnoation() {
        guard let annotationView = annotationView else {
            return
        }
        enlarged = true
        shouldEnlarge = false
        annotationView.clusteringIdentifier = nil
        annotationView.transform = annotationView.transform.scaledBy(x: 2.0, y: 2.0)
        if let image = annotationView.image {
            annotationView.centerOffset = CGPoint(x: 0, y: -(image.size.height))
        } else {
            annotationView.centerOffset = CGPoint(x: 0, y: annotationView.center.y * 2.0)
        }
    }
    
    func shrinkAnnotation() {
        guard let annotationView = annotationView else {
            return
        }
        enlarged = false
        shouldShrink = false
        annotationView.clusteringIdentifier = clusteringIdentifier
        annotationView.transform = annotationView.transform.scaledBy(x: 0.5, y: 0.5)
        if let image = annotationView.image {
            annotationView.centerOffset = CGPoint(x: 0, y: -(image.size.height / 2.0))
        } else {
            annotationView.center = CGPoint(x: 0, y: annotationView.center.y / 2.0)
        }
    }
}
