//
//  RadioBeaconDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 1/31/24.
//

import Foundation
import Kingfisher

class RadioBeaconDataLoadOperation: CountingDataLoadOperation {

    var radioBeacons: [RadioBeaconModel] = []
    var localDataSource: RadioBeaconLocalDataSource

    init(radioBeacons: [RadioBeaconModel], localDataSource: RadioBeaconLocalDataSource) {
        self.radioBeacons = radioBeacons
        self.localDataSource = localDataSource
    }

    @MainActor override func finishLoad() {
        Kingfisher.ImageCache(name: DataSources.radioBeacon.key).clearCache()
        self.state = .isFinished

        MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] = false
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.radioBeacon.key)
                )
            }
        }
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: radioBeacons)) ?? 0
    }
}
