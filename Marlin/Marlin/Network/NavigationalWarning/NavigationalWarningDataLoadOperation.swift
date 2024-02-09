//
//  NavigationalWarningDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import Kingfisher

class NavigationalWarningDataLoadOperation: CountingDataLoadOperation {

    var navigationalWarnings: [NavigationalWarningModel] = []
    var localDataSource: NavigationalWarningLocalDataSource

    init(navigationalWarnings: [NavigationalWarningModel], localDataSource: NavigationalWarningLocalDataSource) {
        self.navigationalWarnings = navigationalWarnings
        self.localDataSource = localDataSource
    }

    @MainActor override func finishLoad() {
        Kingfisher.ImageCache(name: DataSources.navWarning.key).clearCache()
        self.state = .isFinished

        MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] = false
        if count != 0 {
            NotificationCenter.default.post(
                name: .DataSourceUpdated,
                object: DataSourceUpdatedNotification(key: DataSources.navWarning.key)
            )
        }
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: navigationalWarnings)) ?? 0
    }
}
