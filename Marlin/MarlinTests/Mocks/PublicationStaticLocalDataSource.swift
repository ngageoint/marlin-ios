//
//  PublicationStaticLocalDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation

import Combine
import BackgroundTasks

@testable import Marlin

class PublicationStaticLocalDataSource: PublicationLocalDataSource {
    
    var existsMap: [String: Bool] = [:]
    func checkFileExists(s3Key: String) -> Bool {
        guard let epub = map[s3Key] else {
            return false
        }
        var downloaded = false
        if let destinationUrl = URL(string: epub.savePath) {
            downloaded = FileManager().fileExists(atPath: destinationUrl.path)
        }
        if downloaded != epub.isDownloaded {
            var model = map[s3Key] ?? PublicationModel()
            model.isDownloaded = true
            existsMap[s3Key] = true

            map[s3Key] = model
            if let subject = subjectMap[s3Key] {
                subject.send(model)
            }
        }
        return existsMap[s3Key] ?? false
    }
    

    func deleteFile(s3Key: String) {
        guard let epub = map[s3Key] else {
            return
        }
        existsMap[s3Key] = false
        
        if let destinationUrl = URL(string: epub.savePath) {
            try? FileManager().removeItem(atPath: destinationUrl.path)
        }
        var model = map[s3Key] ?? PublicationModel()
        model.isDownloaded = false
        if let subject = subjectMap[s3Key] {
            subject.send(model)
        }
        map[s3Key] = model
    }
    
    func updateProgress(s3Key: String, progress: Marlin.DownloadProgress) {
        print("update progress \(s3Key) \(progress)")
        var model = map[s3Key] ?? PublicationModel()
        model.isDownloaded = progress.isDownloaded
        model.isDownloading = progress.isDownloading
        model.downloadProgress = progress.downloadProgress
        model.error = progress.error
        if progress.downloadProgress == 1.0 {
            existsMap[s3Key] = true
        }
        if let subject = subjectMap[s3Key] {
            subject.send(model)
        }
        map[s3Key] = model
    }
    
    var map: [String: PublicationModel] = [:]
    var subjectMap: [String : PassthroughSubject<PublicationModel, Never>] = [:]

    func observePublication(s3Key: String) -> AnyPublisher<PublicationModel, Never>? {
        let subject = PassthroughSubject<PublicationModel, Never>()
        subjectMap[s3Key] = subject
        if let model = map[s3Key] {
            return AnyPublisher(subject)
        }
        return nil
    }

    func getSections(filters: [Marlin.DataSourceFilterParameter]?) async -> [Marlin.PublicationItem]? {
        let grouped = Dictionary(grouping: Array(map.values), by: { PublicationTypeEnum(rawValue:$0.pubTypeId ?? -1) })
        var sections: [PublicationItem] = []
        for (pubType, models) in grouped {
            if let pubType = pubType {
                sections.append(PublicationItem.pubType(type: pubType, count: models.count))
            }
        }
        return sections
    }

    func getPublications(typeId: Int) async -> [Marlin.PublicationModel] {
        Array(map.values)
    }

    func getPublication(s3Key: String?) -> Marlin.PublicationModel? {
        map[s3Key ?? ""]
    }
    
    func getCount(filters: [Marlin.DataSourceFilterParameter]?) -> Int {
        map.values.count
    }
    
    func pubs(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.PublicationItem], Error> {
        AnyPublisher(Just(map.values.map({ model in
            PublicationItem.listItem(PublicationListModel(epubModel: model))
        })).setFailureType(to: Error.self))
    }
    
    func sectionHeaders(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.PublicationItem], Error> {
        AnyPublisher(Just(map.values.map({ model in
            PublicationItem.sectionHeader(header: PublicationTypeEnum(rawValue: model.pubTypeId ?? -1)?.description ?? "")
        })).setFailureType(to: Error.self))
    }
    
    func insert(task: BGTask?, epubs: [Marlin.PublicationModel]) async -> Int {
        for epub in epubs {
            map[epub.s3Key ?? ""] = epub
        }
        return epubs.count
    }
    
    func batchImport(from propertiesList: [Marlin.PublicationModel]) async throws -> Int {
        for epub in propertiesList {
            map[epub.s3Key ?? ""] = epub
        }
        return propertiesList.count
    }

}
