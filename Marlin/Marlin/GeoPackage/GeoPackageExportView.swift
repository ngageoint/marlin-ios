//
//  GeoPackageExportView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/21/23.
//

import SwiftUI

struct GeoPackageExportView: View {
    @StateObject var exporter: GeoPackageExporter = GeoPackageExporter()
    
    var dataSource: GeoPackageExportable.Type
    var body: some View {
        Text("GeoPackage Export \(dataSource.fullDataSourceName)")
        if exporter.complete {
            Text("Export complete")
        } else if exporter.exporting {
            Text("Exporting")
        }
        if let creationError = exporter.creationError {
            Text("Error \(creationError)")
        }
        Button("Export") {
            print("Export it")
            exporter.export(dataSources: [dataSource])
        }
        .buttonStyle(MaterialButtonStyle(type:.contained))
    }
}
