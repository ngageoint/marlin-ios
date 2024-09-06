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
    @Injected(\.navWarningLocalDataSource)
    var localDataSource: NavigationalWarningLocalDataSource

    init(navigationalWarnings: [NavigationalWarningModel]) {
        self.navigationalWarnings = navigationalWarnings
    }

    @MainActor override func finishLoad() {
        if count != 0 {
            Task {
                await localDataSource.postProcess()
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.navWarning.key)
                )
            }
        }

        self.state = .isFinished
        MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] = false
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: navigationalWarnings)) ?? 0
    }
}
