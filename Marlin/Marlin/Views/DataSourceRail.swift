//
//  DataSourceRail.swift
//  Marlin
//
//  Created by Daniel Barela on 7/29/22.
//

import SwiftUI

struct DataSourceRail: View {
    @ObservedObject var dataSourceList: DataSourceList
    
    @Binding var activeRailItem: DataSourceItem?

    var body: some View {
        ScrollView {
            VStack {
                ForEach(dataSourceList.tabs) { dataSourceItem in
                    if let systemImageName = dataSourceItem.dataSource.systemImageName {
                        RailItem(systemImageName: systemImageName, itemText: dataSourceItem.dataSource.dataSourceName)
                            .onTapGesture {
                                activeRailItem = dataSourceItem
                            }
                            .foregroundColor(activeRailItem == dataSourceItem ? Color.primaryColorVariant.opacity(0.87) : Color.onSurfaceColor.opacity(0.6))
                    } else if let imageName = dataSourceItem.dataSource.imageName {
                        RailItem(imageName: imageName, itemText: dataSourceItem.dataSource.dataSourceName)
                            .onTapGesture {
                                activeRailItem = dataSourceItem
                            }
                            .foregroundColor(activeRailItem == dataSourceItem ? Color.primaryColorVariant.opacity(0.87) : Color.onSurfaceColor.opacity(0.6))
                    }
                }
            }
            Spacer()
        }
        .frame(minWidth: 72, idealWidth: 72, maxWidth: 72)
        .background(
            Color.surfaceColor
                .shadow(color: Color(UIColor.label).opacity(0.3), radius: 1, x: 0, y: 0)
                .mask(Rectangle().padding(.trailing, -4))
        )
    }
}
