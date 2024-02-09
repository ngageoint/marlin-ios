//
//  PortDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 1/30/24.
//

import Foundation
import Kingfisher

class PortDataLoadOperation: CountingDataLoadOperation {

    var ports: [PortModel] = []
    var localDataSource: PortLocalDataSource

    init(ports: [PortModel], localDataSource: PortLocalDataSource) {
        self.ports = ports
        self.localDataSource = localDataSource
    }

    @MainActor override func finishLoad() {
        Kingfisher.ImageCache(name: DataSources.port.key).clearCache()
        self.state = .isFinished

        MSI.shared.appState.loadingDataSource[DataSources.port.key] = false
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.port.key)
                )
            }
        }
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: ports)) ?? 0
    }
}
