//
//  NoticeToMarinersRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks
import Combine

class NoticeToMarinersRemoteDataSource: RemoteDataSource<NoticeToMarinersModel> {
    var downloads: [String: DownloadManager] = [:]

    init(cleanup: (() -> Void)? = nil) {
        super.init(dataSource: DataSources.noticeToMariners, cleanup: cleanup)
    }

    func fetch(
        task: BGTask? = nil,
        noticeNumber: Int? = nil
    ) async -> [NoticeToMarinersModel] {
        let operation = NoticeToMarinersDataFetchOperation(noticeNumber: noticeNumber)
        return await fetch(task: task, operation: operation)
    }

    func downloadFile(model: NoticeToMarinersModel, subject: PassthroughSubject<DownloadProgress, Never>) {
        let downloadManager = DownloadManager(subject: subject, downloadable: model)
        downloads[model.id] = downloadManager
        downloadManager.download()
    }

    func cancelDownload(model: NoticeToMarinersModel) {
        downloads[model.id]?.cancel()
    }

    func cleanupDownload(model: NoticeToMarinersModel) {
        downloads.removeValue(forKey: model.id)
    }
}