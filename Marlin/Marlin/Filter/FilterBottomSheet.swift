//
//  FilterBottomSheet.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/22.
//

import SwiftUI

struct FilterBottomSheet: View {
    @Binding var dataSources: [DataSourceItem]

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach($dataSources.filter({ item in
                    item.showOnMap.wrappedValue
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
    }
}
