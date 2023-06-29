//
//  GeoPackageExportView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/21/23.
//

import SwiftUI

struct GeoPackageExportView: View {
    @StateObject var exporter: GeoPackageExporter = GeoPackageExporter()
    
    var exportRequest: [DataSourceExportRequest]
    var body: some View {
        
        Text("GeoPackage Export")
        ForEach(exportRequest) { request in
            Text("\(request.dataSourceItem.dataSource.fullDataSourceName)")
        }
        if exporter.complete {
            Text("Export complete")
        } else if exporter.exporting {
            Text("Exporting")
        }
        if let creationError = exporter.creationError {
            Text("Error \(creationError)")
        }
        Button("Export") {
            exporter.export(exportRequest: exportRequest)
        }
        .buttonStyle(MaterialButtonStyle(type:.contained))
    }
}
