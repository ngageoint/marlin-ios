//
//  AsamGeoPackageExportable.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import geopackage_ios
import ExceptionCatcher
import sf_ios

class AsamGeoPackageExportable: GeoPackageExportable {
    static var definition: any DataSourceDefinition = DataSources.asam

    let asamRepository: AsamRepository
    init(asamRepository: AsamRepository) {
        self.asamRepository = asamRepository
    }

    var sfGeometry: SFGeometry?

    func createFeatures(
        geoPackage: GPKGGeoPackage,
        table: GPKGFeatureTable,
        filters: [DataSourceFilterParameter]?,
        commonFilters: [DataSourceFilterParameter]?,
        styleRows: [GPKGStyleRow],
        dataSourceProgress: DataSourceExportProgress
    ) async throws {
        let asams = await asamRepository.getAsams(filters: (filters ?? []) + (commonFilters ?? []))
        var exported = 0
        for asam in asams {
            createFeature(model: asam, sfGeometry: asam.sfGeometry, geoPackage: geoPackage, table: table, styleRows: styleRows)
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
