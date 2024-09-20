//
//  NoticeToMarinersRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation
import Combine

enum NoticeToMarinersItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .week(let noticeNumber):
            return "week-\(noticeNumber)"
        case .listItem(let ntm):
            return "ntmid-\(ntm.id)"
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ ntm: NoticeToMarinersListModel)
    case sectionHeader(header: String)
    case week(noticeNumber: Int)
}

private struct NoticeToMarinersRepositoryProviderKey: InjectionKey {
    static var currentValue: NoticeToMarinersRepository = NoticeToMarinersRepository()
}

extension InjectedValues {
    var ntmRepository: NoticeToMarinersRepository {
        get { Self[NoticeToMarinersRepositoryProviderKey.self] }
        set { Self[NoticeToMarinersRepositoryProviderKey.self] = newValue }
    }
}

actor NoticeToMarinersRepository {
    private var cancellables = Set<AnyCancellable>()

    @Injected(\.ntmLocalDataSource)
    private var localDataSource: NoticeToMarinersLocalDataSource
    @Injected(\.ntmRemoteDataSource)
    private var remoteDataSource: any NoticeToMarinersRemoteDataSource

    func createOperation() -> NoticeToMarinersDataFetchOperation {
        let newestNotice = localDataSource.getNewestNoticeToMariners()
        return NoticeToMarinersDataFetchOperation(noticeNumber: newestNotice?.noticeNumber)
    }

    func getNoticesToMariners(
        noticeNumber: Int?
    ) -> [NoticeToMarinersModel]? {
        localDataSource.getNoticesToMariners(noticeNumber: noticeNumber)
    }
    func getNoticeToMariners(
        odsEntryId: Int?
    ) -> NoticeToMarinersModel? {
        localDataSource.getNoticeToMariners(odsEntryId: odsEntryId)
    }
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }
    func noticeToMariners(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[NoticeToMarinersItem], Error> {
        localDataSource.noticeToMariners(filters: filters, paginatedBy: paginator)
    }

    func sectionHeaders(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[NoticeToMarinersItem], Error> {
        localDataSource.sectionHeaders(filters: filters, paginatedBy: paginator)
    }

    func getNoticesToMariners(
        filters: [DataSourceFilterParameter]?
    ) async -> [NoticeToMarinersModel] {
        await localDataSource.getNoticesToMariners(filters: filters)
    }

    func fetchNoticeToMariners() async -> [NoticeToMarinersModel] {
        NSLog("Fetching Notices To Mariners ")
        await MainActor.run {
            MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] = true
            NotificationCenter.default.post(
                name: .DataSourceLoading,
                object: DataSourceItem(dataSource: DataSources.noticeToMariners)
            )
        }

        let newestNotice = localDataSource.getNewestNoticeToMariners()

        let notices = await remoteDataSource.fetch(noticeNumber: newestNotice?.noticeNumber)
        let inserted = await localDataSource.insert(
            task: nil,
            noticeToMariners: notices
        )

        await MainActor.run {
            MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] = false
            UserDefaults.standard.updateLastSyncTimeSeconds(DataSources.noticeToMariners)
            NotificationCenter.default.post(
                name: .DataSourceLoaded,
                object: DataSourceItem(dataSource: DataSources.noticeToMariners)
            )
            if inserted != 0 {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.noticeToMariners.key, inserts: inserted)
                )
            }
        }

        return notices
    }
}

extension NoticeToMarinersRepository {
    func removeCancellable(_ cancellable: AnyCancellable) async {
        cancellables.remove(cancellable)
    }
    
    func downloadFile(odsEntryId: Int) async {
        guard let notice = localDataSource.getNoticeToMariners(odsEntryId: odsEntryId) else {
            return
        }
        if notice.isDownloaded == true && localDataSource.checkFileExists(odsEntryId: odsEntryId) {
            return
        }
        let subject = PassthroughSubject<DownloadProgress, Never>()
        
//        let connectable = subject.makeConnectable()
//        connectable.sink(
//            receiveCompletion: { [weak self] _ in
//                Task {
////                    print(connectable)
//                        await self?.remoteDataSource.cleanupDownload(model: notice)
////                        if let cancellable = cancellable {
////                            await self?.removeCancellable(cancellable)
////                        }
//                }
//            },
//            receiveValue: { downloadProgress in
//                self.localDataSource.updateProgress(odsEntryId: odsEntryId, progress: downloadProgress)
//            }
//        )
//        .store(in: &cancellables)
//        connectable.connect().store(in: &cancellables)
        
        var cancellable: AnyCancellable?
        cancellable = subject
            .sink(
                receiveCompletion: { [weak self] _ in
                    Task {
                        await self?.remoteDataSource.cleanupDownload(model: notice)
                        if let cancellable = cancellable {
                            await self?.removeCancellable(cancellable)
                        }
                    }
                },
                receiveValue: { downloadProgress in
                    self.localDataSource.updateProgress(odsEntryId: odsEntryId, progress: downloadProgress)
                }
            )
        if let cancellable = cancellable {
            cancellable.store(in: &cancellables)
        }

        await remoteDataSource.downloadFile(model: notice, subject: subject)
    }

    func deleteFile(odsEntryId: Int) {
        localDataSource.deleteFile(odsEntryId: odsEntryId)
    }

    func observeNoticeToMariners(
        odsEntryId: Int
    ) -> AnyPublisher<NoticeToMarinersModel, Never>? {
        return localDataSource.observeNoticeToMariners(odsEntryId: odsEntryId)
    }

    func checkFileExists(odsEntryId: Int) -> Bool {
        return localDataSource.checkFileExists(odsEntryId: odsEntryId)
    }

    func cancelDownload(odsEntryId: Int) async {
        guard let notice = localDataSource.getNoticeToMariners(odsEntryId: odsEntryId) else {
            return
        }
        await remoteDataSource.cancelDownload(model: notice)
        localDataSource.updateProgress(odsEntryId: odsEntryId, progress: DownloadProgress(
            id: "\(odsEntryId)",
            isDownloading: false,
            isDownloaded: false,
            downloadProgress: 0.0,
            error: ""
        ))
    }
}
