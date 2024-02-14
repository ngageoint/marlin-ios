//
//  RadioBeaconDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/25/22.
//

import SwiftUI
import MapKit
import CoreData

struct RadioBeaconDetailView: View {
    @EnvironmentObject var radioBeaconRepository: RadioBeaconRepository
    @EnvironmentObject var routeWaypointRepository: RouteWaypointRepository
    @StateObject var viewModel: RadioBeaconViewModel = RadioBeaconViewModel()
    @State var featureNumber: Int?
    @State var volumeNumber: String?
    @State var waypointURI: URL?
    
    var body: some View {
        Group {
            switch viewModel.radioBeacon {
            case nil:
                Color.clear.onAppear {
                    viewModel.routeWaypointRepository = routeWaypointRepository
                    viewModel.repository = radioBeaconRepository
                    viewModel.getRadioBeacon(
                        featureNumber: featureNumber,
                        volumeNumber: volumeNumber,
                        waypointURI: waypointURI
                    )
                }
            case .some(let radioBeacon):
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(radioBeacon.itemTitle)
                                .padding(.all, 8)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .itemTitle()
                                .foregroundColor(Color.white)
                                .background(Color(uiColor: DataSources.radioBeacon.color))
                                .padding(.bottom, -8)
                            DataSourceLocationMapView(
                                dataSourceLocation: radioBeacon,
                                mapName: "Radio Beacon Detail Map",
                                mixins: [
                                    RadioBeaconMap(
                                        repository: RadioBeaconTileRepository(
                                            featureNumber: radioBeacon.featureNumber ?? 0,
                                            volumeNumber: radioBeacon.volumeNumber ?? "",
                                            localDataSource: radioBeaconRepository.localDataSource
                                        )
                                    )
                                ]
                            )
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                            RadioBeaconSummaryView(radioBeacon: RadioBeaconListModel(radioBeaconModel: radioBeacon))
                                .showBookmarkNotes(true)
                                .setShowSectionHeader(true)
                                .padding(.all, 16)
                        }
                        .card()
                    } header: {
                        EmptyView().frame(width: 0, height: 0, alignment: .leading)
                    }
                    .dataSourceSection()
                    
                    KeyValueSection(sectionName: "Additional Information", properties: radioBeacon.additionalKeyValues)
                        .dataSourceSection()
                }
                .dataSourceDetailList()
            }
        }
        .navigationTitle("\(viewModel.radioBeacon?.name ?? DataSources.radioBeacon.fullName)" )
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: featureNumber) { newFeatureNumber in
            viewModel.getRadioBeacon(
                featureNumber: newFeatureNumber,
                volumeNumber: volumeNumber,
                waypointURI: waypointURI
            )
        }
        .onChange(of: volumeNumber) { newVolumeNumber in
            viewModel.getRadioBeacon(
                featureNumber: featureNumber,
                volumeNumber: newVolumeNumber,
                waypointURI: waypointURI
            )
        }
        .onAppear {
            Metrics.shared.dataSourceDetail(dataSource: DataSources.radioBeacon)
        }
    }
}
