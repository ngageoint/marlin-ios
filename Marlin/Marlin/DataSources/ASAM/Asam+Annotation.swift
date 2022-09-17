//
//  Asam+Annotation.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import MapKit
import CoreLocation

extension Asam: MKAnnotation, AnnotationWithView {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: Asam.key, for: self)
        self.annotationView = annotationView
        return annotationView
    }
}
