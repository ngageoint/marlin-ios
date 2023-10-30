//
//  DataSourceLocationMapView.swift
//  Marlin
//
//  Created by Daniel Barela on 5/22/23.
//

import Foundation
import SwiftUI
import MapKit

struct DataSourceLocationMapView: View {
    var dataSourceLocation: any Locatable
    @StateObject var mapState: MapState = MapState()
    @StateObject private var mapMixins: MapMixins = MapMixins()
    var mapName: String
    var mixins: [MapMixin]
    
    var body: some View {
        Self._printChanges()
        return MarlinMap(name: mapName, mixins: mapMixins, mapState: mapState, allowMapTapsOnItems: false)
            .onAppear {
                mapMixins.mixins.append(contentsOf: mixins + [UserLayersMap()])
                if let region = dataSourceLocation.coordinateRegion {
                    mapState.center = region.padded(percent: 0.1, maxDelta: 45)
                } else {
                    mapState.center = MKCoordinateRegion(center: dataSourceLocation.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                }
            }
    }
}
