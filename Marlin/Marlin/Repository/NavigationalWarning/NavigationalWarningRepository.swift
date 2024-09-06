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

struct NavigationalAreaInformation: Identifiable {
    var id: String { navArea.name }
    let navArea: NavigationalWarningNavArea
    let unread: Int
    let total: Int
}

private struct NavigationalWarningRepositoryProviderKey: InjectionKey {
    static var currentValue: NavigationalWarningRepository = NavigationalWarningRepository()
}

extension InjectedValues {
    var navWarningRepository: NavigationalWarningRepository {
        get { Self[NavigationalWarningRepositoryProviderKey.self] }
        set { Self[NavigationalWarningRepositoryProviderKey.self] = newValue }
    }
}

class NavigationalWarningRepository: ObservableObject {
    @Injected(\.navWarningLocalDataSource)
    var localDataSource: NavigationalWarningLocalDataSource
    @Injected(\.navWarningRemoteDataSource)
    private var remoteDataSource: NavigationalWarningRemoteDataSource

    func createOperation() -> NavigationalWarningDataFetchOperation {
        return NavigationalWarningDataFetchOperation()
    }

    func getNavAreasInformation() async -> [NavigationalAreaInformation] {
        await localDataSource.getNavAreasInformation()
    }

    func getNavigationalWarning(msgYear: Int, msgNumber: Int, navArea: String?) -> NavigationalWarningModel? {
        localDataSource.getNavigationalWarning(msgYear: msgYear, msgNumber: msgNumber, navArea: navArea)
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }

    func getNavAreaNavigationalWarnings(navArea: String) async -> [NavigationalWarningModel] {
        // if navArea == "unknown" get unparsed locations
        await getNavigationalWarnings(filters: [
            DataSourceFilterParameter(
                property: DataSourceProperty(
                    name: "Navigational Area",
                    key: "navArea",
                    type: .string
                ),
                comparison: .equals,
                valueString: navArea
            )
        ])
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
