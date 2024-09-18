//
//  ModuDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation
import Kingfisher

class ModuDataLoadOperation: CountingDataLoadOperation, @unchecked Sendable {
    let modus: [ModuModel]
    @Injected(\.moduLocalDataSource)
    var localDataSource: ModuLocalDataSource

    init(modus: [ModuModel]) {
        self.modus = modus
    }

    @MainActor
    override func finishLoad() {
        Kingfisher.ImageCache(name: DataSources.modu.key).clearCache()
        self.state = .isFinished

        MSI.shared.appState.loadingDataSource[DataSources.modu.key] = false
        NotificationCenter.default.post(
            name: .DataSourceUpdated,
            object: DataSourceUpdatedNotification(key: DataSources.modu.key)
        )
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: modus)) ?? 0
    }
}
