//
//  DGPSStationGeoPackageExportable.swift
//  Marlin
//
//  Created by Daniel Barela on 2/9/24.
//

import Foundation
import geopackage_ios
import ExceptionCatcher
import sf_ios

actor DGPSStationGeoPackageExportable: GeoPackageExportable {
    static var definition: any DataSourceDefinition = DataSources.dgps

    @Injected(\.dgpsRepository)
    var differentialGPSStationRepository: DGPSStationRepository

    func createFeatures(
        geoPackage: GPKGGeoPackage,
        table: GPKGFeatureTable,
        filters: [DataSourceFilterParameter]?,
        styleRows: [GPKGStyleRow],
        dataSourceProgress: DataSourceExportProgress
    ) async throws {

        let models = await differentialGPSStationRepository.getDifferentialGPSStations(
            filters: (filters ?? [])
        )
        var exported = 0
        for model in models {
            createFeature(
                model: model,
                sfGeometry: model.sfGeometry,
                geoPackage: geoPackage,
                table: table,
                styleRows: styleRows
            )
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
