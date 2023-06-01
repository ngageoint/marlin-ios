//
//  MapNavigationView.swift
//  Marlin
//
//  Created by Daniel Barela on 5/23/23.
//

import SwiftUI

struct MapNavigationView: View {
    @EnvironmentObject var dataSourceList: DataSourceList
    @Binding var filterOpen: Bool
    @Binding var selection: String?
    @Binding var menuOpen: Bool
    
    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
    
    let viewDataSourcePub = NotificationCenter.default.publisher(for: .ViewDataSource).compactMap { notification in
        notification.object as? ViewDataSource
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DataLoadedNotificationBanner()
                CurrentLocation()
                ZStack(alignment: .topLeading) {
                    MarlinMainMap(selection: $selection)
                        .navigationTitle("Marlin")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                        .if(UserDefaults.standard.hamburger) { view in
                            view.modifier(Hamburger(menuOpen: $menuOpen))
                        }
                        .modifier(FilterButton(filterOpen: $filterOpen, dataSources: $dataSourceList.mappedDataSources))
                        .onAppear {
                            Metrics.shared.mapView()
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Marlin Map")
                    
                    LoadingCapsule()
                }
                NavigationLink(tag: "detail", selection: $selection) {
                    if let data = itemWrapper.dataSource as? DataSourceViewBuilder {
                        data.detailView
                    }
                } label: {
                    EmptyView()
                }
                .isDetailLink(false)
                .hidden()
                
                NavigationLink(tag: "settings", selection: $selection) {
                    AboutView()
                } label: {
                    EmptyView()
                }
                .isDetailLink(false)
                .hidden()
                
                NavigationLink(tag: "submitReport", selection: $selection) {
                    SubmitReportView()
                } label: {
                    EmptyView()
                }
                .isDetailLink(false)
                .hidden()
                
                ForEach(dataSourceList.nonTabs) { dataSource in
                    
                    NavigationLink(tag: "\(dataSource.key)List", selection: $selection) {
                        DataSourceListView(dataSource: dataSource)
                    } label: {
                        EmptyView()
                    }
                    
                    .isDetailLink(false)
                    .hidden()
                }
            }
            .onReceive(viewDataSourcePub) { output in
                if let dataSource = output.dataSource {
                    if output.mapName == nil || output.mapName == "Marlin Map" {
                        viewData(dataSource)
                    }
                }
            }
        }
    }
    
    func viewData(_ data: any DataSource) {
        NotificationCenter.default.post(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: nil))
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        itemWrapper.dataSource = data
        itemWrapper.date = Date()
        selection = "detail"
    }
}
