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
    @EnvironmentObject var radioBeaconRepository: RadioBeaconRepositoryManager
    @StateObject var viewModel: RadioBeaconViewModel = RadioBeaconViewModel()
    @State var featureNumber: Int?
    @State var volumeNumber: String?
    @State var waypointURI: URL?
    
    var body: some View {
        Text("HI")
//        Group {
//            switch viewModel.radioBeacon {
//            case nil:
//                Color.clear.onAppear {
//                    viewModel.repository = radioBeaconRepository
//                    viewModel.getRadioBeacon(
//                        featureNumber: featureNumber,
//                        volumeNumber: volumeNumber,
//                        waypointURI: waypointURI
//                    )
//                }
//            case .some(let radioBeacon):
//                List {
//                    Section {
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text(radioBeacon.itemTitle)
//                                .padding(.all, 8)
//                                .multilineTextAlignment(.leading)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .itemTitle()
//                                .foregroundColor(Color.white)
//                                .background(Color(uiColor: radioBeacon.color))
//                                .padding(.bottom, -8)
//                            DataSourceLocationMapView(
//                                dataSourceLocation: radioBeacon,
//                                mapName: "Radio Beacon Detail Map",
//                                mixins: [RadioBeaconMap<RadioBeaconModel>(objects: [radioBeacon])]
//                            )
//                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
//                            RadioBeaconSummaryView(radioBeacon: radioBeacon)
//                                .showBookmarkNotes(true)
//                                .setShowSectionHeader(true)
//                                .padding(.all, 16)
//                        }
//                        .card()
//                    } header: {
//                        EmptyView().frame(width: 0, height: 0, alignment: .leading)
//                    }
//                    .dataSourceSection()
//                    
//                    KeyValueSection(sectionName: "Additional Information", properties: radioBeacon.additionalKeyValues)
//                        .dataSourceSection()
//                }
//                .dataSourceDetailList()
//            }
//        }
//        .navigationTitle("\(viewModel.radioBeacon?.name ?? DataSources.radioBeacon.fullName)" )
//        .navigationBarTitleDisplayMode(.inline)
//        .onChange(of: featureNumber) { _ in
//            viewModel.getRadioBeacon(featureNumber: featureNumber, volumeNumber: volumeNumber, waypointURI: waypointURI)
//        }
//        .onAppear {
//            viewModel.repository = radioBeaconRepository
//            viewModel.getRadioBeacon(featureNumber: featureNumber, volumeNumber: volumeNumber, waypointURI: waypointURI)
//            Metrics.shared.dataSourceDetail(dataSource: RadioBeacon.definition)
//        }
    }
}
