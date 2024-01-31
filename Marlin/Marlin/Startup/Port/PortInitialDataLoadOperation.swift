//
//  PortInitialDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 1/30/24.
//

import Foundation

class PortInitialDataLoadOperation: CountingDataLoadOperation {

    var localDataSource: PortLocalDataSource
    var bundle: Bundle

    init(localDataSource: PortLocalDataSource, bundle: Bundle = .main) {
        self.localDataSource = localDataSource
        self.bundle = bundle
    }

    @MainActor override func startLoad() {
        MSI.shared.appState.loadingDataSource[DataSources.port.key] = true

        NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: DataSources.port))
    }

    @MainActor override func finishLoad() {
        self.state = .isFinished
        MSI.shared.appState.loadingDataSource[DataSources.port.key] = false
        NotificationCenter.default.post(
            name: .DataSourceLoaded,
            object: DataSourceItem(dataSource: DataSources.port)
        )
        NotificationCenter.default.post(
            name: .DataSourceNeedsProcessed,
            object: DataSourceUpdatedNotification(key: DataSources.port.key)
        )
        NotificationCenter.default.post(
            name: .DataSourceUpdated,
            object: DataSourceUpdatedNotification(key: DataSources.port.key)
        )
    }

    override func loadData() async {
        NSLog("port Initial Data Load")
        if self.isCancelled {
            return
        }
        if let url = bundle.url(forResource: "port", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let propertyContainer = try decoder.decode(PortPropertyContainer.self, from: data)
                count = await localDataSource.insert(task: nil, ports: propertyContainer.ports)
            } catch {
                print("error:\(error)")
            }
        }

    }

}
