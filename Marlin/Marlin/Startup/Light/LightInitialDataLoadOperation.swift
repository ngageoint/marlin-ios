//
//  LightInitialDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation

class LightInitialDataLoadOperation: CountingDataLoadOperation {
    var localDataSource: LightLocalDataSource
    var bundle: Bundle

    init(localDataSource: LightLocalDataSource, bundle: Bundle = .main) {
        self.localDataSource = localDataSource
        self.bundle = bundle
    }

    @MainActor override func startLoad() {
        MSI.shared.appState.loadingDataSource[DataSources.light.key] = true

        NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: DataSources.light))
    }

    @MainActor override func finishLoad() {
        self.state = .isFinished
        MSI.shared.appState.loadingDataSource[DataSources.light.key] = false
        NotificationCenter.default.post(
            name: .DataSourceLoaded,
            object: DataSourceItem(dataSource: DataSources.light)
        )
        NotificationCenter.default.post(
            name: .DataSourceNeedsProcessed,
            object: DataSourceUpdatedNotification(key: DataSources.light.key)
        )
        NotificationCenter.default.post(
            name: .DataSourceUpdated,
            object: DataSourceUpdatedNotification(key: DataSources.light.key)
        )
    }

    override func loadData() async {
        NSLog("Light Initial Data Load")
        if self.isCancelled {
            return
        }
        if let url = bundle.url(forResource: "lights", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let propertyContainer = try decoder.decode(LightsPropertyContainer.self, from: data)
                count = await localDataSource.insert(task: nil, lights: propertyContainer.ngalol)
            } catch {
                print("error:\(error)")
            }
        }

    }
}
