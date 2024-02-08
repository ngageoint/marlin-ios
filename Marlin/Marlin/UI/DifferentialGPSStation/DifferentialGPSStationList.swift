//
//  DifferentialGPSStationList.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import SwiftUI

struct DifferentialGPSStationList: View {
    @EnvironmentObject var differentialGPSStationRepository: DifferentialGPSStationRepository
    @StateObject var viewModel: DifferentialGPSStationsViewModel = DifferentialGPSStationsViewModel()

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
            case let .loaded(rows: rows):
                ZStack(alignment: .bottomTrailing) {
                    List(rows) { dgpsItem in
                        switch dgpsItem {
                        case .listItem(let dgps):
                            DifferentialGPSStationSummaryView(
                                differentialGPSStation: DifferentialGPSStationListModel(
                                    differentialGPSStationModel: dgps)
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
                                        DifferentialGPSStationRoute.detail(
                                            featureNumber: featureNumber,
                                            volumeNumber: volumeNumber
                                        )
                                    )
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.backgroundColor)
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
            viewModel.repository = differentialGPSStationRepository
            Metrics.shared.dataSourceList(dataSource: DataSources.dgps)
        }
        .modifier(
            FilterButton(
                filterOpen: $filterOpen,
                sortOpen: $sortOpen,
                dataSources: Binding.constant([
                    DataSourceItem(dataSource: DataSources.dgps)
                ]),
                allowSorting: true,
                allowFiltering: true)
        )
        .background {
            DataSourceFilter(filterViewModel: filterViewModel, showBottomSheet: $filterOpen)
        }
        .sheet(isPresented: $sortOpen) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        SortView(definition: DataSources.dgps)
                            .background(Color.surfaceColor)

                        Spacer()
                    }

                }
                .navigationTitle("\(DataSources.dgps.name) Sort")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.backgroundColor)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(
                            action: {
                                sortOpen.toggle()
                            },
                            label: {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(Color.onPrimaryColor.opacity(0.87))
                            }
                        )
                        .accessibilityElement()
                        .accessibilityLabel("Close Sort")
                    }
                }
                .presentationDetents([.large])
            }

            .onAppear {
                Metrics.shared.dataSourceSort(dataSource: DataSources.dgps)
            }
        }
    }
}
