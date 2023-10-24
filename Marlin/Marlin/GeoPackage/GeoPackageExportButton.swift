//
//  GeoPackageExportButton.swift
//  Marlin
//
//  Created by Daniel Barela on 8/15/23.
//

import SwiftUI

struct GeoPackageExportButton: View {
    var filterable: Filterable
    
    var body: some View {
        NavigationLink(value: MarlinRoute.exportGeoPackage([DataSourceExportRequest(filterable: filterable, filters: UserDefaults.standard.filter(filterable.definition))])) {
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
