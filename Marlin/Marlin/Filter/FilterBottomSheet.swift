//
//  FilterBottomSheet.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/22.
//

import SwiftUI

struct DataSourceFilter: View {
    var filterViewModel: FilterViewModel
    @Binding var showBottomSheet: Bool

    var body: some View {
        Self._printChanges()
        return Color.clear
            .sheet(isPresented: $showBottomSheet) {
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            FilterView(viewModel: filterViewModel)
                                .padding(.trailing, 16)
                                .padding(.top, 8)
                                .background(Color.surfaceColor)
                            
                        }
                        .background(Color.surfaceColor)
                        
                        Spacer()
                            .foregroundColor(Color.backgroundColor)
                    }
                    .navigationTitle("\(filterViewModel.dataSource?.definition.name ?? "") Filters")
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color.backgroundColor)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(
                                action: {
                                    showBottomSheet.toggle()
                                },
                                label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.large)
                                        .foregroundColor(Color.onPrimaryColor.opacity(0.87))
                                }
                            )
                            .accessibilityElement()
                            .accessibilityLabel("Close Filter")
                        }
                    }
                    .onAppear {
                        Metrics.shared.dataSourceFilter(dataSource: filterViewModel.dataSource?.definition)
                    }
                }
                .environmentObject(LocationManager.shared())
                .presentationDetents([.large])
            }
    }
}

struct MappedDataSourcesFilter: View {
    @EnvironmentObject var dataSourceList: DataSourceList
    @Binding var showBottomSheet: Bool

    var body: some View {
        FilterBottomSheet(showBottomSheet: $showBottomSheet, dataSources: $dataSourceList.mappedFilterableDataSources)
    }
}

struct FilterBottomSheet: View {
    
    @Binding var showBottomSheet: Bool
    @Binding var dataSources: [Filterable]
    let dismissBottomSheetPub = NotificationCenter.default.publisher(for: .DismissBottomSheet)
    
    var filteredFilterables: [Filterable] {
        dataSources.filter { filterable in
            !filterable.properties.isEmpty
        }
        .sorted { item1, item2 in
            item1.definition.order < item2.definition.order
        }
    }

    var body: some View {
        Self._printChanges()
        return Color.clear
            .sheet(isPresented: $showBottomSheet) {
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(filteredFilterables, id: \.id) { filterable in
                                FilterBottomSheetRow(filterable: filterable)
                                    .accessibilityElement(children: .contain)
                                    .accessibilityLabel("\(filterable.definition.fullName) filter row")
                            }
                            .background(Color.surfaceColor)
                        }
                        .background(Color.backgroundColor)
                        
                    }
                    .navigationTitle("Filters")
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color.backgroundColor)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(
                                action: {
                                    showBottomSheet.toggle()
                                },
                                label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.large)
                                        .foregroundColor(Color.onPrimaryColor.opacity(0.87))
                                }
                            )
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("Close Filter")
                        }
                    }
                    .onAppear {
                        Metrics.shared.appRoute(["mapFilter"])
                    }
                    .environmentObject(LocationManager.shared())
                }
                .onReceive(dismissBottomSheetPub) { _ in
                    showBottomSheet = false
                }
                .presentationDetents([.large])
            }
            
    }
}
