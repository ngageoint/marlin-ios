//
//  ModuList.swift
//  Marlin
//
//  Created by Daniel Barela on 1/23/24.
//

import Foundation
import SwiftUI

struct ModuList: View {

    @EnvironmentObject var moduRepository: ModuRepository
    @StateObject var viewModel: ModusViewModel = ModusViewModel()

    @EnvironmentObject var router: MarlinRouter

    @State var sortOpen: Bool = false
    @State var filterOpen: Bool = false
    @State var filterViewModel: FilterViewModel = PersistedFilterViewModel(
        dataSource: DataSources.filterableFromDefintion(DataSources.modu)
    )

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                VStack(alignment: .center, spacing: 16) {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Image("modu")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding([.trailing, .leading], 24)
                            .foregroundColor(Color.onSurfaceColor)
                        Spacer()
                    }
                    Text("Loading MODUs")
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
                    List(rows) { moduItem in
                        switch moduItem {
                        case .listItem(let modu):
                            ModuSummaryView(modu: modu)
                                .showBookmarkNotes(true)
                                .paddedCard()
                                .onAppear {
                                    if rows.last == moduItem {
                                        viewModel.loadMore()
                                    }
                                }
                                .onTapGesture {
                                    if let name = modu.name {
                                        router.path.append(ModuRoute.detail(name: name))
                                    }
                                }
                                .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.backgroundColor)
                        case .sectionHeader(let header):
                            Text(header)
                                .onAppear {
                                    if rows.last == moduItem {
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
                            Image("modu")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .padding([.trailing, .leading], 24)
                                .foregroundColor(Color.onSurfaceColor)
                            Spacer()
                        }
                        Text("No MODUs match this filter")
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
        .navigationTitle(DataSources.modu.fullName)
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
            viewModel.repository = moduRepository
            Metrics.shared.dataSourceList(dataSource: DataSources.modu)
        }
        .modifier(
            FilterButton(
                filterOpen: $filterOpen,
                sortOpen: $sortOpen,
                dataSources: Binding.constant([
                    DataSourceItem(dataSource: DataSources.modu)
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
                        SortView(definition: DataSources.modu)
                            .background(Color.surfaceColor)

                        Spacer()
                    }

                }
                .navigationTitle("\(DataSources.modu.name) Sort")
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
                Metrics.shared.dataSourceSort(dataSource: DataSources.modu)
            }
        }
    }
}
