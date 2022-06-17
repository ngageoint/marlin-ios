//
//  AsamAnnotation.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MapKit

class AsamAnnotation: NSObject, MKAnnotation, Identifiable {
    var coordinate: CLLocationCoordinate2D
    var asam: Asam
    var annotationView: MKAnnotationView?
    var id: ObjectIdentifier
    
    init(asam: Asam) {
        self.asam = asam
        self.id = asam.id
        if let latitude = asam.latitude, let longitude = asam.longitude {
            coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
        } else {
            coordinate = kCLLocationCoordinate2DInvalid
        }
    }
    
    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: AsamAnnotationView.ReuseID, for: self)
        
        annotationView.image = UIImage(named: "asam_marker")
        self.annotationView = annotationView
        return annotationView
    }
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
