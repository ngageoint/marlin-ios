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

class DFRSMap<T: DFRS & MapImage>: FetchRequestMap<T> {
    override public init(fetchPredicate: NSPredicate? = nil, objects: [T]? = nil, showAsTiles: Bool = true) {
        super.init(fetchPredicate: fetchPredicate, showAsTiles: showAsTiles)
        self.sortDescriptors = [NSSortDescriptor(keyPath: \DFRS.stationNumber, ascending: true)]
        self.focusNotificationName = .FocusDFRS
        self.userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapdfrs)
        self.tilePredicate = NSPredicate(format: "rxPosition != nil OR txPosition != nil")
    }
    
    override func setupMixin(mapState: MapState, mapView: MKMapView) {
        super.setupMixin(mapState: mapState, mapView: mapView)
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: DFRS.key)
    }
}
