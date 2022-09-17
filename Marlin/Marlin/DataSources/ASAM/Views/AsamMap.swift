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

class AsamMap: FetchRequestMap<Asam> {
    override public init(fetchRequest: NSFetchRequest<Asam>? = nil, showAsTiles: Bool = true) {
        super.init(fetchRequest: fetchRequest, showAsTiles: showAsTiles)
        self.showKeyPath = \MapState.showAsams
        self.sortDescriptors = [NSSortDescriptor(keyPath: \Asam.date, ascending: true)]
        self.focusNotificationName = .FocusAsam
        self.userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapasam)
    }
    
    override func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        super.setupMixin(marlinMap: marlinMap, mapView: mapView)
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: Asam.key)
    }
}
