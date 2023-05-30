//
//  MarlinMainMap.swift
//  Marlin
//
//  Created by Daniel Barela on 5/23/23.
//

import SwiftUI

struct MarlinMainMap: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    
    @StateObject var mixins: MainMapMixins = MainMapMixins()
    @StateObject var mapState: MapState = MapState()
    
    @Binding var selection: String?
    
    @EnvironmentObject var dataSourceList: DataSourceList
    
    var body: some View {
        Self._printChanges()
        return VStack {
            MarlinMap(name: "Marlin Map", mixins: mixins, mapState: mapState)
                .ignoresSafeArea()
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
            // top right button stack
            VStack(alignment: .trailing, spacing: 16) {
                NavigationLink(tag: "mapSettings", selection: $selection) {
                    MapSettings(mapState: mapState)
                } label: {
                    Label(
                        title: {},
                        icon: { Image(systemName: "square.3.stack.3d")
                                .renderingMode(.template)
                        }
                    )
                }
                .isDetailLink(false)
                .fixedSize()
                .buttonStyle(MaterialFloatingButtonStyle(type: .secondary, size: .mini, foregroundColor: Color.primaryColorVariant, backgroundColor: Color.mapButtonColor))
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Map Settings Button")
            }
            .padding(.trailing, 8)
            .padding(.top, 16)
        }
    }
    
    @ViewBuilder
    func bottomButtons() -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            if verticalSizeClass != .compact {
                VStack(alignment: .leading, spacing: 8) {
                    DataSourceToggles()
                }
                .padding(.leading, 8)
                .padding(.bottom, 30)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    DataSourceToggles()
                }
                .padding(.leading, 8)
                .padding(.bottom, 30)
            }
            
            Spacer()
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