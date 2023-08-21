//
//  RouteMapView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/21/23.
//

import SwiftUI
import MapKit

struct RouteMapView: View {
    @Binding var path: NavigationPath

    let focusMapAtLocation = NotificationCenter.default.publisher(for: .FocusMapAtLocation)

    @StateObject var mixins: MainMapMixins = MainMapMixins()
    @StateObject var mapState: MapState = MapState()
    
    var body: some View {
        VStack {
            MarlinMap(name: "Marlin Map", mixins: mixins, mapState: mapState)
                .ignoresSafeArea()
        }
        .onReceive(focusMapAtLocation) { notification in
            mapState.forceCenter = notification.object as? MKCoordinateRegion
        }
        .overlay(bottomButtons(), alignment: .bottom)
        .overlay(topButtons(), alignment: .top)
    }
    
    @ViewBuilder
    func topButtons() -> some View {
        HStack(alignment: .top, spacing: 8) {
            // top left button stack
            VStack(alignment: .leading, spacing: 8) {
                SearchView(mapState: mapState)
            }
            .padding(.leading, 8)
            .padding(.top, 16)
            Spacer()
        }
    }
    
    @ViewBuilder
    func bottomButtons() -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            DataSourceToggles()
                .padding(.leading, 8)
                .padding(.bottom, 30)
            
            Spacer()
                .frame(maxWidth: .infinity)
            
            // bottom right button stack
            VStack(alignment: .trailing, spacing: 16) {
                UserTrackingButton(mapState: mapState)
                    .fixedSize()
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("User Tracking")
            }
            .padding(.trailing, 8)
            .padding(.bottom, 30)
        }
    }
}
