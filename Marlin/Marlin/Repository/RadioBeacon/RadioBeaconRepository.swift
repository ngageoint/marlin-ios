//
//  RadioBeaconRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/27/23.
//

import Foundation
import Combine

enum RadioBeaconItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let radioBeacon):
            return radioBeacon.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ radioBeacon: RadioBeaconListModel)
    case sectionHeader(header: String)
}

class RadioBeaconRepository: ObservableObject {
    let localDataSource: RadioBeaconLocalDataSource
    private let remoteDataSource: RadioBeaconRemoteDataSource
    init(localDataSource: RadioBeaconLocalDataSource, remoteDataSource: RadioBeaconRemoteDataSource) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    func createOperation() -> RadioBeaconDataFetchOperation {
        let newestRadioBeacon = localDataSource.getNewestRadioBeacon()
        let noticeWeek = Int(newestRadioBeacon?.noticeWeek ?? "0") ?? 0
        return RadioBeaconDataFetchOperation(
            noticeYear: newestRadioBeacon?.noticeYear,
            noticeWeek: String(format: "%02d", noticeWeek + 1)
        )
    }

    func getRadioBeacon(featureNumber: Int?, volumeNumber: String?) -> RadioBeaconModel? {
        localDataSource.getRadioBeacon(featureNumber: featureNumber, volumeNumber: volumeNumber)
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }

    func getRadioBeacons(
        filters: [DataSourceFilterParameter]?
    ) async -> [RadioBeaconModel] {
        await localDataSource.getRadioBeacons(filters: filters)
    }

    func radioBeacons(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[RadioBeaconItem], Error> {
        localDataSource.radioBeacons(filters: filters, paginatedBy: paginator)
    }

    func fetchRadioBeacons() async -> [RadioBeaconModel] {
        NSLog("Fetching Radio Beacons")
        DispatchQueue.main.async {
            MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] = true
            NotificationCenter.default.post(
                name: .DataSourceLoading,
                object: DataSourceItem(dataSource: DataSources.radioBeacon)
            )
        }

        let newestRadioBeacon = localDataSource.getNewestRadioBeacon()
        let noticeWeek = Int(newestRadioBeacon?.noticeWeek ?? "0") ?? 0

        let radioBeacons = await remoteDataSource.fetch(
            noticeYear: newestRadioBeacon?.noticeYear,
            noticeWeek: String(format: "%02d", noticeWeek + 1)
        )
        let inserted = await localDataSource.insert(task: nil, radioBeacons: radioBeacons)

        DispatchQueue.main.async {
            MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] = false
            UserDefaults.standard.updateLastSyncTimeSeconds(DataSources.radioBeacon)
            NotificationCenter.default.post(
                name: .DataSourceLoaded,
                object: DataSourceItem(dataSource: DataSources.radioBeacon)
            )
            if inserted != 0 {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.radioBeacon.key)
                )
            }
        }

        return radioBeacons
    }
}
