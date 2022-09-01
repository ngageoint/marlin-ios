//
//  LightMap.swift
//  Marlin
//
//  Created by Daniel Barela on 7/11/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class LightMap: FetchRequestMap<Light> {
    override public init(fetchRequest: NSFetchRequest<Light>? = nil, showAsTiles: Bool = true) {
        super.init(fetchRequest: fetchRequest, showAsTiles: showAsTiles)
        self.showKeyPath = \MapState.showLights
        self.sortDescriptors = [NSSortDescriptor(keyPath: \Light.featureNumber, ascending: true)]
        self.focusNotificationName = .FocusLight
        self.userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMaplight)
    }
    
    override func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        super.setupMixin(marlinMap: marlinMap, mapView: mapView)
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: Light.key)
    }
    
    override func getBoundingPredicate(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) -> NSPredicate {
        return NSPredicate(
            format: "characteristicNumber = 1 AND latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minLat, maxLat, minLon, maxLon
        )
    }
}
