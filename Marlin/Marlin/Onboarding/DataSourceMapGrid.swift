//
//  DataSourceMapGrid.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI

struct DataSourceMapGrid: View {
    @EnvironmentObject var dataSourceList: DataSourceList
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @State var dateUpdated: Date = Date()
        
    var gridSize: CGFloat {
        verticalSizeClass != .compact ? 100 : 75
    }
    
    func isMapped(_ key: String) -> Bool {
        dataSourceList.mappedDataSources.contains { item in
            item.key == key
        }
    }
    
    @ViewBuilder
    func dataSourceMapSquare(dataSourceItem: DataSourceItem) -> some View {
        DataSourceGridSquare(dataSource: dataSourceItem.dataSource)
            .onTapGesture {
                dataSourceItem.showOnMap.toggle()
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(dataSourceItem.dataSource.definition.fullName) Map")
            .overlay(CheckBadge(on: .constant(isMapped(dataSourceItem.dataSource.definition.key)))
                .accessibilityElement()
                .accessibilityLabel("\(dataSourceItem.dataSource.definition.fullName) Map \(dataSourceItem.showOnMap ? "On" : "Off")"))
            .padding(8)
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: gridSize))]) {
            ForEach(dataSourceList.mappableDataSources) { dataSourceItem in
                dataSourceMapSquare(dataSourceItem: dataSourceItem)
            }
        }
        .frame(maxWidth: 500, alignment: .center)
    }
}
