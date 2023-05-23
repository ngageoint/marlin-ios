//
//  DataSourceToggles.swift
//  Marlin
//
//  Created by Daniel Barela on 5/22/23.
//

import SwiftUI

struct DataSourceToggles: View {
    @EnvironmentObject var dataSourceList: DataSourceList
    // force an updates
    @State var date = Date()
    
    let mappedDataSourcesUpdatedPub = NotificationCenter.default.publisher(for: .MappedDataSourcesUpdated)
    
    var body: some View {
        ForEach(dataSourceList.allTabs, id: \.self) { dataSource in
            if dataSource.dataSource.isMappable {
                Button(action: {
                    dataSource.showOnMap.toggle()
                }) {
                    Label(title: {}) {
                        if let image = dataSource.dataSource.image {
                            Image(uiImage: image)
                                .renderingMode(.template)
                                .tint(Color.white)
                        }
                    }
                }
                .buttonStyle(MaterialFloatingButtonStyle(type: .custom, size: .mini, foregroundColor: dataSource.showOnMap ? Color.white : Color.disabledColor, backgroundColor: dataSource.showOnMap ? Color(uiColor: dataSource.dataSource.color) : Color.disabledBackground))
                .accessibilityElement(children: .contain)
                .accessibilityLabel("\(dataSource.dataSource.key) Map Toggle")
            }
        }
        .onReceive(mappedDataSourcesUpdatedPub) { updated in
            date = Date()
        }
    }
}
