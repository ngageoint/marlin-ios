//
//  PortDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 1/30/24.
//

import Foundation

enum PortDataLoadOperationState: String {
    case isReady
    case isExecuting
    case isFinished
}

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

        let portPropertyContainer = PortPropertyContainer(ports: ports)
        NSLog("Loading ports \(portPropertyContainer.ports.count)")
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
