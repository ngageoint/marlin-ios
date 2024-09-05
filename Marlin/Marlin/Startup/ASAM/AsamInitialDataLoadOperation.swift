//
//  AsamInitialDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 11/8/23.
//

import Foundation
import Kingfisher

class AsamInitialDataLoadOperation: CountingDataLoadOperation {
    var localDataSource: AsamLocalDataSource
    var bundle: Bundle
    
    init(localDataSource: AsamLocalDataSource, bundle: Bundle = .main) {
        self.localDataSource = localDataSource
        self.bundle = bundle
    }
    
    @MainActor override func startLoad() {
        MSI.shared.appState.loadingDataSource[DataSources.asam.key] = true

        NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: DataSources.asam))
    }
    
    @MainActor override func finishLoad() {
        Kingfisher.ImageCache(name: DataSources.asam.key).clearCache()
        self.state = .isFinished
        
        MSI.shared.appState.loadingDataSource[DataSources.asam.key] = false
        NotificationCenter.default.post(
            name: .DataSourceLoaded,
            object: DataSourceItem(dataSource: DataSources.asam)
        )
        NotificationCenter.default.post(
            name: .DataSourceUpdated,
            object: DataSourceUpdatedNotification(key: DataSources.asam.key)
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
