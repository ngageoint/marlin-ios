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

class NoticeToMarinersRepository: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    @Injected(\.ntmLocalDataSource)
    private var localDataSource: NoticeToMarinersLocalDataSource
    @Injected(\.ntmRemoteDataSource)
    private var remoteDataSource: NoticeToMarinersRemoteDataSource

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
        let inserted = await localDataSource.insert(task: nil, noticeToMariners: notices)

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
    func downloadFile(odsEntryId: Int) {
        guard let notice = localDataSource.getNoticeToMariners(odsEntryId: odsEntryId) else {
            return
        }
        if notice.isDownloaded == true && localDataSource.checkFileExists(odsEntryId: odsEntryId) {
            return
        }
        let subject = PassthroughSubject<DownloadProgress, Never>()
        var cancellable: AnyCancellable?
        cancellable = subject
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.remoteDataSource.cleanupDownload(model: notice)
                    if let cancellable = cancellable {
                        self?.cancellables.remove(cancellable)
                    }
                },
                receiveValue: { downloadProgress in
                    self.localDataSource.updateProgress(odsEntryId: odsEntryId, progress: downloadProgress)
                }
            )
        if let cancellable = cancellable {
            cancellable.store(in: &cancellables)
        }

        remoteDataSource.downloadFile(model: notice, subject: subject)
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

    func cancelDownload(odsEntryId: Int) {
        guard let notice = localDataSource.getNoticeToMariners(odsEntryId: odsEntryId) else {
            return
        }
        remoteDataSource.cancelDownload(model: notice)
        localDataSource.updateProgress(odsEntryId: odsEntryId, progress: DownloadProgress(
            id: "\(odsEntryId)",
            isDownloading: false,
            isDownloaded: false,
            downloadProgress: 0.0,
            error: ""
        ))
    }
}
