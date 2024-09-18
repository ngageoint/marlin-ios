//
//  RadioBeaconInitialDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import Kingfisher

class RadioBeaconInitialDataLoadOperation: CountingDataLoadOperation, @unchecked Sendable {
    @Injected(\.radioBeaconLocalDataSource)
    private var localDataSource: RadioBeaconLocalDataSource
    let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    @MainActor
    override func startLoad() {
        MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] = true

        NotificationCenter.default.post(
            name: .DataSourceLoading,
            object: DataSourceItem(dataSource: DataSources.radioBeacon)
        )
    }

    @MainActor
    override func finishLoad() {
        Kingfisher.ImageCache(name: DataSources.radioBeacon.key).clearCache()
        self.state = .isFinished
        MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] = false
        NotificationCenter.default.post(
            name: .DataSourceLoaded,
            object: DataSourceItem(dataSource: DataSources.radioBeacon)
        )
        NotificationCenter.default.post(
            name: .DataSourceUpdated,
            object: DataSourceUpdatedNotification(key: DataSources.radioBeacon.key)
        )
    }

    override func loadData() async {
        NSLog("Radio Beacon Initial Data Load")
        if self.isCancelled {
            return
        }
        if let url = bundle.url(forResource: "radioBeacon", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let propertyContainer = try decoder.decode(RadioBeaconPropertyContainer.self, from: data)
                count = await localDataSource.insert(task: nil, radioBeacons: propertyContainer.ngalol)
            } catch {
                print("error:\(error)")
            }
        }

    }
}
