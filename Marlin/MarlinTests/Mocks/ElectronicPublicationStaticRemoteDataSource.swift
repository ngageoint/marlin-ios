//
//  ElectronicPublicationStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation
import BackgroundTasks
import Combine

@testable import Marlin

class ElectronicPublicationStaticRemoteDataSource: ElectronicPublicationRemoteDataSource {
    var list: [ElectronicPublicationModel] = []

    override func fetch(task: BGTask? = nil) async -> [ElectronicPublicationModel] {
        return list
    }

    override func downloadFile(model: ElectronicPublicationModel, subject: PassthroughSubject<DownloadProgress, Never>) {
        let downloadManager = DownloadManager(subject: subject, downloadable: model)
        
        let config = URLSessionConfiguration.default
        downloadManager.sessionConfig = config
        downloads[model.id] = downloadManager
        downloadManager.download()
    }
}
