//
//  AsamDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 11/7/23.
//

import Foundation
import CoreData

class AsamDataLoadOperation: CountingDataLoadOperation {

    var asams: [AsamModel] = []
    var localDataSource: AsamLocalDataSource

    init(asams: [AsamModel], localDataSource: AsamLocalDataSource) {
        self.asams = asams
        self.localDataSource = localDataSource
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: asams)) ?? 0
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceNeedsProcessed,
                    object: DataSourceUpdatedNotification(key: DataSources.asam.key)
                )
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.asam.key)
                )
            }
        }
    }
}
