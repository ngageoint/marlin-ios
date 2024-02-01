//
//  DifferentialGPSStationDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import CoreData

class DifferentialGPSStationDataLoadOperation: CountingDataLoadOperation {

    var dgpss: [DifferentialGPSStationModel] = []
    var localDataSource: DifferentialGPSStationLocalDataSource

    init(dgpss: [DifferentialGPSStationModel], localDataSource: DifferentialGPSStationLocalDataSource) {
        self.dgpss = dgpss
        self.localDataSource = localDataSource
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: dgpss)) ?? 0
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceNeedsProcessed,
                    object: DataSourceUpdatedNotification(key: DataSources.dgps.key)
                )
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.dgps.key)
                )
            }
        }
    }
}
