//
//  AnnotationWithView.swift
//  Marlin
//
//  Created by Daniel Barela on 7/26/22.
//

import Foundation
import MapKit

protocol AnnotationWithView: MKAnnotation {
    var annotationView: MKAnnotationView? { get set }
    var color: UIColor { get }
    var clusteringIdentifier: String? { get set }
}
