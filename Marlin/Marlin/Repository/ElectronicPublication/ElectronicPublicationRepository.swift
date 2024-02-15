//
//  ElectronicPublicationRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import Combine

enum ElectronicPublicationItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let epub):
            return epub.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ epub: ElectronicPublicationListModel)
    case sectionHeader(header: String)
}

class ElectronicPublicationRepository: ObservableObject {
    var localDataSource: ElectronicPublicationLocalDataSource
    private var remoteDataSource: ElectronicPublicationRemoteDataSource
    init(
        localDataSource: ElectronicPublicationLocalDataSource,
        remoteDataSource: ElectronicPublicationRemoteDataSource
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    func createOperation() -> ElectronicPublicationDataFetchOperation {
        return ElectronicPublicationDataFetchOperation()
    }

    func getElectronicPublication(s3Key: String?) -> ElectronicPublicationModel? {
        localDataSource.getElectronicPublication(s3Key: s3Key)
    }
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }

    func sectionHeaders(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[ElectronicPublicationItem], Error> {
        localDataSource.sectionHeaders(filters: filters, paginatedBy: paginator)
    }

    func epubs(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[ElectronicPublicationItem], Error> {
        localDataSource.epubs(filters: filters, paginatedBy: paginator)
    }

    func fetch() async -> [ElectronicPublicationModel] {
        NSLog("Fetching Electronic Publications")
        await MainActor.run {
            MSI.shared.appState.loadingDataSource[DataSources.epub.key] = true
            NotificationCenter.default.post(
                name: .DataSourceLoading,
                object: DataSourceItem(dataSource: DataSources.epub)
            )
        }

        let epubs = await remoteDataSource.fetch()
        let inserted = await localDataSource.insert(task: nil, epubs: epubs)

        await MainActor.run {
            MSI.shared.appState.loadingDataSource[DataSources.epub.key] = false
            UserDefaults.standard.updateLastSyncTimeSeconds(DataSources.epub)
            NotificationCenter.default.post(
                name: .DataSourceLoaded,
                object: DataSourceItem(dataSource: DataSources.epub)
            )
            if inserted != 0 {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.epub.key, inserts: inserted)
                )
            }
        }

        return epubs
    }

}
