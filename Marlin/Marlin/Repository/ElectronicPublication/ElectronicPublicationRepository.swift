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
    private var cancellables = Set<AnyCancellable>()

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
        return localDataSource.getElectronicPublication(s3Key: s3Key)
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

extension ElectronicPublicationRepository {
    func downloadFile(id: String) {
        guard let electronicPublication = localDataSource.getElectronicPublication(s3Key: id) else {
            return
        }
        if electronicPublication.isDownloaded == true && localDataSource.checkFileExists(s3Key: id) {
            return
        }
        let subject = PassthroughSubject<DownloadProgress, Never>()
        var cancellable: AnyCancellable?
        cancellable = subject
            .sink(
                receiveCompletion: { [weak self] _ in
                    if let cancellable = cancellable {
                        self?.cancellables.remove(cancellable)
                    }
                },
                receiveValue: { downloadProgress in
                    self.localDataSource.updateProgress(s3Key: id, progress: downloadProgress)
                }
            )
        if let cancellable = cancellable {
            cancellable.store(in: &cancellables)
        }

        remoteDataSource.downloadFile(model: electronicPublication, subject: subject)
    }

    func deleteFile(id: String) {
        localDataSource.deleteFile(s3Key: id)
    }

    func observeElectronicPublication(
        s3Key: String
    ) -> AnyPublisher<ElectronicPublicationModel, Never>? {
        return localDataSource.observeElectronicPublication(s3Key: s3Key)
    }

    func checkFileExists(id: String) -> Bool {
        localDataSource.checkFileExists(s3Key: id)
    }

    func cancelDownload(s3Key: String) {
        guard let electronicPublication = localDataSource.getElectronicPublication(s3Key: s3Key) else {
            return
        }
        remoteDataSource.cancelDownload(model: electronicPublication)
        localDataSource.updateProgress(s3Key: s3Key, progress: DownloadProgress(
            id: electronicPublication.id,
            isDownloading: false,
            isDownloaded: false,
            downloadProgress: 0.0,
            error: ""
        ))
    }
}
