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

    func createOperation() -> ModuDataFetchOperation {
        let newestModu = localDataSource.getNewestModu()
        return ModuDataFetchOperation(dateString: newestModu?.dateString)
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

    func getModus(
        filters: [DataSourceFilterParameter]?
    ) async -> [ModuModel] {
        await localDataSource.getModus(filters: filters)
    }

    func fetchModus() async -> [ModuModel] {
        NSLog("Fetching MODUs")
        DispatchQueue.main.async {
            MSI.shared.appState.loadingDataSource[DataSources.modu.key] = true
            NotificationCenter.default.post(
                name: .DataSourceLoading,
                object: DataSourceItem(dataSource: DataSources.modu)
            )
        }

        let newestModu = localDataSource.getNewestModu()

        let modus = await remoteDataSource.fetch(dateString: newestModu?.dateString)
        let inserted = await localDataSource.insert(task: nil, modus: modus)

        DispatchQueue.main.async {
            MSI.shared.appState.loadingDataSource[DataSources.modu.key] = false
            UserDefaults.standard.updateLastSyncTimeSeconds(DataSources.modu)
            NotificationCenter.default.post(
                name: .DataSourceLoaded,
                object: DataSourceItem(dataSource: DataSources.modu)
            )
            if inserted != 0 {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.modu.key, inserts: inserted)
                )
            }
        }

        return modus
    }
}
