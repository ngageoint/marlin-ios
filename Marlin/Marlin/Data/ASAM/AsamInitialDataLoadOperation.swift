//
//  AsamInitialDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 11/8/23.
//

import Foundation

class AsamInitialDataLoadOperation: CountingDataLoadOperation {
    var localDataSource: AsamLocalDataSource
    var bundle: Bundle
    
    init(localDataSource: AsamLocalDataSource, bundle: Bundle = .main) {
        self.localDataSource = localDataSource
        self.bundle = bundle
    }
    
    @MainActor override func startLoad() {
        MSI.shared.appState.loadingDataSource[Asam.key] = true

        NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: Asam.self))
    }
    
    @MainActor override func finishLoad() {
        self.state = .isFinished
        MSI.shared.appState.loadingDataSource[Asam.key] = false
        NotificationCenter.default.post(
            name: .DataSourceLoaded,
            object: DataSourceItem(dataSource: Asam.self)
        )
        NotificationCenter.default.post(
            name: .DataSourceNeedsProcessed,
            object: DataSourceUpdatedNotification(key: Asam.key)
        )
        NotificationCenter.default.post(
            name: .DataSourceUpdated,
            object: DataSourceUpdatedNotification(key: Asam.key)
        )
    }
    
    override func loadData() async {
        NSLog("ASAM Initial Data Load")
        if self.isCancelled {
            return
        }
        if let url = bundle.url(forResource: "asam", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let asamPropertyContainer = try decoder.decode(AsamPropertyContainer.self, from: data)
                    count = await localDataSource.insert(task: nil, asams: asamPropertyContainer.asam)
                } catch {
                    print("error:\(error)")
                }
            }
        
    }
}
