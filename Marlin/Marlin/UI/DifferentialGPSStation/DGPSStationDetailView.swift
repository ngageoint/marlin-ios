//
//  DGPSStationDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI
import MapKit
import CoreData

struct DGPSStationDetailView: View {
    @EnvironmentObject var routeWaypointRepository: RouteWaypointRepository

    @StateObject var viewModel: DGPSStationViewModel = DGPSStationViewModel()
    @State var featureNumber: Int?
    @State var volumeNumber: String?
    @State var waypointURI: URL?

    var body: some View {
        Group {
            switch viewModel.dgpsStation {
            case nil:
                Color.clear.task {
                    await viewModel.getDGPSStation(
                        featureNumber: featureNumber,
                        volumeNumber: volumeNumber,
                        waypointURI: waypointURI
                    )
                }
            case .some(let dgpsStation):
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(dgpsStation.itemTitle)
                                .padding(.all, 8)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .itemTitle()
                                .foregroundColor(Color.white)
                                .background(Color(uiColor: DataSources.dgps.color))
                                .padding(.bottom, -8)
                            DataSourceLocationMapView(
                                dataSourceLocation: dgpsStation,
                                mapName: "DifferentialGPSStation Detail Map",
                                mixins: [
                                    DGPSStationMap(
                                        repository: DGPSStationTileRepository(
                                            featureNumber: dgpsStation.featureNumber ?? -1,
                                            volumeNumber: dgpsStation.volumeNumber ?? ""
                                        )
                                    )
                                ]
                            )
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                            DGPSStationSummaryView(
                                showBookmarkNotes: true, dgpsStation: DGPSStationListModel(
                                    dgpsStationModel: dgpsStation),
                                showSectionHeader: true,
                                showTitle: true
                            )
//                            .showBookmarkNotes(true)
//                            .setShowSectionHeader(true)
//                            .setShowTitle(false)
                            .padding(.all, 16)
                        }
                        .card()
                    } header: {
                        EmptyView().frame(width: 0, height: 0, alignment: .leading)
                    }
                    .dataSourceSection()
                    
                    KeyValueSection(
                        sectionName: "Additional Information",
                        properties: dgpsStation.additionalKeyValues
                    )
                    .dataSourceSection()
                }
                .dataSourceDetailList()
            }
        }
        .navigationTitle("\(viewModel.dgpsStation?.name ?? DataSources.dgps.fullName)" )
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: featureNumber) { _ in
            Task {
                await viewModel.getDGPSStation(
                    featureNumber: featureNumber,
                    volumeNumber: volumeNumber,
                    waypointURI: waypointURI
                )
            }
        }
        .onAppear {
            Metrics.shared.dataSourceDetail(dataSource: DataSources.dgps)
        }
    }
}
