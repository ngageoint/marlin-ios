//
//  LightInitialDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation

class LightInitialDataLoadOperation: CountingDataLoadOperation, @unchecked Sendable {
    @Injected(\.lightLocalDataSource)
    var localDataSource: LightLocalDataSource
    let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    @MainActor
    override func startLoad() {
        MSI.shared.appState.loadingDataSource[DataSources.light.key] = true

        NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: DataSources.light))
    }

    @MainActor
    override func finishLoad() {
        Task {
            NotificationCenter.default.post(
                name: .DataSourceLoaded,
                object: DataSourceItem(dataSource: DataSources.light)
            )
            NotificationCenter.default.post(
                name: .DataSourceUpdated,
                object: DataSourceUpdatedNotification(key: DataSources.light.key)
            )
        }
        self.state = .isFinished
        MSI.shared.appState.loadingDataSource[DataSources.light.key] = false
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
