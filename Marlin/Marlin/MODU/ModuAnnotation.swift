//
//  ModuAnnotation.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import Foundation
import MapKit

class ModuAnnotation: NSObject, MKAnnotation, Identifiable {
    var coordinate: CLLocationCoordinate2D
    var modu: Modu
    var annotationView: MKAnnotationView?
    var id: ObjectIdentifier
    
    init(modu: Modu) {
        self.modu = modu
        self.id = modu.id
        if let latitude = modu.latitude, let longitude = modu.longitude {
            coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
        } else {
            coordinate = kCLLocationCoordinate2DInvalid
        }
    }
    
    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: ModuAnnotationView.ReuseID, for: self)
        
        annotationView.image = UIImage(named: "modu_marker")
        self.annotationView = annotationView
        return annotationView
    }
}

class ModuAnnotationView: MKAnnotationView {
    static let ReuseID = "modu"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//        clusteringIdentifier = "modu"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
