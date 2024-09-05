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
            var noticeWeek: Int?
            if let lightWeek = newestLight?.noticeWeek {
                noticeWeek = Int(lightWeek)
            }
            return LightDataFetchOperation(
                volume: lightVolume.volumeQuery,
                noticeYear: newestLight?.noticeYear,
                noticeWeek: noticeWeek != nil ? String(format: "%02d", noticeWeek! + 1) : nil
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
        await MainActor.run {
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

        let inserted = insertedLights.count
        await MainActor.run { [inserted] in
            MSI.shared.appState.loadingDataSource[DataSources.light.key] = false
            UserDefaults.standard.updateLastSyncTimeSeconds(DataSources.light)
            NotificationCenter.default.post(
                name: .DataSourceLoaded,
                object: DataSourceItem(dataSource: DataSources.light)
            )
            if inserted != 0 {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.light.key, inserts: inserted)
                )
            }
        }

        return insertedLights
    }

}
