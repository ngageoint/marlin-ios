//
//  LightCoreDataDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/24.
//

import Foundation
import CoreData
import Combine
import UIKit
import BackgroundTasks
import Kingfisher

class LightCoreDataDataSource:
    CoreDataDataSource,
    LightLocalDataSource,
    ObservableObject {
    typealias DataType = Light
    typealias ModelType = LightModel
    typealias Item = LightItem
    typealias ListModelType = LightListModel

    private lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()

    func getCharacteristic(
        featureNumber: String?,
        volumeNumber: String?,
        characteristicNumber: Int64
    ) -> ModelType? {
        var model: ModelType?
        if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
            model = context.performAndWait {
                if let light = try? context.fetchFirst(
                    DataType.self,
                    predicate: NSPredicate(
                        format: "featureNumber = %@ AND volumeNumber = %@ AND characteristicNumber = %d",
                        argumentArray: [featureNumber, volumeNumber, characteristicNumber])) {
                    return ModelType(light: light)
                }
                return nil
            }
        }
        return model
    }

    func getLight(
        featureNumber: String?,
        volumeNumber: String?
    ) -> [ModelType]? {
        var models: [ModelType] = []
        if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
            models = context.performAndWait {
                if let lights = try? context.fetchObjects(
                    DataType.self,
                    sortBy: [NSSortDescriptor(key: "characteristicNumber", ascending: false)],
                    predicate: NSPredicate(
                        format: "featureNumber = %@ AND volumeNumber = %@",
                        argumentArray: [featureNumber, volumeNumber])) {
                    return lights.map { light in
                        ModelType(light: light)
                    }
                }
                return []
            }
        }
        return models
    }

    func getNewestLight(volumeNumber: String) -> ModelType? {
        return context.performAndWait {
            return try? context.fetchFirst(
                Light.self,
                sortBy: [NSSortDescriptor(keyPath: \Light.noticeNumber, ascending: false)],
                predicate: NSPredicate(format: "volumeNumber = %@", volumeNumber))
            .map({ light in
                LightModel(light: light)
            })
        }
    }

    func getLightsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) async -> [ModelType] {
        let context = PersistenceController.current.newTaskContext()
        return await context.perform {
            let fetchRequest = DataType.fetchRequest()
            var predicates: [NSPredicate] = self.buildPredicates(filters: filters)

            if let minLatitude = minLatitude,
               let maxLatitude = maxLatitude,
               let minLongitude = minLongitude,
               let maxLongitude = maxLongitude {
                predicates.append(
                    self.boundsPredicate(
                        minLatitude: minLatitude,
                        maxLatitude: maxLatitude,
                        minLongitude: minLongitude,
                        maxLongitude: maxLongitude
                    )
                )
            }

            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.predicate = predicate

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.light.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            return (context.fetch(request: fetchRequest)?.map { model in
                ModelType(light: model)
            }) ?? []
        }
    }

    func boundsPredicate(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> NSPredicate {
        return NSPredicate(
            format: """
                    characteristicNumber = 1 AND \
                    latitude >= %lf AND \
                    latitude <= %lf AND \
                    longitude >= %lf AND \
                    longitude <= %lf
                    """,
            minLatitude, maxLatitude, minLongitude, maxLongitude
        )
    }

    func volumeCount(volumeNumber: String) -> Int {
        let fetchRequest = DataType.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "volumeNumber = %@", volumeNumber)

        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Light.noticeNumber, ascending: false)]

        return context.performAndWait {
            return (try? context.count(for: fetchRequest)) ?? 0
        }
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        let fetchRequest = DataType.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.light.key).map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })

        var count = 0
        context.performAndWait {
            count = (try? context.count(for: fetchRequest)) ?? 0
        }
        return count
    }

    func getLights(
        filters: [DataSourceFilterParameter]?
    ) async -> [LightModel] {
        return await context.perform {
            let fetchRequest = Light.fetchRequest()
            let predicates: [NSPredicate] = self.buildPredicates(filters: filters)

            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.predicate = predicate

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.light.key).toNSSortDescriptors()
            return (self.context.fetch(request: fetchRequest)?.map { light in
                LightModel(light: light)
            }) ?? []
        }
    }

}

// MARK: Data Publisher methods
extension LightCoreDataDataSource {

    struct ModelPage {
        var list: [Item]
        var next: Int?
        var currentHeader: String?
    }

    func lights(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[Item], Error> {
        return models(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.list)
            .eraseToAnyPublisher()
    }

    func models(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?
    ) -> AnyPublisher<ModelPage, Error> {

        let request = DataType.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.predicate = predicate

        request.fetchLimit = 100
        request.fetchOffset = (page ?? 0) * request.fetchLimit
        let userSort = UserDefaults.standard.sort(DataSources.light.key)
        let sortDescriptors: [DataSourceSortParameter] =
        userSort.isEmpty ? DataSources.light.defaultSort : userSort

        request.sortDescriptors = sortDescriptors.map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        var previousHeader: String? = currentHeader
        var list: [Item] = []
        context.performAndWait {
            if let fetched = context.fetch(request: request) {

                list = fetched.flatMap { item in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [Item.listItem(ListModelType(light: item))]
                    }

                    if !sortDescriptor.section {
                        return [Item.listItem(ListModelType(light: item))]
                    }

                    return createSectionHeaderAndListItem(
                        item: item,
                        sortDescriptor: sortDescriptor,
                        previousHeader: &previousHeader
                    )
                }
            }
        }

        let modelPage: ModelPage = ModelPage(
            list: list,
            next: (page ?? 0) + 1,
            currentHeader: previousHeader
        )

        return Just(modelPage)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func createSectionHeaderAndListItem(
        item: DataType,
        sortDescriptor: DataSourceSortParameter,
        previousHeader: inout String?
    ) -> [Item] {
        let currentValue = item.value(forKey: sortDescriptor.property.key)
        let sortValueString: String? = getCurrentSortValue(sortDescriptor: sortDescriptor, sortValue: currentValue)

        if let previous = previousHeader, let sortValueString = sortValueString {
            if previous != sortValueString {
                previousHeader = sortValueString
                return [
                    Item.sectionHeader(header: sortValueString),
                    Item.listItem(ListModelType(light: item))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                Item.sectionHeader(header: sortValueString),
                Item.listItem(ListModelType(light: item))
            ]
        }

        return [Item.listItem(ListModelType(light: item))]
    }

    func getCurrentSortValue(sortDescriptor: DataSourceSortParameter, sortValue: Any?) -> String? {
        var sortValueString: String?
        switch sortDescriptor.property.type {
        case .string:
            sortValueString = sortValue as? String
        case .date:
            if let currentValue = sortValue as? Date {
                sortValueString = DataSources.light.dateFormatter.string(from: currentValue)
            }
        case .int:
            sortValueString = (sortValue as? Int)?.zeroIsEmptyString
        case .float:
            sortValueString = (sortValue as? Float)?.zeroIsEmptyString
        case .double:
            sortValueString = (sortValue as? Double)?.zeroIsEmptyString
        case .boolean:
            sortValueString = ((sortValue as? Bool) ?? false) ? "True" : "False"
        case .enumeration:
            sortValueString = sortValue as? String
        case .latitude:
            sortValueString = (sortValue as? Double)?.latitudeDisplay
        case .longitude:
            sortValueString = (sortValue as? Double)?.longitudeDisplay
        default:
            return nil
        }
        return sortValueString
    }

    func models(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<ModelPage, Error> {
        return models(filters: filters, at: page, currentHeader: currentHeader)
            .map { result -> AnyPublisher<ModelPage, Error> in
                if let paginator = paginator, let next = result.next {
                    return self.models(
                        filters: filters,
                        at: next,
                        currentHeader: result.currentHeader,
                        paginatedBy: paginator
                    )
                    .wait(untilOutputFrom: paginator)
                    .retry(.max)
                    .prepend(result)
                    .eraseToAnyPublisher()
                } else {
                    return Just(result)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
