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

class LightMap<T: LightProtocol & MapImage>: FetchRequestMap<T> {
    var userDefaultsShowLightRangesPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?
    var userDefaultsShowLightSectorRangesPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?

    
    override public init(fetchPredicate: NSPredicate? = nil, objects: [T]? = nil, showAsTiles: Bool = true) {
        super.init(fetchPredicate: fetchPredicate, objects: objects, showAsTiles: showAsTiles)
        self.showKeyPath = \MapState.showLights
        self.sortDescriptors = [NSSortDescriptor(keyPath: \Light.featureNumber, ascending: true)]
        self.focusNotificationName = .FocusLight
        self.userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMaplight)
        self.userDefaultsShowLightRangesPublisher = UserDefaults.standard.publisher(for: \.actualRangeLights)
        self.userDefaultsShowLightSectorRangesPublisher = UserDefaults.standard.publisher(for: \.actualRangeSectorLights)
    }
    
    override func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        super.setupMixin(marlinMap: marlinMap, mapView: mapView)
        
        userDefaultsShowLightRangesPublisher?
            .dropFirst()
            .removeDuplicates()
            .handleEvents(receiveOutput: { showLightRanges in
                print("Show light ranges: \(showLightRanges)")
            })
            .sink() { [weak self] _ in
                self?.imageCache.clearCache(completion: {
                    self?.refreshOverlay(marlinMap: marlinMap)
                })
            }
            .store(in: &cancellable)
        
        userDefaultsShowLightSectorRangesPublisher?
            .removeDuplicates()
            .dropFirst()
            .handleEvents(receiveOutput: { showLightSectorRanges in
                print("Show light sector ranges: \(showLightSectorRanges)")
            })
            .sink() { [weak self] _ in
                self?.imageCache.clearCache(completion: {
                    self?.refreshOverlay(marlinMap: marlinMap)
                })
            }
            .store(in: &cancellable)
        
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: Light.key)
    }
    
    override func getBoundingPredicate(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) -> NSPredicate {
        return NSPredicate(
            format: "characteristicNumber = 1 AND latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minLat, maxLat, minLon, maxLon
        )
    }
}
