//
//  PortDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 1/30/24.
//

import Foundation

class PortDataLoadOperation: CountingDataLoadOperation {

    var ports: [PortModel] = []
    var localDataSource: PortLocalDataSource

    init(ports: [PortModel], localDataSource: PortLocalDataSource) {
        self.ports = ports
        self.localDataSource = localDataSource
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: ports)) ?? 0
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceNeedsProcessed,
                    object: DataSourceUpdatedNotification(key: DataSources.port.key)
                )
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.port.key)
                )
            }
        }
    }
}
