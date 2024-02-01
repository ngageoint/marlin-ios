//
//  NavigationalWarningDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

class NavigationalWarningDataLoadOperation: CountingDataLoadOperation {

    var warnings: [NavigationalWarningModel] = []
    var localDataSource: NavigationalWarningLocalDataSource

    init(warnings: [NavigationalWarningModel], localDataSource: NavigationalWarningLocalDataSource) {
        self.warnings = warnings
        self.localDataSource = localDataSource
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: warnings)) ?? 0
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceNeedsProcessed,
                    object: DataSourceUpdatedNotification(key: DataSources.navWarning.key)
                )
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.navWarning.key)
                )
            }
        }
    }
}
