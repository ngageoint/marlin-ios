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

class PublicationStaticRemoteDataSource: PublicationRemoteDataSource {
    var list: [PublicationModel] = []

    override func fetch(task: BGTask? = nil) async -> [PublicationModel] {
        return list
    }

    override func downloadFile(model: PublicationModel, subject: PassthroughSubject<DownloadProgress, Never>) {
        let downloadManager = DownloadManager(subject: subject, downloadable: model)
        
        let config = URLSessionConfiguration.default
        downloadManager.sessionConfig = config
        downloads[model.id] = downloadManager
        downloadManager.download()
    }
}
