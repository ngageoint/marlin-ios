//
//  PublicationRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks
import Combine

class PublicationRemoteDataSource: RemoteDataSource<PublicationModel> {
    var downloads: [String: DownloadManager] = [:]
    init(cleanup: (() -> Void)? = nil) {
        super.init(dataSource: DataSources.epub, cleanup: cleanup)
    }

    func fetch(
        task: BGTask? = nil
    ) async -> [PublicationModel] {
        let operation = PublicationDataFetchOperation()
        return await fetch(task: task, operation: operation)
    }

    func downloadFile(model: PublicationModel, subject: PassthroughSubject<DownloadProgress, Never>) {
        let downloadManager = DownloadManager(subject: subject, downloadable: model)
        downloads[model.id] = downloadManager
        downloadManager.download()
    }

    func cancelDownload(model: PublicationModel) {
        downloads[model.id]?.cancel()
    }

    func cleanupDownload(model: PublicationModel) {
        downloads.removeValue(forKey: model.id)
    }
}