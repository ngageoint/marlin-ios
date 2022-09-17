//
//  Modu+Annotation.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import MapKit

extension Modu: MKAnnotation, AnnotationWithView {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: Modu.key, for: self)
        self.annotationView = annotationView
        return annotationView
    }
}
