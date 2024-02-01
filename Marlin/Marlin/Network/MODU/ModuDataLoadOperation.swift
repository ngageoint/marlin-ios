//
//  ModuDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation
import CoreData

class ModuDataLoadOperation: CountingDataLoadOperation {
    var modus: [ModuModel] = []
    var localDataSource: ModuLocalDataSource

    init(modus: [ModuModel], localDataSource: ModuLocalDataSource) {
        self.modus = modus
        self.localDataSource = localDataSource
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: modus)) ?? 0
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceNeedsProcessed,
                    object: DataSourceUpdatedNotification(key: DataSources.modu.key)
                )
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.modu.key)
                )
            }
        }
    }
}
