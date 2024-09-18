//
//  UserPlaceLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/26/24.
//

import Foundation
import CoreData
import Combine

protocol UserPlaceLocalDataSource {
    @discardableResult
    func getUserPlace(uri: URL) async -> UserPlaceModel?
    func insert(userPlace: UserPlaceModel) async -> UserPlaceModel?
    func getUserPlacesInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) async -> [UserPlaceModel]
    func getCount(filters: [DataSourceFilterParameter]?) async -> Int
    func userPlaces(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[UserPlaceItem], Error>
}

class UserPlaceCoreDataDataSource:
    CoreDataDataSource,
    UserPlaceLocalDataSource {

    typealias DataType = UserPlace
    typealias ModelType = UserPlaceModel
    typealias Item = UserPlaceItem

    func getUserPlace(uri: URL) async -> UserPlaceModel? {
        let context = PersistenceController.current.newTaskContext()
        return await context.perform {
            if let id = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri),
               let userPlace = try? context.existingObject(with: id) as? UserPlace {
                return UserPlaceModel(userPlace: userPlace)
            }
            return nil
        }
    }

    func insert(userPlace: UserPlaceModel) async -> UserPlaceModel? {
        let context = PersistenceController.current.newTaskContext()
        return await context.perform {
            let managedObject = UserPlace(context: context)
            managedObject.populateFromModel(userPlaceModel: userPlace)
            try? context.obtainPermanentIDs(for: [managedObject])
            try? context.save()

            return UserPlaceModel(userPlace: managedObject)
        }
    }

    func getUserPlacesInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) async -> [UserPlaceModel] {
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

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.navWarning.key).toNSSortDescriptors()
            return (context.fetch(request: fetchRequest)?.map { model in
                UserPlaceModel(userPlace: model)
            }) ?? []
        }
    }

    func getCount(filters: [DataSourceFilterParameter]?) async -> Int {
        let fetchRequest = DataType.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.navWarning.key).toNSSortDescriptors()

        let context = PersistenceController.current.newTaskContext()
        return await context.perform {
            return (try? context.count(for: fetchRequest)) ?? 0
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
            (maxLatitude >= %lf AND minLatitude <= %lf AND maxLongitude >= %lf AND minLongitude <= %lf) \
            OR minLongitude < -180 OR maxLongitude > 180
            """, minLatitude, maxLatitude, minLongitude, maxLongitude
        )
    }
}

// MARK: Data Publisher methods
extension UserPlaceCoreDataDataSource {

    struct ModelPage {
        var list: [Item]
        var next: Int?
        var currentHeader: String?
    }

    func userPlaces(
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
        let userSort = UserDefaults.standard.sort(DataSources.userPlace.key)
        let sortDescriptors: [DataSourceSortParameter] =
        userSort.isEmpty ? DataSources.userPlace.defaultSort : userSort

        request.sortDescriptors = sortDescriptors.map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        var previousHeader: String? = currentHeader
        var list: [Item] = []
        let context = PersistenceController.current.viewContext
        context.performAndWait {
            if let fetched = context.fetch(request: request) {

                list = fetched.flatMap { item in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [Item.listItem(ModelType(userPlace: item))]
                    }

                    if !sortDescriptor.section {
                        return [Item.listItem(ModelType(userPlace: item))]
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
                    Item.listItem(ModelType(userPlace: item))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                Item.sectionHeader(header: sortValueString),
                Item.listItem(ModelType(userPlace: item))
            ]
        }

        return [Item.listItem(ModelType(userPlace: item))]
    }

    func getCurrentSortValue(sortDescriptor: DataSourceSortParameter, sortValue: Any?) -> String? {
        var sortValueString: String?
        switch sortDescriptor.property.type {
        case .string:
            sortValueString = sortValue as? String
        case .date:
            if let currentValue = sortValue as? Date {
                sortValueString = DataSources.userPlace.dateFormatter.string(from: currentValue)
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
