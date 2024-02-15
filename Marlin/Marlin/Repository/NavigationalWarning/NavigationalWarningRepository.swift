//
//  NavigationalWarningRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 10/27/23.
//

import Foundation
import CoreData
import Combine

enum NavigationalWarningItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let navigationalWarning):
            return navigationalWarning.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ navigationalWarning: NavigationalWarningModel)
    case sectionHeader(header: String)
}

class NavigationalWarningRepository: ObservableObject {
    var localDataSource: NavigationalWarningLocalDataSource
    private var remoteDataSource: NavigationalWarningRemoteDataSource
    init(localDataSource: NavigationalWarningLocalDataSource, remoteDataSource: NavigationalWarningRemoteDataSource) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    func createOperation() -> NavigationalWarningDataFetchOperation {
        return NavigationalWarningDataFetchOperation()
    }

    func getNavigationalWarning(msgYear: Int64, msgNumber: Int64, navArea: String?) -> NavigationalWarningModel? {
        localDataSource.getNavigationalWarning(msgYear: msgYear, msgNumber: msgNumber, navArea: navArea)
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }

    func getNavigationalWarnings(
        filters: [DataSourceFilterParameter]?
    ) async -> [NavigationalWarningModel] {
        await localDataSource.getNavigationalWarnings(filters: filters)
    }

    func navigationalWarnings(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[NavigationalWarningItem], Error> {
        localDataSource.navigationalWarnings(filters: filters, paginatedBy: paginator)
    }

    func fetch() async -> [NavigationalWarningModel] {
        NSLog("Fetching Navigational Warnings")
        await MainActor.run {
            MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] = true
            NotificationCenter.default.post(
                name: .DataSourceLoading,
                object: DataSourceItem(dataSource: DataSources.navWarning)
            )
        }

        let navWarnings = await remoteDataSource.fetch()
        let inserted = await localDataSource.insert(task: nil, navigationalWarnings: navWarnings)

        await MainActor.run {
            MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] = false
            UserDefaults.standard.updateLastSyncTimeSeconds(DataSources.navWarning)
            NotificationCenter.default.post(
                name: .DataSourceLoaded,
                object: DataSourceItem(dataSource: DataSources.navWarning)
            )
            if inserted != 0 {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.navWarning.key, inserts: inserted)
                )
            }
        }

        return navWarnings
    }
}
