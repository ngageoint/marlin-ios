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
                MSI.shared.appState.loadingDataSource[Modu.key] = true
                NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: DataSources.modu))
            }

            let newestModu = localDataSource.getNewestModu()

            let modus = await remoteDataSource.fetchModus(dateString: newestModu?.dateString)
            let inserted = await localDataSource.insert(task: nil, modus: modus)

            DispatchQueue.main.async {
                MSI.shared.appState.loadingDataSource[Modu.key] = false
                UserDefaults.standard.updateLastSyncTimeSeconds(Modu.definition)
                NotificationCenter.default.post(name: .DataSourceLoaded, object: DataSourceItem(dataSource: DataSources.modu))
                if inserted != 0 {
                    NotificationCenter.default.post(
                        name: .DataSourceNeedsProcessed,
                        object: DataSourceUpdatedNotification(key: Modu.definition.key)
                    )
                    NotificationCenter.default.post(
                        name: .DataSourceUpdated,
                        object: DataSourceUpdatedNotification(key: Modu.definition.key)
                    )
                }
            }

            return modus
        }
        return localDataSource.getModus(filters: nil)
    }
}

protocol ModuRepositoryProtocol {
    @discardableResult
    func getModu(name: String?, waypointURI: URL?) -> ModuModel?
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
}

class ModuRepositoryManager: ModuRepositoryProtocol, ObservableObject {
    private var repository: ModuRepositoryProtocol
    
    init(repository: ModuRepositoryProtocol) {
        self.repository = repository
    }
    
    func getModu(name: String?, waypointURI: URL?) -> ModuModel? {
        repository.getModu(name: name, waypointURI: waypointURI)
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        repository.getCount(filters: filters)
    }
}

class ModuCoreDataRepository: ModuRepositoryProtocol, ObservableObject {
    private var context: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getModu(name: String?, waypointURI: URL?) -> ModuModel? {
        if let waypointURI = waypointURI {
            if let id = context.persistentStoreCoordinator?.managedObjectID(
                forURIRepresentation: waypointURI
            ), let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
                let dataSource = waypoint.decodeToDataSource()
                if let dataSource = dataSource as? ModuModel {
                    return dataSource
                }
            }
        }
        if let name = name {
            if let modu = context.fetchFirst(Modu.self, key: "name", value: name) {
                return ModuModel(modu: modu)
            }
        }
        return nil
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        guard let fetchRequest = ModuFilterable().fetchRequest(filters: filters, commonFilters: nil) else {
            return 0
        }
        return (try? context.count(for: fetchRequest)) ?? 0
    }
}
