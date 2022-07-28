//
//  DataSourceCell.swift
//  Marlin
//
//  Created by Daniel Barela on 7/5/22.
//

import SwiftUI

struct DataSourceCell: View {
    @EnvironmentObject var scheme: MarlinScheme
    
    @ObservedObject var dataSourceItem: DataSourceItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text(dataSourceItem.dataSource.dataSourceName)
                    .font(Font(scheme.containerScheme.typographyScheme.body1))
                    .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                    .opacity(0.87)
                    
                Spacer()
                if dataSourceItem.dataSource.isMappable {
                    Image(systemName: dataSourceItem.showOnMap ? "mappin.circle.fill" : "mappin.slash.circle.fill")
                        .renderingMode(.template)
                        .foregroundColor(Color(dataSourceItem.showOnMap ? scheme.containerScheme.colorScheme.primaryColor : scheme.disabledScheme.colorScheme.primaryColor))
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
                    .frame(maxWidth: 6, maxHeight: .infinity)
                Spacer()
                }
                .background(Color(scheme.containerScheme.colorScheme.surfaceColor))
        )

    }
}

struct DataSourceCell_Previews: PreviewProvider {
    static var previews: some View {
        DataSourceCell(dataSourceItem: DataSourceItem(dataSource: Asam.self))
    }
}
