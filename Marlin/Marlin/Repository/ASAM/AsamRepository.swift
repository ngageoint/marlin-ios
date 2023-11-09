//
//  AsamRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/23.
//

import Foundation
import Combine

class AsamRepository: ObservableObject {
    var localDataSource: AsamLocalDataSource
    private var remoteDataSource: AsamRemoteDataSource
    init(localDataSource: AsamLocalDataSource, remoteDataSource: AsamRemoteDataSource) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }
    func getAsam(reference: String?) -> AsamModel? {
        localDataSource.getAsam(reference: reference)
    }
    func getAsams(filters: [DataSourceFilterParameter]?) -> [AsamModel] {
        localDataSource.getAsams(filters: filters)
    }
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }
    func observeAsamListItems(filters: [DataSourceFilterParameter]?) -> AnyPublisher<CollectionDifference<AsamModel>, Never> {
        localDataSource.observeAsamListItems(filters: filters)
    }
    func fetchAsams(refresh: Bool = false) async -> [AsamModel] {
        NSLog("Fetching ASAMS with refresh? \(refresh)")
        if refresh {
            DispatchQueue.main.async {
                MSI.shared.appState.loadingDataSource[Asam.key] = true
                NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: Asam.self))
            }
            
            let newestAsam = localDataSource.getNewestAsam()
            
            let asams = await remoteDataSource.fetchAsams(dateString: newestAsam?.dateString)
            let inserted = await localDataSource.insert(task: nil, asams: asams)
            
            DispatchQueue.main.async {
                MSI.shared.appState.loadingDataSource[Asam.key] = false
                UserDefaults.standard.updateLastSyncTimeSeconds(Asam.definition)
                NotificationCenter.default.post(name: .DataSourceLoaded, object: DataSourceItem(dataSource: Asam.self))
                    if inserted != 0 {
                        NotificationCenter.default.post(name: .DataSourceNeedsProcessed, object: DataSourceUpdatedNotification(key: Asam.definition.key))
                        NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceUpdatedNotification(key: Asam.definition.key))
                    }
            }
            
            return asams
        }
        return localDataSource.getAsams(filters: nil)
    }
}
