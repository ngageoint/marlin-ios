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
