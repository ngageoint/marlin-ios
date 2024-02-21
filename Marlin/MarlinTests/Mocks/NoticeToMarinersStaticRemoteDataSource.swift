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

class NoticeToMarinersStaticRemoteDataSource: NoticeToMarinersRemoteDataSource {
    var list: [NoticeToMarinersModel] = []

    override func fetch(
        task: BGTask? = nil,
        noticeNumber: Int? = nil
    ) async -> [NoticeToMarinersModel] {
        return list
    }

    override func downloadFile(model: NoticeToMarinersModel, subject: PassthroughSubject<DownloadProgress, Never>) {
        let downloadManager = DownloadManager(subject: subject, downloadable: model)

        let config = URLSessionConfiguration.default
        downloadManager.sessionConfig = config
        downloads[model.id] = downloadManager
        downloadManager.download()
    }
}
