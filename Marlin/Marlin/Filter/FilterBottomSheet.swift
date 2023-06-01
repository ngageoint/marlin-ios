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
        // TODO: this can be replaced with .sheet introduced in ios16 when we are at 17
            .bottomSheet(isPresented: $showBottomSheet, detents: .large) {
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
                .navigationTitle("\(filterViewModel.dataSource.dataSourceName) Filters")
                .background(Color.backgroundColor)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showBottomSheet.toggle()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(Color.onPrimaryColor.opacity(0.87))
                        }
                        .accessibilityElement()
                        .accessibilityLabel("Close Filter")
                    }
                }
                .onAppear {
                    Metrics.shared.dataSourceFilter(dataSource: filterViewModel.dataSource)
                }
                .environmentObject(LocationManager.shared())
            }
    }
}

struct MappedDataSourcesFilter: View {
    @EnvironmentObject var dataSourceList: DataSourceList
    @Binding var showBottomSheet: Bool

    var body: some View {
        FilterBottomSheet(showBottomSheet: $showBottomSheet, dataSources: $dataSourceList.mappedDataSources)
    }
}

extension FilterBottomSheet: BottomSheetDelegate {
    func bottomSheetDidDismiss() {
        NotificationCenter.default.post(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: nil))
    }
}

struct FilterBottomSheet: View {
    
    @Binding var showBottomSheet: Bool
    @Binding var dataSources: [DataSourceItem]
    let dismissBottomSheetPub = NotificationCenter.default.publisher(for: .DismissBottomSheet)

    var body: some View {
        Self._printChanges()
        return Color.clear
        // TODO: this can be replaced with .sheet introduced in ios16 when we are at 17
            .bottomSheet(isPresented: $showBottomSheet, detents: .large, delegate: self) {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach($dataSources.filter({ item in
                            item.showOnMap.wrappedValue && item.dataSource.wrappedValue.properties.count != 0
                        }).sorted(by: { item1, item2 in
                            item1.order.wrappedValue < item2.order.wrappedValue
                        })) { $dataSourceItem in
                            FilterBottomSheetRow(dataSourceItem: $dataSourceItem)
                                .accessibilityElement(children: .contain)
                                .accessibilityLabel("\(dataSourceItem.dataSource.fullDataSourceName) filter row")
                        }
                        .background(Color.surfaceColor)
                    }
                    .background(Color.backgroundColor)
                    
                }
                .navigationTitle("Filters")
                .background(Color.backgroundColor)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showBottomSheet.toggle()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(Color.onPrimaryColor.opacity(0.87))
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Close Filter")
                    }
                }
                .onAppear {
                    Metrics.shared.appRoute(["mapFilter"])
                }
                .environmentObject(LocationManager.shared())
            }
            .onReceive(dismissBottomSheetPub) { output in
                showBottomSheet = false
            }
    }
}
