//
//  ElectronicPublicationRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks
import Combine

class ElectronicPublicationRemoteDataSource: RemoteDataSource<ElectronicPublicationModel> {
    var downloads: [String: DownloadManager] = [:]
    init(cleanup: (() -> Void)? = nil) {
        super.init(dataSource: DataSources.epub, cleanup: cleanup)
    }

    func fetch(
        task: BGTask? = nil
    ) async -> [ElectronicPublicationModel] {
        let operation = ElectronicPublicationDataFetchOperation()
        return await fetch(task: task, operation: operation)
    }

    func downloadFile(model: ElectronicPublicationModel, subject: PassthroughSubject<DownloadProgress, Never>) {
        let downloadManager = DownloadManager(subject: subject, downloadable: model)
        downloads[model.id] = downloadManager
        downloadManager.download()
    }

    func cancelDownload(model: ElectronicPublicationModel) {
        downloads[model.id]?.cancel()
    }

    func cleanupDownload(model: ElectronicPublicationModel) {
        downloads.removeValue(forKey: model.id)
    }
}
