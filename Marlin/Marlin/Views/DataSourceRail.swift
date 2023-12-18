//
//  DataSourceRail.swift
//  Marlin
//
//  Created by Daniel Barela on 7/29/22.
//

import SwiftUI

struct DataSourceRail: View {
    @EnvironmentObject var dataSourceList: DataSourceList
    
    @Binding var activeRailItem: DataSourceItem?

    var body: some View {
        ScrollView {
            VStack {
                ForEach(dataSourceList.allTabs) { dataSourceItem in
                    RailItem(
                        imageName: dataSourceItem.dataSource.definition.imageName,
                        systemImageName: dataSourceItem.dataSource.definition.systemImageName,
                        itemText: dataSourceItem.dataSource.definition.name)
                        .onTapGesture {
                            if activeRailItem == dataSourceItem {
                                activeRailItem = nil
                            } else {
                                activeRailItem = dataSourceItem
                            }
                        }
                        .foregroundColor(activeRailItem == dataSourceItem ? Color.primaryColorVariant.opacity(0.87) : Color.onSurfaceColor.opacity(0.6))
                        .accessibilityElement()
                        .accessibilityLabel("\(dataSourceItem.dataSource.definition.fullName) rail item")
                }
            }
            Spacer()
        }
        .background(
            Color.surfaceColor
                .shadow(color: Color(UIColor.label).opacity(0.3), radius: 1, x: 0, y: 0)
                .mask(Rectangle().padding(.trailing, -4))
        )
    }
}
