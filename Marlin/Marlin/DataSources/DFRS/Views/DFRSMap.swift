//
//  DFRSMap.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class DFRSMap: FetchRequestMap<DFRS> {
    override public init(fetchRequest: NSFetchRequest<DFRS>? = nil, showAsTiles: Bool = true) {
        super.init(fetchRequest: fetchRequest, showAsTiles: showAsTiles)
        self.showKeyPath = \MapState.showDFRS
        self.sortDescriptors = [NSSortDescriptor(keyPath: \DFRS.stationNumber, ascending: true)]
        self.focusNotificationName = .FocusDFRS
        self.userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapdfrs)
        self.tilePredicate = NSPredicate(format: "rxPosition != nil OR txPosition != nil")
    }
    
    override func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        super.setupMixin(marlinMap: marlinMap, mapView: mapView)
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: DFRS.key)
    }
    
    override func getBoundingPredicate(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) -> NSPredicate {
        NSPredicate(
            format: "(rxPosition != nil AND rxLatitude >= %lf AND rxLatitude <= %lf AND rxLongitude >= %lf AND rxLongitude <= %lf) OR (txPosition != nil AND txLatitude >= %lf AND txLatitude <= %lf AND txLongitude >= %lf AND txLongitude <= %lf)", minLat, maxLat, minLon, maxLon, minLat, maxLat, minLon, maxLon
        )
    }
}
