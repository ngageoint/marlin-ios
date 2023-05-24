//
//  DataSourceListView.swift
//  Marlin
//
//  Created by Daniel Barela on 5/23/23.
//

import SwiftUI

struct DataSourceListView: View {
    var dataSource: DataSourceItem
    
    var body: some View {
        if dataSource.key == Asam.key {
            MSIListView<Asam, EmptyView, EmptyView>()
        } else if dataSource.key == Modu.key {
            MSIListView<Modu, EmptyView, EmptyView>()
        } else if dataSource.key == Light.key {
            MSIListView<Light, EmptyView, EmptyView>()
        } else if dataSource.key == NavigationalWarning.key {
            NavigationalWarningsOverview()
        } else if dataSource.key == Port.key {
            MSIListView<Port, EmptyView, EmptyView>()
        } else if dataSource.key == RadioBeacon.key {
            MSIListView<RadioBeacon, EmptyView, EmptyView>()
        } else if dataSource.key == DifferentialGPSStation.key {
            MSIListView<DifferentialGPSStation, EmptyView, EmptyView>()
        } else if dataSource.key == DFRS.key {
            MSIListView<DFRS, EmptyView, EmptyView>()
        } else if dataSource.key == ElectronicPublication.key {
            ElectronicPublicationsList()
        } else if dataSource.key == NoticeToMariners.key {
            NoticeToMarinersView()
        }
    }
}
