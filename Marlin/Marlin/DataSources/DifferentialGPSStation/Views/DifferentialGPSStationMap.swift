//
//  DifferentialGPSStationMap.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class DifferentialGPSStationMap: FetchRequestMap<DifferentialGPSStation> {
    override public init(fetchPredicate: NSPredicate? = nil, showAsTiles: Bool = true) {
        super.init(fetchPredicate: fetchPredicate, showAsTiles: showAsTiles)
        self.showKeyPath = \MapState.showDifferentialGPSStations
        self.sortDescriptors = [NSSortDescriptor(keyPath: \DifferentialGPSStation.featureNumber, ascending: true)]
        self.focusNotificationName = .FocusDifferentialGPSStation
        self.userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapdifferentialGPSStation)
    }
    
    override func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        super.setupMixin(marlinMap: marlinMap, mapView: mapView)
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: DifferentialGPSStation.key)
    }
}
