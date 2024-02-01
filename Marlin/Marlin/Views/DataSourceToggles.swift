//
//  DataSourceToggles.swift
//  Marlin
//
//  Created by Daniel Barela on 5/22/23.
//

import SwiftUI

struct DataSourceToggles: View {
    @EnvironmentObject var dataSourceList: DataSourceList
    @State var expanded: Bool = false
    
    var body: some View {
        expandButton()
            .background(alignment: .bottomLeading) {
                // two arcs
                // outer arc
                ForEach(
                    Array(
                        dataSourceList
                            .mappableDataSources
                            .prefix(5)
                            .enumerated()
                    ), id: \.element) { index, dataSourceItem in
                    dataSourceButton(dataSourceItem: dataSourceItem)
                        .offset(expanded ? position(position: index, arcSize: 5, radius: 120.0) : .zero)
                        .opacity(expanded ? 1.0 : 0.0)
                }
                // inner arc
                ForEach(
                    Array(
                        dataSourceList
                            .mappableDataSources[5...7]
                            .enumerated()
                    ), id: \.element) { index, dataSourceItem in
                    dataSourceButton(dataSourceItem: dataSourceItem)
                        .offset(expanded ? position(position: index, arcSize: 3, radius: 65.0) : .zero)
                        .opacity(expanded ? 1.0 : 0.0)
                }
            }
    }
    
    func position(position: Int, arcSize: Int, radius: CGFloat) -> CGSize {
        let range = -CGFloat.pi / 2 ... 0
        let angle = range.lowerBound + CGFloat(position) / CGFloat(arcSize - 1) * (range.upperBound - range.lowerBound)
        return CGSize(width: radius * cos(angle) + 8, height: radius * sin(angle))
    }
    
    @ViewBuilder
    func expandButton() -> some View {
        Button(
            action: {
                withAnimation {
                    expanded.toggle()
                }
            },
            label: {
                Label(
                    title: {},
                    icon: {
                        Group {
                            if expanded {
                                Image(systemName: "xmark")
                                    .renderingMode(.template)
                                    .tint(expanded ? Color.primaryColor : Color.onPrimaryColor)
                            } else {
                                Image("marlin_large")
                                    .resizable()
                                    .renderingMode(.template)
                                    .tint(expanded ? Color.primaryColor : Color.onPrimaryColor)
                                    .aspectRatio(contentMode: .fit)
                            }
                        }

                    }
                )
            }
        )
        .buttonStyle(
            MaterialFloatingButtonStyle(
                type: .custom,
                size: expanded ? .mini : .regular,
                foregroundColor: expanded ? Color.primaryColor : Color.onPrimaryColor,
                backgroundColor: expanded ? Color.onPrimaryColor : Color.primaryColor))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(expanded ? "Collapse" : "Expand") Map Toggle")
        .offset(x: expanded ? 8 : 0, y: 0)
    }
    
    @ViewBuilder
    func dataSourceButton(dataSourceItem: DataSourceItem) -> some View {
        Button(
            action: {
                dataSourceItem.showOnMap.toggle()
            },
            label: {
                Label(
                    title: {},
                    icon: {
                        if let image = dataSourceItem.dataSource.image {
                            Image(uiImage: image)
                                .renderingMode(.template)
                                .tint(Color.white)
                        }
                    }
                )
            }
        )
        .buttonStyle(
            MaterialFloatingButtonStyle(
                type: .custom, size: .mini,
                foregroundColor: Color.white,
                backgroundColor: dataSourceItem.showOnMap ?
                Color(uiColor: dataSourceItem.dataSource.definition.color) : Color.disabledBackground))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(dataSourceItem.dataSource.definition.key) Map Toggle")
    }
}
