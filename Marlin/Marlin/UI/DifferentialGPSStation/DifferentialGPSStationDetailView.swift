//
//  DifferentialGPSStationDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI
import MapKit
import CoreData

struct DifferentialGPSStationDetailView: View {
    @EnvironmentObject var dgpsRepository: DifferentialGPSStationRepositoryManager
    @StateObject var viewModel: DifferentialGPSStationViewModel = DifferentialGPSStationViewModel()
    @State var featureNumber: Int?
    @State var volumeNumber: String?
    @State var waypointURI: URL?

    var body: some View {
        Group {
            switch viewModel.differentialGPSStation {
            case nil:
                Color.clear.onAppear {
                    viewModel.repository = dgpsRepository
                    viewModel.getDifferentialGPSStation(
                        featureNumber: featureNumber,
                        volumeNumber: volumeNumber,
                        waypointURI: waypointURI
                    )
                }
            case .some(let differentialGPSStation):
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(differentialGPSStation.itemTitle)
                                .padding(.all, 8)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .itemTitle()
                                .foregroundColor(Color.white)
                                .background(Color(uiColor: differentialGPSStation.color))
                                .padding(.bottom, -8)
                            DataSourceLocationMapView(
                                dataSourceLocation: differentialGPSStation,
                                mapName: "DifferentialGPSStation Detail Map",
                                mixins: [
                                    DifferentialGPSStationMap<DifferentialGPSStationModel>(
                                        objects: [differentialGPSStation]
                                    )
                                ]
                            )
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                            DifferentialGPSStationSummaryView(differentialGPSStation: differentialGPSStation)
                                .showBookmarkNotes(true)
                                .setShowSectionHeader(true)
                                .setShowTitle(false)
                                .padding(.all, 16)
                        }
                        .card()
                    } header: {
                        EmptyView().frame(width: 0, height: 0, alignment: .leading)
                    }
                    .dataSourceSection()
                    
                    KeyValueSection(
                        sectionName: "Additional Information",
                        properties: differentialGPSStation.additionalKeyValues
                    )
                    .dataSourceSection()
                }
                .dataSourceDetailList()
            }
        }
        .navigationTitle("\(viewModel.differentialGPSStation?.name ?? DifferentialGPSStation.dataSourceName)" )
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: featureNumber) { _ in
            viewModel.getDifferentialGPSStation(
                featureNumber: featureNumber,
                volumeNumber: volumeNumber,
                waypointURI: waypointURI
            )
        }
        .onAppear {
            viewModel.repository = dgpsRepository
            viewModel.getDifferentialGPSStation(
                featureNumber: featureNumber,
                volumeNumber: volumeNumber,
                waypointURI: waypointURI
            )
            Metrics.shared.dataSourceDetail(dataSource: DifferentialGPSStation.definition)
        }
    }
}
