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
        let currentOffset = annotationView.centerOffset
        annotationView.transform = annotationView.transform.scaledBy(x: 2.0, y: 2.0)
        annotationView.centerOffset = CGPoint(x: currentOffset.x * 2.0, y: currentOffset.y * 2.0)
    }
    
    func shrinkAnnotation() {
        guard let annotationView = annotationView else {
            return
        }
        enlarged = false
        shouldShrink = false
        annotationView.clusteringIdentifier = clusteringIdentifier
        let currentOffset = annotationView.centerOffset
        annotationView.transform = annotationView.transform.scaledBy(x: 0.5, y: 0.5)
        annotationView.centerOffset = CGPoint(x: currentOffset.x * 0.5, y: currentOffset.y * 0.5)
    }
}
