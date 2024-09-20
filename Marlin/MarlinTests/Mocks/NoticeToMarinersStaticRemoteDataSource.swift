//
//  NoticeToMarinersStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/21/24.
//

import Foundation
import BackgroundTasks
import Combine

@testable import Marlin

actor NoticeToMarinersStaticRemoteDataSource: NoticeToMarinersRemoteDataSource {
    var downloads: [String: DownloadManager] = [:]
    typealias DataModel = NoticeToMarinersModel
    
    let _backgroundFetchQueue: OperationQueue
    
    init() {
        self._backgroundFetchQueue = OperationQueue()
        self._backgroundFetchQueue.maxConcurrentOperationCount = 1
        self._backgroundFetchQueue.name = "\(DataSources.noticeToMariners.name) fetch queue"
    }
    
    func dataSource() -> any DataSourceDefinition {
        DataSources.noticeToMariners
    }
    
    func backgroundFetchQueue() -> OperationQueue {
        _backgroundFetchQueue
    }
    
    var list: [NoticeToMarinersModel] = []

    func fetch(
        noticeNumber: Int? = nil
    ) async -> [NoticeToMarinersModel] {
        return list
    }

    func downloadFile(model: NoticeToMarinersModel, subject: PassthroughSubject<DownloadProgress, Never>) {
        let downloadManager = DownloadManager(subject: subject, downloadable: model)

        let config = URLSessionConfiguration.default
        downloadManager.sessionConfig = config
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
