//
//  RouteGeoPackageExportable.swift
//  Marlin
//
//  Created by Daniel Barela on 2/9/24.
//

import Foundation
import geopackage_ios
import ExceptionCatcher
import sf_ios

class RouteGeoPackageExportable: GeoPackageExportable {
    static var definition: any DataSourceDefinition = DataSources.route

    var sfGeometry: SFGeometry?

    func createFeatures(
        geoPackage: GPKGGeoPackage,
        table: GPKGFeatureTable,
        filters: [DataSourceFilterParameter]?,
        commonFilters: [DataSourceFilterParameter]?,
        styleRows: [GPKGStyleRow],
        dataSourceProgress: DataSourceExportProgress
    ) async throws {

        guard let repository = MSI.shared.routeRepository else {
            return
        }

        let routes = await repository.getRoutes(filters: (filters ?? []) + (commonFilters ?? []))
        var exported = 0
        for route in routes {
            createFeature(model: route, sfGeometry: route.sfGeometry, geoPackage: geoPackage, table: table, styleRows: styleRows)
            exported += 1
            if exported % 10 == 0 {
                await updateProgress(dataSourceProgress: dataSourceProgress, count: exported)
            }
        }
        await updateProgress(dataSourceProgress: dataSourceProgress, count: exported)
    }

    @MainActor
    func updateProgress(dataSourceProgress: DataSourceExportProgress, count: Int) {
        dataSourceProgress.exportCount = Float(count)
    }
}
