//
//  DifferentialGPSStationGeoPackageExportable.swift
//  Marlin
//
//  Created by Daniel Barela on 2/9/24.
//

import Foundation
import geopackage_ios
import ExceptionCatcher
import sf_ios

class DifferentialGPSStationGeoPackageExportable: GeoPackageExportable {
    static var definition: any DataSourceDefinition = DataSources.dgps

    func createFeatures(
        geoPackage: GPKGGeoPackage,
        table: GPKGFeatureTable,
        filters: [DataSourceFilterParameter]?,
        commonFilters: [DataSourceFilterParameter]?,
        styleRows: [GPKGStyleRow],
        dataSourceProgress: DataSourceExportProgress
    ) async throws {

        guard let repository = MSI.shared.differentialGPSStationRepository else {
            return
        }

        let models = await repository.getDifferentialGPSStations(filters: (filters ?? []) + (commonFilters ?? []))
        var exported = 0
        for model in models {
            createFeature(model: model, sfGeometry: model.sfGeometry, geoPackage: geoPackage, table: table, styleRows: styleRows)
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