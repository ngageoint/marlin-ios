//
//  DGPSStationInitialDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import Kingfisher

class DGPSStationInitialDataLoadOperation: CountingDataLoadOperation {
    @Injected(\.dgpsLocalDataSource)
    var localDataSource: DGPSStationLocalDataSource
    var bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    @MainActor override func startLoad() {
        MSI.shared.appState.loadingDataSource[DataSources.dgps.key] = true

        NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: DataSources.dgps))
    }

    @MainActor override func finishLoad() {
        Kingfisher.ImageCache(name: DataSources.dgps.key).clearCache()

        self.state = .isFinished
        MSI.shared.appState.loadingDataSource[DataSources.dgps.key] = false
        NotificationCenter.default.post(
            name: .DataSourceLoaded,
            object: DataSourceItem(dataSource: DataSources.dgps)
        )
        NotificationCenter.default.post(
            name: .DataSourceUpdated,
            object: DataSourceUpdatedNotification(key: DataSources.dgps.key)
        )
    }

    override func loadData() async {
        NSLog("DGPS Initial Data Load")
        if self.isCancelled {
            return
        }
        if let url = bundle.url(forResource: "dgps", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let propertyContainer = try decoder.decode(DGPSStationPropertyContainer.self, from: data)
                count = await localDataSource.insert(task: nil, dgpss: propertyContainer.ngalol)
            } catch {
                print("error:\(error)")
            }
        }

    }
}
