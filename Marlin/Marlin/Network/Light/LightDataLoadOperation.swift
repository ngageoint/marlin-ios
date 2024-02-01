//
//  LightDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import CoreData

class LightDataLoadOperation: CountingDataLoadOperation {

    var lights: [LightModel] = []
    var localDataSource: LightLocalDataSource

    init(lights: [LightModel], localDataSource: LightLocalDataSource) {
        self.lights = lights
        self.localDataSource = localDataSource
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: lights)) ?? 0
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceNeedsProcessed,
                    object: DataSourceUpdatedNotification(key: DataSources.light.key)
                )
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.light.key)
                )
            }
        }
    }
}
