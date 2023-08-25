//
//  AsamMap.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class AsamMap<T: Asam & MapImage>: FetchRequestMap<T> {
    override public init(fetchPredicate: NSPredicate? = nil, objects: [T]? = nil, showAsTiles: Bool = true) {
        super.init(fetchPredicate: fetchPredicate, showAsTiles: showAsTiles)
        self.sortDescriptors = [NSSortDescriptor(keyPath: \Asam.date, ascending: true)]
        self.focusNotificationName = .FocusAsam
        self.userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapasam)
    }
    
    override func setupMixin(mapState: MapState, mapView: MKMapView) {
        super.setupMixin(mapState: mapState, mapView: mapView)
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: Asam.key)
    }
}
