//
//  DifferentialGPSStationRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/25/23.
//

import Foundation
import Combine

enum DifferentialGPSStationItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let dgps):
            return dgps.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ dgps: DifferentialGPSStationModel)
    case sectionHeader(header: String)
}

class DifferentialGPSStationRepository: ObservableObject {
    var localDataSource: DifferentialGPSStationLocalDataSource
    private var remoteDataSource: DifferentialGPSStationRemoteDataSource
    init(
        localDataSource: DifferentialGPSStationLocalDataSource,
        remoteDataSource: DifferentialGPSStationRemoteDataSource
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    func createOperation() -> DifferentialGPSStationDataFetchOperation {
        let newestRadioBeacon = localDataSource.getNewestDifferentialGPSStation()
        let noticeWeek = Int(newestRadioBeacon?.noticeWeek ?? "0") ?? 0
        return DifferentialGPSStationDataFetchOperation(
            noticeYear: newestRadioBeacon?.noticeYear,
            noticeWeek: String(format: "%02d", noticeWeek + 1)
        )
    }

    func getDifferentialGPSStation(
        featureNumber: Int?,
        volumeNumber: String?
    ) -> DifferentialGPSStationModel? {
        localDataSource.getDifferentialGPSStation(
            featureNumber: featureNumber,
            volumeNumber: volumeNumber
        )
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }

    func dgps(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[DifferentialGPSStationItem], Error> {
        localDataSource.dgps(filters: filters, paginatedBy: paginator)
    }

    func getDifferentialGPSStations(
        filters: [DataSourceFilterParameter]?
    ) async -> [DifferentialGPSStationModel] {
        await localDataSource.getDifferentialGPSStations(filters: filters)
    }

    func fetch() async -> [DifferentialGPSStationModel] {
        NSLog("Fetching DGPS")
        DispatchQueue.main.async {
            MSI.shared.appState.loadingDataSource[DataSources.dgps.key] = true
            NotificationCenter.default.post(
                name: .DataSourceLoading,
                object: DataSourceItem(dataSource: DataSources.dgps)
            )
        }

        let newest = localDataSource.getNewestDifferentialGPSStation()

        let noticeWeek = newest?.noticeWeek
        let noticeYear = newest?.noticeYear

        let dgpss = await remoteDataSource.fetch(noticeYear: noticeYear, noticeWeek: noticeWeek)
        let inserted = await localDataSource.insert(task: nil, dgpss: dgpss)

        DispatchQueue.main.async {
            MSI.shared.appState.loadingDataSource[DataSources.dgps.key] = false
            UserDefaults.standard.updateLastSyncTimeSeconds(DataSources.dgps)
            NotificationCenter.default.post(
                name: .DataSourceLoaded,
                object: DataSourceItem(dataSource: DataSources.dgps)
            )
            if inserted != 0 {
                NotificationCenter.default.post(
                    name: .DataSourceNeedsProcessed,
                    object: DataSourceUpdatedNotification(key: DataSources.dgps.key)
                )
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.dgps.key)
                )
            }
        }

        return dgpss
    }
}
