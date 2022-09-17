//
//  DFRS+Annotation.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import CoreLocation
import MapKit

extension DFRS: MKAnnotation, AnnotationWithView {
    var clusteringIdentifier: String? {
        get { nil }
        set { }
    }
    
    var coordinate: CLLocationCoordinate2D {
        if CLLocationCoordinate2DIsValid(txCoordinate) {
            return txCoordinate
        } else if CLLocationCoordinate2DIsValid(rxCoordinate) {
            return rxCoordinate
        }
        return kCLLocationCoordinate2DInvalid
    }
    
    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: DFRS.key, for: self)
        self.annotationView = annotationView
        return annotationView
    }
}
