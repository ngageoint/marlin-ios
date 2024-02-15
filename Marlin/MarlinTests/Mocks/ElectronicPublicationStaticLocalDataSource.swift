//
//  ElectronicPublicationStaticLocalDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation

import Combine
import BackgroundTasks

@testable import Marlin

class ElectronicPublicationStaticLocalDataSource: ElectronicPublicationLocalDataSource {
    var list: [ElectronicPublicationModel] = []

    func getElectronicPublication(s3Key: String?) -> Marlin.ElectronicPublicationModel? {
        list.first { model in
            model.s3Key == s3Key
        }
    }
    
    func getCount(filters: [Marlin.DataSourceFilterParameter]?) -> Int {
        list.count
    }
    
    func epubs(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.ElectronicPublicationItem], Error> {
        AnyPublisher(Just(list.map({ model in
            ElectronicPublicationItem.listItem(ElectronicPublicationListModel(epubModel: model))
        })).setFailureType(to: Error.self))
    }
    
    func sectionHeaders(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.ElectronicPublicationItem], Error> {
        AnyPublisher(Just(list.map({ model in
            ElectronicPublicationItem.sectionHeader(header: PublicationTypeEnum(rawValue: model.pubTypeId ?? -1)?.description ?? "")
        })).setFailureType(to: Error.self))
    }
    
    func insert(task: BGTask?, epubs: [Marlin.ElectronicPublicationModel]) async -> Int {
        list.append(contentsOf: epubs)
        return epubs.count
    }
    
    func batchImport(from propertiesList: [Marlin.ElectronicPublicationModel]) async throws -> Int {
        list.append(contentsOf: propertiesList)
        return propertiesList.count
    }

}
