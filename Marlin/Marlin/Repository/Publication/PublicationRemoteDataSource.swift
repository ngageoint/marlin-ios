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
    static var currentValue: any PublicationRemoteDataSource = PublicationRemoteDataSourceImpl()
}

extension InjectedValues {
    var publicationRemoteDataSource: any  PublicationRemoteDataSource {
        get { Self[PublicationRemoteDataSourceProviderKey.self] }
        set { Self[PublicationRemoteDataSourceProviderKey.self] = newValue }
    }
}

protocol PublicationRemoteDataSource: RemoteDataSource {
    func fetch() async -> [PublicationModel]
    func downloadFile(model: PublicationModel, subject: PassthroughSubject<DownloadProgress, Never>)
    func cancelDownload(model: PublicationModel)
    func cleanupDownload(model: PublicationModel)
}

actor PublicationRemoteDataSourceImpl: PublicationRemoteDataSource {
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
    
    func fetch() async -> [PublicationModel] {
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
