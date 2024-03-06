//
//  DGPSStationList.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import SwiftUI

struct DGPSStationList: View {
    @EnvironmentObject var dgpsStationRepository: DGPSStationRepository
    @StateObject var viewModel: DGPSStationsViewModel = DGPSStationsViewModel()

    @EnvironmentObject var router: MarlinRouter

    @State var sortOpen: Bool = false
    @State var filterOpen: Bool = false
    @State var filterViewModel: FilterViewModel = PersistedFilterViewModel(
        dataSource: DataSources.filterableFromDefintion(DataSources.dgps)
    )

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                VStack(alignment: .center, spacing: 16) {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Image("dgps")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding([.trailing, .leading], 24)
                            .foregroundColor(Color.onSurfaceColor)
                        Spacer()
                    }
                    Text("Loading Differential GPS Stations")
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                    ProgressView()
                        .tint(Color.primaryColorVariant)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.backgroundColor)
                .transition(AnyTransition.opacity)
                .accessibilityElement()
                .accessibilityLabel("\(DataSources.dgps.key) Loading")
            case let .loaded(rows: rows):
                ZStack(alignment: .bottomTrailing) {
                    List(rows) { dgpsItem in
                        switch dgpsItem {
                        case .listItem(let dgps):
                            DGPSStationSummaryView(
                                dgpsStation: DGPSStationListModel(
                                    dgpsStationModel: dgps)
                            )
                            .showBookmarkNotes(true)
                            .paddedCard()
                            .onAppear {
                                if rows.last == dgpsItem {
                                    viewModel.loadMore()
                                }
                            }
                            .onTapGesture {
                                if let featureNumber = dgps.featureNumber, let volumeNumber = dgps.volumeNumber {
                                    router.path.append(
                                        DGPSStationRoute.detail(
                                            featureNumber: featureNumber,
                                            volumeNumber: volumeNumber
                                        )
                                    )
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.backgroundColor)
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("\(DataSources.dgps.key) \(dgps.itemKey)")
                        case .sectionHeader(let header):
                            Text(header)
                                .onAppear {
                                    if rows.last == dgpsItem {
                                        viewModel.loadMore()
                                    }
                                }
                                .sectionHeader()
                        }

                    }
                    .listStyle(.plain)
                    .listSectionSeparator(.hidden)
                    .refreshable {
                        viewModel.reload()
                    }
                }
                .emptyPlaceholder(rows) {
                    VStack(alignment: .center, spacing: 16) {
                        HStack(alignment: .center, spacing: 0) {
                            Spacer()
                            Image("dgps")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .padding([.trailing, .leading], 24)
                                .foregroundColor(Color.onSurfaceColor)
                            Spacer()
                        }
                        Text("No Differential GPS Stations match this filter")
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.backgroundColor)
                }
                .transition(AnyTransition.opacity)
            case let .failure(error: error):
                Text(error.localizedDescription)
            }
        }
        .navigationTitle(DataSources.dgps.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.backgroundColor)
        .foregroundColor(Color.onSurfaceColor)
        .onChange(of: filterOpen) { filterOpen in
            if !filterOpen {
                viewModel.reload()
            }
        }
        .onChange(of: sortOpen) { sortOpen in
            if !sortOpen {
                viewModel.reload()
            }
        }
        .onAppear {
            viewModel.repository = dgpsStationRepository
            Metrics.shared.dataSourceList(dataSource: DataSources.dgps)
        }
        .modifier(
            DataSourceFilterAndSort(
                filterOpen: $filterOpen,
                sortOpen: $sortOpen,
                filterViewModel: filterViewModel,
                allowSorting: true,
                allowFiltering: true)
        )
    }
}
