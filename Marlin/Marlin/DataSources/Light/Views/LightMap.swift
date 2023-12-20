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

class LightMap<T: MapImage>: FetchRequestMap<T> {
    var defaultsShowLightRangesPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?
    var defaultsShowLightSectorRangesPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?

    override public init(fetchPredicate: NSPredicate? = nil, objects: [T]? = nil, showAsTiles: Bool = true) {
        super.init(fetchPredicate: fetchPredicate, objects: objects, showAsTiles: showAsTiles)
        self.sortDescriptors = [NSSortDescriptor(keyPath: \Light.featureNumber, ascending: true)]
        self.focusNotificationName = .FocusLight
        self.userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMaplight)
        self.defaultsShowLightRangesPublisher = UserDefaults.standard.publisher(for: \.actualRangeLights)
        self.defaultsShowLightSectorRangesPublisher = UserDefaults.standard.publisher(for: \.actualRangeSectorLights)
    }
    
    override func setupMixin(mapState: MapState, mapView: MKMapView) {
        super.setupMixin(mapState: mapState, mapView: mapView)
        
        defaultsShowLightRangesPublisher?
            .dropFirst()
            .removeDuplicates()
            .handleEvents(receiveOutput: { showLightRanges in
                print("Show light ranges: \(showLightRanges)")
            })
            .sink { [weak self] _ in
                self?.imageCache.clearCache(completion: {
                    self?.refreshOverlay(mapState: mapState)
                })
            }
            .store(in: &cancellable)
        
        defaultsShowLightSectorRangesPublisher?
            .removeDuplicates()
            .dropFirst()
            .handleEvents(receiveOutput: { showLightSectorRanges in
                print("Show light sector ranges: \(showLightSectorRanges)")
            })
            .sink { [weak self] _ in
                self?.imageCache.clearCache(completion: {
                    self?.refreshOverlay(mapState: mapState)
                })
            }
            .store(in: &cancellable)
        
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: Light.key)
    }
}
