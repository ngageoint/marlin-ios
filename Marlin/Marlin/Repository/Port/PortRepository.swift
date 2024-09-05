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

    func createOperation() -> PortDataFetchOperation {
        return PortDataFetchOperation()
    }

    func getPort(portNumber: Int?) -> PortModel? {
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

    func getPorts(
        filters: [DataSourceFilterParameter]?
    ) async -> [PortModel] {
        await localDataSource.getPorts(filters: filters)
    }

    func fetchPorts() async -> [PortModel] {
        NSLog("Fetching Ports")
        await MainActor.run {
            MSI.shared.appState.loadingDataSource[DataSources.port.key] = true
            NotificationCenter.default.post(
                name: .DataSourceLoading,
                object: DataSourceItem(dataSource: DataSources.port)
            )
        }

        let ports = await remoteDataSource.fetch()
        let inserted = await localDataSource.insert(task: nil, ports: ports)

        await MainActor.run {
            MSI.shared.appState.loadingDataSource[DataSources.port.key] = false
            UserDefaults.standard.updateLastSyncTimeSeconds(DataSources.port)
            NotificationCenter.default.post(
                name: .DataSourceLoaded,
                object: DataSourceItem(dataSource: DataSources.port)
            )
            if inserted != 0 {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.port.key, inserts: inserted)
                )
            }
        }

        return ports
    }
}
