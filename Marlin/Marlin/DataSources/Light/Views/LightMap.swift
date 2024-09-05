//
//  LightMap.swift
//  Marlin
//
//  Created by Daniel Barela on 7/11/22.
//

import Foundation
import MapKit
import Combine
import Kingfisher

class LightMap: DataSourceMap {

    override var minZoom: Int {
        get {
            return 2
        }
        set {

        }
    }

    var defaultsShowLightRangesPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?
    var defaultsShowLightSectorRangesPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?

    override init(repository: TileRepository? = nil, mapFeatureRepository: MapFeatureRepository? = nil) {
        super.init(repository: repository, mapFeatureRepository: mapFeatureRepository)

        orderPublisher = UserDefaults.standard.orderPublisher(key: DataSources.light.key)
        userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMaplight)
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
                Kingfisher.ImageCache(name: DataSources.light.key).clearCache(completion: {
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
                Kingfisher.ImageCache(name: DataSources.light.key).clearCache(completion: {
                    self?.refreshOverlay(mapState: mapState)
                })
            }
            .store(in: &cancellable)

    }
}
