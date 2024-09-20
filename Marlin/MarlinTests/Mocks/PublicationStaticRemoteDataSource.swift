//
//  PublicationStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation
import BackgroundTasks
import Combine

@testable import Marlin

actor PublicationStaticRemoteDataSource: PublicationRemoteDataSource {
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
    
    var list: [PublicationModel] = []
    
    func setList(_ list: [PublicationModel]) {
        self.list = list
    }

    func fetch() async -> [PublicationModel] {
        return list
    }

    func downloadFile(model: PublicationModel, subject: PassthroughSubject<DownloadProgress, Never>) {
        let downloadManager = DownloadManager(subject: subject, downloadable: model)
        
        let config = URLSessionConfiguration.default
        downloadManager.sessionConfig = config
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
