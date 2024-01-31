//
//  ModuRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/23.
//

import Foundation
import CoreData
import Combine

enum ModuItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let modu):
            return modu.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ modu: ModuListModel)
    case sectionHeader(header: String)
}

class ModuRepository: ObservableObject {
    var localDataSource: ModuLocalDataSource
    private var remoteDataSource: ModuRemoteDataSource

    init(
        localDataSource: ModuLocalDataSource,
        remoteDataSource: ModuRemoteDataSource
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    func getModu(name: String?) -> ModuModel? {
        localDataSource.getModu(name: name)
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }

    func modus(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[ModuItem], Error> {
        localDataSource.modus(filters: filters, paginatedBy: paginator)
    }

    func fetchModus(refresh: Bool = false) async -> [ModuModel] {
        NSLog("Fetching MODUs with refresh? \(refresh)")
        if refresh {
            DispatchQueue.main.async {
                MSI.shared.appState.loadingDataSource[DataSources.modu.key] = true
                NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: DataSources.modu))
            }

            let newestModu = localDataSource.getNewestModu()

            let modus = await remoteDataSource.fetchModus(dateString: newestModu?.dateString)
            let inserted = await localDataSource.insert(task: nil, modus: modus)

            DispatchQueue.main.async {
                MSI.shared.appState.loadingDataSource[DataSources.modu.key] = false
                UserDefaults.standard.updateLastSyncTimeSeconds(DataSources.modu)
                NotificationCenter.default.post(name: .DataSourceLoaded, object: DataSourceItem(dataSource: DataSources.modu))
                if inserted != 0 {
                    NotificationCenter.default.post(
                        name: .DataSourceNeedsProcessed,
                        object: DataSourceUpdatedNotification(key: DataSources.modu.key)
                    )
                    NotificationCenter.default.post(
                        name: .DataSourceUpdated,
                        object: DataSourceUpdatedNotification(key: DataSources.modu.key)
                    )
                }
            }

            return modus
        }
        return localDataSource.getModus(filters: nil)
    }
}
