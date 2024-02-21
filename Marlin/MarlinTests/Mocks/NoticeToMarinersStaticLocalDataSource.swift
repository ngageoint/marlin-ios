//
//  NoticeToMarinersStaticLocalDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/16/24.
//

import Foundation
import Combine
import BackgroundTasks

@testable import Marlin

class NoticeToMarinersStaticLocalDataSource: NoticeToMarinersLocalDataSource {
    var existsMap: [Int: Bool] = [:]
    var map: [Int: NoticeToMarinersModel] = [:]
    var subjectMap: [Int : PassthroughSubject<NoticeToMarinersModel, Never>] = [:]

    func observeNoticeToMariners(noticeNumber: Int) -> AnyPublisher<Marlin.NoticeToMarinersModel, Never>? {
        let subject = PassthroughSubject<NoticeToMarinersModel, Never>()
        subjectMap[noticeNumber] = subject
        if let model = map[noticeNumber] {
            return AnyPublisher(subject)
        }
        return nil
    }
    
    func checkFileExists(noticeNumber: Int) -> Bool {
        guard let epub = map[noticeNumber] else {
            return false
        }
        var downloaded = false
        if let destinationUrl = URL(string: epub.savePath) {
            downloaded = FileManager().fileExists(atPath: destinationUrl.path)
        }
        if downloaded != epub.isDownloaded {
            var model = map[noticeNumber] ?? NoticeToMarinersModel()
            model.isDownloaded = true
            existsMap[noticeNumber] = true

            map[noticeNumber] = model
            if let subject = subjectMap[noticeNumber] {
                subject.send(model)
            }
        }
        return existsMap[noticeNumber] ?? false
    }
    
    func deleteFile(noticeNumber: Int) {
        guard let epub = map[noticeNumber] else {
            return
        }
        existsMap[noticeNumber] = false

        if let destinationUrl = URL(string: epub.savePath) {
            try? FileManager().removeItem(atPath: destinationUrl.path)
        }
        var model = map[noticeNumber] ?? NoticeToMarinersModel()
        model.isDownloaded = false
        if let subject = subjectMap[noticeNumber] {
            subject.send(model)
        }
        map[noticeNumber] = model
    }
    
    func updateProgress(noticeNumber: Int, progress: Marlin.DownloadProgress) {
        print("update progress \(noticeNumber) \(progress)")
        var model = map[noticeNumber] ?? NoticeToMarinersModel()
        model.isDownloaded = progress.isDownloaded
        model.isDownloading = progress.isDownloading
        model.downloadProgress = progress.downloadProgress
        model.error = progress.error
        if progress.downloadProgress == 1.0 {
            existsMap[noticeNumber] = true
        }
        if let subject = subjectMap[noticeNumber] {
            subject.send(model)
        }
        map[noticeNumber] = model
    }
    
    func getNoticeToMariners(noticeNumber: Int?) -> Marlin.NoticeToMarinersModel? {
        map[noticeNumber ?? -1]
    }
    
    func getNewestNoticeToMariners() -> Marlin.NoticeToMarinersModel? {
        map.first?.value
    }
    
    func getNoticesToMariners(filters: [Marlin.DataSourceFilterParameter]?) async -> [Marlin.NoticeToMarinersModel] {
        Array(map.values)
    }
    
    func noticeToMariners(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.NoticeToMarinersItem], Error> {
        AnyPublisher(Just(map.values.map({ model in
            NoticeToMarinersItem.listItem(NoticeToMarinersListModel(noticeToMarinersModel:model))
        })).setFailureType(to: Error.self))
    }
    
    func getCount(filters: [Marlin.DataSourceFilterParameter]?) -> Int {
        map.values.count
    }
    
    func insert(task: BGTask?, noticeToMariners: [Marlin.NoticeToMarinersModel]) async -> Int {
        for notice in noticeToMariners {
            if let noticeNumber = notice.noticeNumber {
                map[noticeNumber] = notice
            }
        }
        return noticeToMariners.count
    }
    
    func batchImport(from propertiesList: [Marlin.NoticeToMarinersModel]) async throws -> Int {
        for notice in propertiesList {
            if let noticeNumber = notice.noticeNumber {
                map[noticeNumber] = notice
            }
        }
        return propertiesList.count
    }
}
