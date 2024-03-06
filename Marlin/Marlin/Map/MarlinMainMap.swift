//
//  MarlinMainMap.swift
//  Marlin
//
//  Created by Daniel Barela on 5/23/23.
//

import SwiftUI
import MapKit

struct MarlinMainMap: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @EnvironmentObject var routeRepository: RouteRepository
    @EnvironmentObject var asamsTileRepository: AsamsTileRepository
    @EnvironmentObject var modusTileRepository: ModusTileRepository
    @EnvironmentObject var portsTileRepository: PortsTileRepository
    @EnvironmentObject var lightsTileRepository: LightsTileRepository
    @EnvironmentObject var radioBeaconsTileRepository: RadioBeaconsTileRepository
    @EnvironmentObject var differentialGPSStationsTileRepository: DifferentialGPSStationsTileRepository
    @EnvironmentObject var navigationalWarningsMapFeatureRepository: NavigationalWarningsMapFeatureRepository

    @StateObject var mixins: MainMapMixins = MainMapMixins()
    @StateObject var mapState: MapState = MapState()
        
    @EnvironmentObject var dataSourceList: DataSourceList
    
    var showSettings: Bool = true
    var showExport: Bool = true
    
    let focusMapAtLocation = NotificationCenter.default.publisher(for: .FocusMapAtLocation)
    let longPressPub = NotificationCenter.default.publisher(for: .MapLongPress)

    var body: some View {
        VStack {
            MarlinMap(name: "Marlin Map", mixins: mixins, mapState: mapState)
                .ignoresSafeArea()
        }
        .onReceive(focusMapAtLocation) { notification in
            mapState.forceCenter = notification.object as? MKCoordinateRegion
        }
        .overlay(alignment: .bottom) {
            bottomButtons()
        }
        .overlay(alignment: .top) {
            topButtons()
        }
        .onAppear {
            mixins.addRouteMixin(routeRepository: routeRepository)
            mixins.addAsamTileRepository(tileRepository: asamsTileRepository)
            mixins.addModuTileRepository(tileRepository: modusTileRepository)
            mixins.addPortTileRepository(tileRepository: portsTileRepository)
            mixins.addLightTileRepository(tileRepository: lightsTileRepository)
            mixins.addRadioBeaconTileRepository(tileRepository: radioBeaconsTileRepository)
            mixins.addDifferentialGPSStationTileRepository(tileRepository: differentialGPSStationsTileRepository)
            mixins.addNavigationalWarningsMapFeatureRepository(
                mapFeatureRepository: navigationalWarningsMapFeatureRepository
            )
        }
    }
    
    @ViewBuilder
    func topButtons() -> some View {
        HStack(alignment: .top, spacing: 8) {
            // top left button stack
            VStack(alignment: .leading, spacing: 8) {
                switch mapState.searchType {
                case .native:
                    SearchView<NativeSearchProvider>(mapState: mapState)
                case .nominatim:
                    SearchView<NominatimSearchProvider>(mapState: mapState)
                }
            }
            .padding(.leading, 8)
            .padding(.top, 16)
            Spacer()
            // top right button stack
            VStack(alignment: .trailing, spacing: 16) {
                if showSettings {
                    NavigationLink(value: MarlinRoute.mapSettings) {
                        Label(
                            title: {},
                            icon: { Image(systemName: "square.3.stack.3d")
                                    .renderingMode(.template)
                            }
                        )
                    }
                    .isDetailLink(false)
                    .fixedSize()
                    .buttonStyle(
                        MaterialFloatingButtonStyle(
                            type: .secondary,
                            size: .mini,
                            foregroundColor: Color.primaryColorVariant,
                            backgroundColor: Color.mapButtonColor
                        )
                    )
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Map Settings Button")
                }
            }
            .padding(.trailing, 8)
            .padding(.top, 16)
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
                if showExport {
                    NavigationLink(value: MarlinRoute.exportGeoPackage(useMapRegion: true)) {
                        Label(
                            title: {},
                            icon: { Image(systemName: "square.and.arrow.down")
                                    .renderingMode(.template)
                            }
                        )
                    }
                    .isDetailLink(false)
                    .fixedSize()
                    .buttonStyle(
                        MaterialFloatingButtonStyle(
                            type: .secondary,
                            size: .mini,
                            foregroundColor: Color.primaryColorVariant,
                            backgroundColor: Color.mapButtonColor
                        )
                    )
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Export Button")
                }
                
                UserTrackingButton(mapState: mapState)
                    .fixedSize()
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("User Tracking")
//                CreateUserPlaceButton()
            }
            .padding(.trailing, 8)
            .padding(.bottom, 30)
        }
    }
}
