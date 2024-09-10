//
//  GeoPackageExportButton.swift
//  Marlin
//
//  Created by Daniel Barela on 8/15/23.
//

import SwiftUI

struct GeoPackageExportButton: View {
    @EnvironmentObject var router: MarlinRouter
    var filterable: Filterable
    
    var body: some View {
        Button {
            router.path.append(MarlinRoute.exportGeoPackageDataSource(
                dataSource: DataSourceDefinitions.from(filterable.definition)
            ))
        } label: {
            Label(
                title: {},
                icon: { Image(systemName: "square.and.arrow.down")
                        .renderingMode(.template)
                }
            )
        }
        .fixedSize()
        .buttonStyle(
            MaterialFloatingButtonStyle(
                type: .secondary,
                size: .mini,
                foregroundColor: Color.onPrimaryColor,
                backgroundColor: Color.primaryColor
            )
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Export Button")
        .padding(16)
    }
}
