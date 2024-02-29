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
    func getNoticesToMariners(noticeNumber: Int?) -> [Marlin.NoticeToMarinersModel]? {
        map.values.filter { model in
            model.noticeNumber == noticeNumber
        }
    }
    
    func sectionHeaders(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.NoticeToMarinersItem], Error> {
        AnyPublisher(Just(map.values.map({ model in
            NoticeToMarinersItem.listItem(NoticeToMarinersListModel(noticeToMarinersModel:model))
        })).setFailureType(to: Error.self))
    }
    
    var existsMap: [Int: Bool] = [:]
    var map: [Int: NoticeToMarinersModel] = [:]
    var subjectMap: [Int : PassthroughSubject<NoticeToMarinersModel, Never>] = [:]

    func observeNoticeToMariners(odsEntryId: Int) -> AnyPublisher<Marlin.NoticeToMarinersModel, Never>? {
        let subject = PassthroughSubject<NoticeToMarinersModel, Never>()
        subjectMap[odsEntryId] = subject
        if let model = map[odsEntryId] {
            return AnyPublisher(subject)
        }
        return nil
    }
    
    func checkFileExists(odsEntryId: Int) -> Bool {
        guard let epub = map[odsEntryId] else {
            return false
        }
        var downloaded = false
        if let destinationUrl = URL(string: epub.savePath) {
            downloaded = FileManager().fileExists(atPath: destinationUrl.path)
        }
        if downloaded != epub.isDownloaded {
            var model = map[odsEntryId] ?? NoticeToMarinersModel()
            model.isDownloaded = true
            existsMap[odsEntryId] = true

            map[odsEntryId] = model
            if let subject = subjectMap[odsEntryId] {
                subject.send(model)
            }
        }
        return existsMap[odsEntryId] ?? false
    }
    
    func deleteFile(odsEntryId: Int) {
        guard let epub = map[odsEntryId] else {
            return
        }
        existsMap[odsEntryId] = false

        if let destinationUrl = URL(string: epub.savePath) {
            try? FileManager().removeItem(atPath: destinationUrl.path)
        }
        var model = map[odsEntryId] ?? NoticeToMarinersModel()
        model.isDownloaded = false
        if let subject = subjectMap[odsEntryId] {
            subject.send(model)
        }
        map[odsEntryId] = model
    }
    
    func updateProgress(odsEntryId: Int, progress: Marlin.DownloadProgress) {
        print("update progress \(odsEntryId) \(progress)")
        var model = map[odsEntryId] ?? NoticeToMarinersModel()
        model.isDownloaded = progress.isDownloaded
        model.isDownloading = progress.isDownloading
        model.downloadProgress = progress.downloadProgress
        model.error = progress.error
        if progress.downloadProgress == 1.0 {
            existsMap[odsEntryId] = true
        }
        if let subject = subjectMap[odsEntryId] {
            subject.send(model)
        }
        map[odsEntryId] = model
    }
    
    func getNoticeToMariners(odsEntryId: Int?) -> Marlin.NoticeToMarinersModel? {
        map[odsEntryId ?? -1]
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
            if let odsEntryId = notice.odsEntryId {
                map[odsEntryId] = notice
            }
        }
        return noticeToMariners.count
    }
    
    func batchImport(from propertiesList: [Marlin.NoticeToMarinersModel]) async throws -> Int {
        for notice in propertiesList {
            if let odsEntryId = notice.odsEntryId {
                map[odsEntryId] = notice
            }
        }
        return propertiesList.count
    }
}
