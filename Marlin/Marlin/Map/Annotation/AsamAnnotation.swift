//
//  AsamAnnotation.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MapKit

class AsamAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var asam: Asam
    var annotationView: MKAnnotationView?
    
    init(asam: Asam) {
        self.asam = asam
        if let latitude = asam.latitude, let longitude = asam.longitude {
            coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
        } else {
            coordinate = kCLLocationCoordinate2DInvalid
        }
    }
    
    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: "asam", for: self)
        
        annotationView.image = UIImage(named: "asam_marker")
        self.annotationView = annotationView
        return annotationView
    }
}

class AsamAnnotationView: MKAnnotationView {

}
