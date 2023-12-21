//
//  AsamList.swift
//  Marlin
//
//  Created by Daniel Barela on 11/16/23.
//

import Foundation
import SwiftUI

struct AsamList: View {
    @EnvironmentObject var asamRepository: AsamRepository
    @StateObject var viewModel: AsamsViewModel = AsamsViewModel()
    
    @Binding var path: NavigationPath
    
    @State var sortOpen: Bool = false
    @State var filterOpen: Bool = false
    @State var filterViewModel: FilterViewModel = PersistedFilterViewModel(
        dataSource: DataSources.filterableFromDefintion(DataSources.asam)
    )

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                VStack(alignment: .center, spacing: 16) {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Image("asam_large")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding([.trailing, .leading], 24)
                            .foregroundColor(Color.onSurfaceColor)
                        Spacer()
                    }
                    Text("Loading ASAMs")
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
                    List(rows) { asamItem in
                        switch asamItem {
                        case .listItem(let asam):
                            
                            AsamSummaryView(asam: asam)
                                .paddedCard()
                                .onAppear {
                                    if rows.last == asamItem {
                                        viewModel.loadMore()
                                    }
                                }
                                .onTapGesture {
                                    path.append(MarlinRoute.dataSourceDetail(
                                        dataSourceKey: Asam.definition.key, itemKey: asam.itemKey)
                                    )
                                }
                                .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.backgroundColor)
                        case .sectionHeader(let header):
                            Text(header)
                                .onAppear {
                                    if rows.last == asamItem {
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
                            Image("asam_large")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .padding([.trailing, .leading], 24)
                                .foregroundColor(Color.onSurfaceColor)
                            Spacer()
                        }
                        Text("No ASAMs match this filter")
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
        .navigationTitle(DataSources.asam.fullName)
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
            viewModel.repository = asamRepository
            Metrics.shared.dataSourceList(dataSource: DataSources.asam)
        }
        .modifier(
            FilterButton(
                filterOpen: $filterOpen,
                sortOpen: $sortOpen,
                dataSources: Binding.constant([
                    DataSourceItem(dataSource: Asam.self)
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
                        SortView(definition: DataSources.asam)
                            .background(Color.surfaceColor)
                        
                        Spacer()
                    }
                    
                }
                .navigationTitle("\(DataSources.asam.name) Sort")
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
                Metrics.shared.dataSourceSort(dataSource: DataSources.asam)
            }
        }
    }
}
