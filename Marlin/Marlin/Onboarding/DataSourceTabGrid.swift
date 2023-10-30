//
//  DataSourceTabGrid.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI

struct DataSourceTabGrid: View {
    @EnvironmentObject var dataSourceList: DataSourceList
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    
    var gridSize: CGFloat {
        verticalSizeClass != .compact ? 100 : 75
    }
    
    func isTab(_ key: String) -> Bool {
        dataSourceList.tabs.contains { item in
            item.key == key
        }
    }
    
    @ViewBuilder
    func dataSourceTabSquare(dataSource: any DataSource.Type) -> some View {
        DataSourceGridSquare(dataSource: dataSource)
        .onTapGesture {
            if isTab(dataSource.definition.key) {
                dataSourceList.addItemToNonTabs(dataSourceItem: DataSourceItem(dataSource: dataSource), position: 0)
            } else {
                dataSourceList.addItemToTabs(dataSourceItem: DataSourceItem(dataSource: dataSource), position: 0)
            }
        }
        .overlay(CheckBadge(on: .constant(isTab(dataSource.definition.key)))
            .accessibilityElement()
            .accessibilityLabel("\(dataSource.definition.fullName) Tab \(isTab(dataSource.definition.key) ? "On" : "Off")"))
        .padding(8)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(dataSource.definition.fullName) Tab")
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: gridSize))]) {
            ForEach(dataSourceList.enabledTabs) { dataSourceItem in
                dataSourceTabSquare(dataSource: dataSourceItem.dataSource)
            }
        }
        .frame(maxWidth: 500, alignment: .center)
    }
}
