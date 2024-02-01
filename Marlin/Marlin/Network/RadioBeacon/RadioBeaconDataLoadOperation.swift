//
//  RadioBeaconDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 1/31/24.
//

import Foundation
import CoreData

enum RadioBeaconDataLoadOperationState: String {
    case isReady
    case isExecuting
    case isFinished
}

class RadioBeaconDataLoadOperation: CountingDataLoadOperation {

    var radioBeacons: [RadioBeaconModel] = []
    var localDataSource: RadioBeaconLocalDataSource

    init(radioBeacons: [RadioBeaconModel], localDataSource: RadioBeaconLocalDataSource) {
        self.radioBeacons = radioBeacons
        self.localDataSource = localDataSource
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        let propertyContainer = RadioBeaconPropertyContainer(radioBeacons: radioBeacons)
        NSLog("Loading radio beacons \(propertyContainer.ngalol.count)")
        count = (try? await localDataSource.batchImport(from: radioBeacons)) ?? 0
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceNeedsProcessed,
                    object: DataSourceUpdatedNotification(key: DataSources.radioBeacon.key)
                )
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.radioBeacon.key)
                )
            }
        }
    }
}
