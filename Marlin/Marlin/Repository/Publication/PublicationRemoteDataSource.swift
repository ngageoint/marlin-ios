//
//  PublicationRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks
import Combine

private struct PublicationRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: PublicationRemoteDataSource = PublicationRemoteDataSource()
}

extension InjectedValues {
    var publicationRemoteDataSource: PublicationRemoteDataSource {
        get { Self[PublicationRemoteDataSourceProviderKey.self] }
        set { Self[PublicationRemoteDataSourceProviderKey.self] = newValue }
    }
}

class PublicationRemoteDataSource: RemoteDataSource {
    var downloads: [String: DownloadManager] = [:]
    
    typealias DataModel = PublicationModel
    
    let _backgroundFetchQueue: OperationQueue
    
    init() {
        self._backgroundFetchQueue = OperationQueue()
        self._backgroundFetchQueue.maxConcurrentOperationCount = 1
        self._backgroundFetchQueue.name = "\(DataSources.epub.name) fetch queue"
    }
    
    func dataSource() -> any DataSourceDefinition {
        DataSources.epub
    }
    
    func backgroundFetchQueue() -> OperationQueue {
        _backgroundFetchQueue
    }
//    init() {
//        super.init(dataSource: DataSources.epub)
//    }

    func fetch(
        task: BGTask? = nil
    ) async -> [PublicationModel] {
        let operation = PublicationDataFetchOperation()
        return await fetch(operation: operation)
    }

    func downloadFile(model: PublicationModel, subject: PassthroughSubject<DownloadProgress, Never>) {
        let downloadManager = DownloadManager(subject: subject, downloadable: model)
        downloads[model.id] = downloadManager
        downloadManager.download()
    }

    func cancelDownload(model: PublicationModel) {
        cleanupDownload(model: model)
        downloads[model.id]?.cancel()
    }

    func cleanupDownload(model: PublicationModel) {
        downloads.removeValue(forKey: model.id)
    }
}
