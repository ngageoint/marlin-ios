//
//  AsamRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/23.
//

import Foundation
import Combine

enum AsamItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let asam):
            return asam.id
        case .sectionHeader(let header):
            return header
        }
    }
    
    case listItem(_ asam: AsamListModel)
    case sectionHeader(header: String)
}

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
    func asams(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[AsamItem], Error> {
        localDataSource.asams(filters: filters, paginatedBy: paginator)
    }

    func fetchAsams(refresh: Bool = false) async -> [AsamModel] {
        NSLog("Fetching ASAMS with refresh? \(refresh)")
        if refresh {
            DispatchQueue.main.async {
                MSI.shared.appState.loadingDataSource[DataSources.asam.key] = true
                NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: DataSources.asam))
            }
            
            let newestAsam = localDataSource.getNewestAsam()
            
            let asams = await remoteDataSource.fetchAsams(dateString: newestAsam?.dateString)
            let inserted = await localDataSource.insert(task: nil, asams: asams)
            
            DispatchQueue.main.async {
                MSI.shared.appState.loadingDataSource[DataSources.asam.key] = false
                UserDefaults.standard.updateLastSyncTimeSeconds(DataSources.asam)
                NotificationCenter.default.post(name: .DataSourceLoaded, object: DataSourceItem(dataSource: DataSources.asam))
                    if inserted != 0 {
                        NotificationCenter.default.post(
                            name: .DataSourceNeedsProcessed,
                            object: DataSourceUpdatedNotification(key: DataSources.asam.key)
                        )
                        NotificationCenter.default.post(
                            name: .DataSourceUpdated,
                            object: DataSourceUpdatedNotification(key: DataSources.asam.key)
                        )
                    }
            }
            
            return asams
        }
        return localDataSource.getAsams(filters: nil)
    }
    
}
