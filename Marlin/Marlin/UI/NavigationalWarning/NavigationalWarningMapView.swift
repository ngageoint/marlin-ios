//
//  NavigationalWarningMapView.swift
//  Marlin
//
//  Created by Daniel Barela on 5/24/23.
//

import SwiftUI

struct NavigationalWarningMapView<Content: View>: View {
    @EnvironmentObject var navigationalWarningsMapFeatureRepository: NavigationalWarningsMapFeatureRepository
    @ViewBuilder var bottomButtons: Content
    @StateObject var mixins: NavigationalMapMixins = NavigationalMapMixins()
    @StateObject var mapState: MapState = MapState()
    
    var body: some View {
        MarlinMap(name: "Navigational Warning List View Map", mixins: mixins, mapState: mapState)
            .overlay(alignment: .bottom) {
                HStack(alignment: .bottom, spacing: 0) {
                    Spacer()
                    VStack {
                        bottomButtons
                        UserTrackingButton(mapState: mapState)
                            .fixedSize()
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("User Tracking")
                    }
                }
                .padding(.trailing, 8)
                .padding(.bottom, 30)
            }
            .onAppear {
                mixins.setMapFeatureRepository(mapFeatureRepository: navigationalWarningsMapFeatureRepository)
            }
    }
}
