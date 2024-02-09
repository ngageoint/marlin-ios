//
//  LightRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/18/23.
//

import Foundation
import Combine

enum LightItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let light):
            return light.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ light: LightListModel)
    case sectionHeader(header: String)
}

class LightRepository: ObservableObject {
    var localDataSource: LightLocalDataSource
    private var remoteDataSource: LightRemoteDataSource
    init(localDataSource: LightLocalDataSource, remoteDataSource: LightRemoteDataSource) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    func createOperations() -> [LightDataFetchOperation] {
        return Light.lightVolumes.map { lightVolume in
            let newestLight = localDataSource.getNewestLight(volumeNumber: lightVolume.volumeNumber)
            let noticeWeek = Int(newestLight?.noticeWeek ?? "0") ?? 0
            return LightDataFetchOperation(
                volume: lightVolume.volumeQuery,
                noticeYear: newestLight?.noticeYear,
                noticeWeek: String(format: "%02d", noticeWeek + 1)
            )
        }
    }

    func getCharacteristic(
        featureNumber: String?,
        volumeNumber: String?,
        characteristicNumber: Int64
    ) -> LightModel? {
        localDataSource.getCharacteristic(
            featureNumber: featureNumber,
            volumeNumber: volumeNumber,
            characteristicNumber: characteristicNumber
        )
    }

    func getLight(
        featureNumber: String?,
        volumeNumber: String?
    ) -> [LightModel]? {
        localDataSource.getLight(
            featureNumber: featureNumber,
            volumeNumber: volumeNumber
        )
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }
    func lights(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[LightItem], Error> {
        localDataSource.lights(filters: filters, paginatedBy: paginator)
    }

    func getLights(
        filters: [DataSourceFilterParameter]?
    ) async -> [LightModel] {
        await localDataSource.getLights(filters: filters)
    }

    func fetchLights() async -> [LightModel] {
        NSLog("Fetching Lights")
        DispatchQueue.main.async {
            MSI.shared.appState.loadingDataSource[DataSources.light.key] = true
            NotificationCenter.default.post(
                name: .DataSourceLoading,
                object: DataSourceItem(dataSource: DataSources.light)
            )
        }

        var insertedLights: [LightModel] = []

        for lightVolume in Light.lightVolumes {

            let newestLight = localDataSource.getNewestLight(volumeNumber: lightVolume.volumeNumber)
            let noticeWeek = Int(newestLight?.noticeWeek ?? "0") ?? 0

            var lights = await remoteDataSource.fetch(
                volume: lightVolume.volumeQuery,
                noticeYear: newestLight?.noticeYear,
                noticeWeek: String(format: "%02d", noticeWeek + 1)
            )
            // if there were already lights in the db for this volume and this was an update
            // and we got back a light we have to go redo the query due to regions not being
            // populated on all returned objects
            if lights.count != 0 && localDataSource.volumeCount(volumeNumber: lightVolume.volumeNumber) != 0 {
                lights = await remoteDataSource.fetch(
                    volume: lightVolume.volumeQuery
                )
            }
            await localDataSource.insert(task: nil, lights: lights)
            insertedLights.append(contentsOf: lights)
        }

        DispatchQueue.main.async {
            MSI.shared.appState.loadingDataSource[DataSources.light.key] = false
            UserDefaults.standard.updateLastSyncTimeSeconds(DataSources.light)
            NotificationCenter.default.post(
                name: .DataSourceLoaded,
                object: DataSourceItem(dataSource: DataSources.light)
            )
        }
        if insertedLights.count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceNeedsProcessed,
                    object: DataSourceUpdatedNotification(key: DataSources.asam.key)
                )
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.asam.key)
                )
            }
        }

        return insertedLights
    }

}

// protocol LightRepository {
//    @discardableResult
//    func getLights(featureNumber: String?, volumeNumber: String?, waypointURI: URL?) -> [LightModel]
//    func getCount(filters: [DataSourceFilterParameter]?) -> Int
// }
//
// class LightRepositoryManager: LightRepository, ObservableObject {
//    private var repository: LightRepository
//    init(repository: LightRepository) {
//        self.repository = repository
//    }
//    func getLights(featureNumber: String?, volumeNumber: String?, waypointURI: URL?) -> [LightModel] {
//        repository.getLights(featureNumber: featureNumber, volumeNumber: volumeNumber, waypointURI: waypointURI)
//    }
//    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
//        repository.getCount(filters: filters)
//    }
// }
//
// class LightCoreDataRepository: LightRepository, ObservableObject {
//    private var context: NSManagedObjectContext
//    
//    required init(context: NSManagedObjectContext) {
//        self.context = context
//    }
//    
//    func getLights(featureNumber: String?, volumeNumber: String?, waypointURI: URL?) -> [LightModel] {
//        if let waypointURI = waypointURI {
//            if let id = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: waypointURI),
//               let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
//                let dataSource = waypoint.decodeToDataSource()
//                if let dataSource = dataSource as? LightModel {
//                    return [dataSource]
//                }
//            }
//        }
//        if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
//            if let lights = try? context.fetchObjects(
//                Light.self,
//                predicate: NSPredicate(
//                    format: "featureNumber = %@ AND volumeNumber = %@",
//                    argumentArray: [featureNumber, volumeNumber]
//                )
//            ) {
//                var models: [LightModel] = []
//                for light in lights {
//                    models.append(LightModel(light: light))
//                }
//                return models
//            }
//        }
//        return []
//    }
//    
//    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
//        guard let fetchRequest = LightFilterable().fetchRequest(filters: filters, commonFilters: nil) else {
//            return 0
//        }
//        return (try? context.count(for: fetchRequest)) ?? 0
//    }
// }
