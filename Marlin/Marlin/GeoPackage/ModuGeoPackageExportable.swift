//
//  ModuGeoPackageExportable.swift
//  Marlin
//
//  Created by Daniel Barela on 2/9/24.
//

import Foundation
import geopackage_ios
import ExceptionCatcher
import sf_ios

class ModuGeoPackageExportable: GeoPackageExportable {
    static var definition: any DataSourceDefinition = DataSources.modu

    @Injected(\.moduRepository)
    var moduRepository: ModuRepository

    func createFeatures(
        geoPackage: GPKGGeoPackage,
        table: GPKGFeatureTable,
        filters: [DataSourceFilterParameter]?,
        styleRows: [GPKGStyleRow],
        dataSourceProgress: DataSourceExportProgress
    ) async throws {
        let modus = await moduRepository.getModus(filters: (filters ?? []))
        var exported = 0
        for modu in modus {
            createFeature(
                model: modu,
                sfGeometry: modu.sfGeometry,
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
