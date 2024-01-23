//
//  ModuInitialDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation

class ModuInitialDataLoadOperation: CountingDataLoadOperation {
    var localDataSource: ModuLocalDataSource
    var bundle: Bundle

    init(localDataSource: ModuLocalDataSource, bundle: Bundle = .main) {
        self.localDataSource = localDataSource
        self.bundle = bundle
    }

    @MainActor override func startLoad() {
        MSI.shared.appState.loadingDataSource[Modu.key] = true

        NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: Modu.self))
    }

    @MainActor override func finishLoad() {
        self.state = .isFinished
        MSI.shared.appState.loadingDataSource[Modu.key] = false
        NotificationCenter.default.post(
            name: .DataSourceLoaded,
            object: DataSourceItem(dataSource: Modu.self)
        )
        NotificationCenter.default.post(
            name: .DataSourceNeedsProcessed,
            object: DataSourceUpdatedNotification(key: Modu.key)
        )
        NotificationCenter.default.post(
            name: .DataSourceUpdated,
            object: DataSourceUpdatedNotification(key: Modu.key)
        )
    }

    override func loadData() async {
        NSLog("Modu Initial Data Load")
        if self.isCancelled {
            return
        }
        if let url = bundle.url(forResource: "modu", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let moduPropertyContainer = try decoder.decode(ModuPropertyContainer.self, from: data)
                count = await localDataSource.insert(task: nil, modus: moduPropertyContainer.modu)
            } catch {
                print("error:\(error)")
            }
        }

    }
}
