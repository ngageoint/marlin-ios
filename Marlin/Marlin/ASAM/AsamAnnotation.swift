//
//  AsamAnnotation.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MapKit

protocol AnnotationWithView {
    var annotationView: MKAnnotationView? { get set }
}

class AsamAnnotationView: MKAnnotationView {
    static let ReuseID = "asam"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "msi"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
