//
//  PublicationRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import Combine

enum PublicationItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let epub):
            return epub.id
        case .sectionHeader(let header):
            return header
        case .pubType(let type, _):
            return type.description
        }
    }

    case listItem(_ epub: PublicationListModel)
    case sectionHeader(header: String)
    case pubType(type: PublicationTypeEnum, count: Int)
}

private struct PublicationRepositoryProviderKey: InjectionKey {
    static var currentValue: PublicationRepository = PublicationRepository()
}

extension InjectedValues {
    var publicationRepository: PublicationRepository {
        get { Self[PublicationRepositoryProviderKey.self] }
        set { Self[PublicationRepositoryProviderKey.self] = newValue }
    }
}

actor PublicationRepository: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    @Injected(\.publicationLocalDataSource)
    var localDataSource: PublicationLocalDataSource
    @Injected(\.publicationRemoteDataSource)
    private var remoteDataSource: any PublicationRemoteDataSource

    func createOperation() -> PublicationDataFetchOperation {
        return PublicationDataFetchOperation()
    }

    func getPublication(s3Key: String?) -> PublicationModel? {
        return localDataSource.getPublication(s3Key: s3Key)
    }
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }

    func getPublications(typeId: Int) async -> [PublicationModel] {
        await localDataSource.getPublications(typeId: typeId)
    }

    func getSections() async -> [PublicationItem] {
        await localDataSource.getSections(filters: nil) ?? []
    }

    func sectionHeaders(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[PublicationItem], Error> {
        localDataSource.sectionHeaders(filters: filters, paginatedBy: paginator)
    }

    func pubs(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[PublicationItem], Error> {
        localDataSource.pubs(filters: filters, paginatedBy: paginator)
    }

    func fetch() async -> [PublicationModel] {
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

extension PublicationRepository {
    func removeCancellable(_ cancellable: AnyCancellable) async {
        cancellables.remove(cancellable)
    }
    
    func downloadFile(id: String) async {
        guard let publication = localDataSource.getPublication(s3Key: id) else {
            return
        }
        if publication.isDownloaded == true && localDataSource.checkFileExists(s3Key: id) {
            return
        }
        let subject = PassthroughSubject<DownloadProgress, Never>()
        var cancellable: AnyCancellable?
        cancellable = subject
            .sink(
                receiveCompletion: { [weak self] _ in
                    Task {
                        await self?.remoteDataSource.cleanupDownload(model: publication)
                        if let cancellable = cancellable {
                            await self?.removeCancellable(cancellable)
                        }
                    }
                },
                receiveValue: { downloadProgress in
                    self.localDataSource.updateProgress(s3Key: id, progress: downloadProgress)
                }
            )
        if let cancellable = cancellable {
            cancellable.store(in: &cancellables)
        }

        await remoteDataSource.downloadFile(
            model: publication,
            subject: subject
        )
    }

    func deleteFile(id: String) {
        localDataSource.deleteFile(s3Key: id)
    }

    func observePublication(
        s3Key: String
    ) -> AnyPublisher<PublicationModel, Never>? {
        return localDataSource.observePublication(s3Key: s3Key)
    }

    func checkFileExists(id: String) -> Bool {
        print("XXX checking file exists in local data source \(localDataSource)")
        return localDataSource.checkFileExists(s3Key: id)
    }

    func cancelDownload(s3Key: String) async {
        guard let publication = localDataSource.getPublication(s3Key: s3Key) else {
            return
        }
        await remoteDataSource.cancelDownload(model: publication)
        localDataSource.updateProgress(s3Key: s3Key, progress: DownloadProgress(
            id: publication.id,
            isDownloading: false,
            isDownloaded: false,
            downloadProgress: 0.0,
            error: ""
        ))
    }
}
