//
//  AsamDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 11/7/23.
//

import Foundation
import Kingfisher

class AsamDataLoadOperation: CountingDataLoadOperation, @unchecked Sendable {

    let asams: [AsamModel]
    @Injected(\.asamLocalDataSource)
    var localDataSource: AsamLocalDataSource

    init(asams: [AsamModel]) {
        self.asams = asams
    }

    @MainActor
    override func finishLoad() {
        Kingfisher.ImageCache(name: DataSources.asam.key).clearCache()
        self.state = .isFinished

        MSI.shared.appState.loadingDataSource[DataSources.asam.key] = false
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.asam.key)
                )
            }
        }
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: asams)) ?? 0
    }
}
