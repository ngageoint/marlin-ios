//
//  PortMap.swift
//  Marlin
//
//  Created by Daniel Barela on 8/23/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class PortMap<T: MapImage>: FetchRequestMap<T> {
    override public init(fetchPredicate: NSPredicate? = nil, objects: [T]? = nil, showAsTiles: Bool = true) {
        super.init(fetchPredicate: fetchPredicate, objects: objects, showAsTiles: showAsTiles)
        self.sortDescriptors = [NSSortDescriptor(keyPath: \Port.portNumber, ascending: true)]
        self.focusNotificationName = .FocusPort
        self.userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapport)
    }
    
    override func setupMixin(mapState: MapState, mapView: MKMapView) {
        super.setupMixin(mapState: mapState, mapView: mapView)
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: Port.key)
    }
}
