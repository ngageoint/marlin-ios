//
//  GeoPackageExportButton.swift
//  Marlin
//
//  Created by Daniel Barela on 8/15/23.
//

import SwiftUI

struct GeoPackageExportButton: View {
    var dataSource: any DataSource.Type
    
    var body: some View {
        NavigationLink(value: MarlinRoute.exportGeoPackage([DataSourceExportRequest(dataSourceItem: DataSourceItem(dataSource: dataSource), filters: UserDefaults.standard.filter(dataSource))])) {
            Label(
                title: {},
                icon: { Image(systemName: "square.and.arrow.down")
                        .renderingMode(.template)
                }
            )
        }
        .isDetailLink(false)
        .fixedSize()
        .buttonStyle(MaterialFloatingButtonStyle(type: .secondary, size: .mini, foregroundColor: Color.onPrimaryColor, backgroundColor: Color.primaryColor))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Export Button")
        .padding(16)
    }
}
