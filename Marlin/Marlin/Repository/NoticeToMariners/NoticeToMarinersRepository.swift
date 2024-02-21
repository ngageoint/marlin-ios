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
        case .listItem(let ntm):
            return ntm.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ ntm: NoticeToMarinersListModel)
    case sectionHeader(header: String)
}

class NoticeToMarinersRepository: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    var localDataSource: NoticeToMarinersLocalDataSource
    private var remoteDataSource: NoticeToMarinersRemoteDataSource
    init(localDataSource: NoticeToMarinersLocalDataSource, remoteDataSource: NoticeToMarinersRemoteDataSource) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    func createOperation() -> NoticeToMarinersDataFetchOperation {
        let newestNotice = localDataSource.getNewestNoticeToMariners()
        return NoticeToMarinersDataFetchOperation(noticeNumber: newestNotice?.noticeNumber)
    }

    func getNoticeToMariners(
        noticeNumber: Int?
    ) -> NoticeToMarinersModel? {
        localDataSource.getNoticeToMariners(noticeNumber: noticeNumber)
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
    func downloadFile(id: Int) {
        guard let notice = localDataSource.getNoticeToMariners(noticeNumber: Int(id)) else {
            return
        }
        if notice.isDownloaded == true && localDataSource.checkFileExists(noticeNumber: id) {
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
                    self.localDataSource.updateProgress(noticeNumber: id, progress: downloadProgress)
                }
            )
        if let cancellable = cancellable {
            cancellable.store(in: &cancellables)
        }

        remoteDataSource.downloadFile(model: notice, subject: subject)
    }

    func deleteFile(id: Int) {
        localDataSource.deleteFile(noticeNumber: id)
    }

    func observeNoticeToMariners(
        noticeNumber: Int
    ) -> AnyPublisher<NoticeToMarinersModel, Never>? {
        return localDataSource.observeNoticeToMariners(noticeNumber: noticeNumber)
    }

    func checkFileExists(id: Int) -> Bool {
        return localDataSource.checkFileExists(noticeNumber: id)
    }

    func cancelDownload(noticeNumber: Int) {
        guard let notice = localDataSource.getNoticeToMariners(noticeNumber: noticeNumber) else {
            return
        }
        remoteDataSource.cancelDownload(model: notice)
        localDataSource.updateProgress(noticeNumber: noticeNumber, progress: DownloadProgress(
            id: notice.id,
            isDownloading: false,
            isDownloaded: false,
            downloadProgress: 0.0,
            error: ""
        ))
    }
}
