//
//  PortRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/23.
//

import Foundation
import Combine

enum PortItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let port):
            return port.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ port: PortListModel)
    case sectionHeader(header: String)
}

class PortRepository: ObservableObject {
    var localDataSource: PortLocalDataSource
    private var remoteDataSource: PortRemoteDataSource
    init(localDataSource: PortLocalDataSource, remoteDataSource: PortRemoteDataSource) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    func getPort(portNumber: Int64?) -> PortModel? {
        localDataSource.getPort(portNumber: portNumber)
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }

    func ports(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[PortItem], Error> {
        localDataSource.ports(filters: filters, paginatedBy: paginator)
    }

    func fetchPorts() async -> [PortModel] {
        NSLog("Fetching Ports")
        DispatchQueue.main.async {
            MSI.shared.appState.loadingDataSource[DataSources.port.key] = true
            NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: DataSources.port))
        }

        let ports = await remoteDataSource.fetch()
        let inserted = await localDataSource.insert(task: nil, ports: ports)

        DispatchQueue.main.async {
            MSI.shared.appState.loadingDataSource[DataSources.port.key] = false
            UserDefaults.standard.updateLastSyncTimeSeconds(DataSources.port)
            NotificationCenter.default.post(name: .DataSourceLoaded, object: DataSourceItem(dataSource: DataSources.port))
            if inserted != 0 {
                NotificationCenter.default.post(
                    name: .DataSourceNeedsProcessed,
                    object: DataSourceUpdatedNotification(key: DataSources.port.key)
                )
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.port.key)
                )
            }
        }

        return ports
    }
}

// protocol PortRepository2 {
//    @discardableResult
//    func getPort(portNumber: Int64?, waypointURI: URL?) -> PortModel?
//    func getCount(filters: [DataSourceFilterParameter]?) -> Int
// }
//
// class PortRepositoryManager2: PortRepository2, ObservableObject {
//    private var repository: PortRepository2
//    init(repository: PortRepository2) {
//        self.repository = repository
//    }
//    
//    func getPort(portNumber: Int64?, waypointURI: URL?) -> PortModel? {
//        repository.getPort(portNumber: portNumber, waypointURI: waypointURI)
//    }
//    
//    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
//        repository.getCount(filters: filters)
//    }
// }
//
// class PortCoreDataRepository: PortRepository2, ObservableObject {
//    private var context: NSManagedObjectContext
//    required init(context: NSManagedObjectContext) {
//        self.context = context
//    }
//    
//    func getPort(portNumber: Int64?, waypointURI: URL?) -> PortModel? {
//        if let waypointURI = waypointURI {
//            if let id = context.persistentStoreCoordinator?.managedObjectID(
//                forURIRepresentation: waypointURI
//            ), let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
//                let dataSource = waypoint.decodeToDataSource()
//                if let dataSource = dataSource as? PortModel {
//                    return dataSource
//                }
//            }
//        }
//        if let portNumber = portNumber {
//            if let port = context.fetchFirst(Port.self, key: "portNumber", value: portNumber) {
//                return PortModel(port: port)
//            }
//        }
//        return nil
//    }
//    
//    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
//        guard let fetchRequest = PortFilterable().fetchRequest(filters: filters, commonFilters: nil) else {
//            return 0
//        }
//        return (try? context.count(for: fetchRequest)) ?? 0
//    }
// }
