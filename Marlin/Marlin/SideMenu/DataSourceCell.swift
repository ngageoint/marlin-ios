//
//  DataSourceCell.swift
//  Marlin
//
//  Created by Daniel Barela on 7/5/22.
//

import SwiftUI

struct DataSourceCell: View {    
    @ObservedObject var dataSourceItem: DataSourceItem
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                
                if let loading = appState.loadingDataSource[dataSourceItem.key], loading {
                    HStack(alignment: .center) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.primaryColorVariant))
                            .scaleEffect(0.75, anchor: .center)
                    }
                } else {
                    if let systemImageName = dataSourceItem.dataSource.systemImageName {
                        Image(systemName: systemImageName)
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                    } else if let imageName = dataSourceItem.dataSource.imageName {
                        Image(imageName)
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                    }
                }
                
                Text(dataSourceItem.dataSource.fullDataSourceName)
                    .primary()

                Spacer()
                if dataSourceItem.dataSource.isMappable {
                    Image(systemName: dataSourceItem.showOnMap ? "mappin.circle.fill" : "mappin.slash.circle.fill")
                        .renderingMode(.template)
                        .foregroundColor(dataSourceItem.showOnMap ? Color.primaryColorVariant : Color.disabledColor)
                        .onTapGesture {
                            dataSourceItem.showOnMap = !dataSourceItem.showOnMap
                        }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                NotificationCenter.default.post(name: .SwitchTabs, object: dataSourceItem.key)
            }
            .padding([.leading, .top, .bottom, .trailing], 16)
            Divider()
        }
        .background(
            
            HStack {
                Rectangle()
                    .fill(Color(dataSourceItem.dataSource.color))
                    .frame(maxWidth: 8, maxHeight: .infinity)
                Spacer()
                }
                .background(Color.surfaceColor)
        )

    }
}

struct DataSourceCell_Previews: PreviewProvider {
    static var previews: some View {
        DataSourceCell(dataSourceItem: DataSourceItem(dataSource: Asam.self))
    }
}
