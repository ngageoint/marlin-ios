//
//  DGPSStationDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import Kingfisher

class DGPSStationDataLoadOperation: CountingDataLoadOperation, @unchecked Sendable {

    let dgpss: [DGPSStationModel]
    @Injected(\.dgpsLocalDataSource)
    var localDataSource: DGPSStationLocalDataSource

    init(dgpss: [DGPSStationModel]) {
        self.dgpss = dgpss
    }

    @MainActor
    override func finishLoad() {
        Kingfisher.ImageCache(name: DataSources.dgps.key).clearCache()
        self.state = .isFinished

        MSI.shared.appState.loadingDataSource[DataSources.dgps.key] = false
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.dgps.key)
                )
            }
        }
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: dgpss)) ?? 0
    }
}
