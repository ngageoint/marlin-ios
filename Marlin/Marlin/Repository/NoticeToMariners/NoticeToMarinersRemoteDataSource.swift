//
//  NoticeToMarinersRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks
import Combine

// swiftlint:disable type_name
private struct NoticeToMarinersRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: any NoticeToMarinersRemoteDataSource = NoticeToMarinersRemoteDataSourceImpl()
}
// swiftlint:enable type_name

extension InjectedValues {
    var ntmRemoteDataSource: any NoticeToMarinersRemoteDataSource {
        get { Self[NoticeToMarinersRemoteDataSourceProviderKey.self] }
        set { Self[NoticeToMarinersRemoteDataSourceProviderKey.self] = newValue }
    }
}

protocol NoticeToMarinersRemoteDataSource: RemoteDataSource {
    func fetch(
        noticeNumber: Int?
    ) async -> [NoticeToMarinersModel]
    func downloadFile(model: NoticeToMarinersModel, subject: PassthroughSubject<DownloadProgress, Never>)
    func cancelDownload(model: NoticeToMarinersModel)
    func cleanupDownload(model: NoticeToMarinersModel)
}

actor NoticeToMarinersRemoteDataSourceImpl: NoticeToMarinersRemoteDataSource {
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

    func fetch(
        noticeNumber: Int? = nil
    ) async -> [NoticeToMarinersModel] {
        let operation = NoticeToMarinersDataFetchOperation(noticeNumber: noticeNumber)
        return await fetch(operation: operation)
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
