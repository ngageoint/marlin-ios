//
//  DGPSStationRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/25/23.
//

import Foundation
import Combine

enum DGPSStationItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let dgps):
            return dgps.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ dgps: DGPSStationModel)
    case sectionHeader(header: String)
}

private struct DGPSStationRepositoryProviderKey: InjectionKey {
    static var currentValue: DGPSStationRepository = DGPSStationRepository()
}

extension InjectedValues {
    var dgpsRepository: DGPSStationRepository {
        get { Self[DGPSStationRepositoryProviderKey.self] }
        set { Self[DGPSStationRepositoryProviderKey.self] = newValue }
    }
}

actor DGPSStationRepository: ObservableObject {
    @Injected(\.dgpsLocalDataSource)
    var localDataSource: DGPSStationLocalDataSource
    @Injected(\.dgpsemoteDataSource)
    private var remoteDataSource: DGPSStationRemoteDataSource

    func createOperation() -> DGPSStationDataFetchOperation {
        let newestRadioBeacon = localDataSource.getNewestDifferentialGPSStation()
        let noticeWeek = Int(newestRadioBeacon?.noticeWeek ?? "0") ?? 0
        return DGPSStationDataFetchOperation(
            noticeYear: newestRadioBeacon?.noticeYear,
            noticeWeek: String(format: "%02d", noticeWeek + 1)
        )
    }

    func getDGPSStation(
        featureNumber: Int?,
        volumeNumber: String?
    ) -> DGPSStationModel? {
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
    ) -> AnyPublisher<[DGPSStationItem], Error> {
        localDataSource.dgps(filters: filters, paginatedBy: paginator)
    }

    func getDifferentialGPSStations(
        filters: [DataSourceFilterParameter]?
    ) async -> [DGPSStationModel] {
        await localDataSource.getDifferentialGPSStations(filters: filters)
    }

    func fetch() async -> [DGPSStationModel] {
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

        await MainActor.run {
            MSI.shared.appState.loadingDataSource[DataSources.dgps.key] = false
            UserDefaults.standard.updateLastSyncTimeSeconds(DataSources.dgps)
            NotificationCenter.default.post(
                name: .DataSourceLoaded,
                object: DataSourceItem(dataSource: DataSources.dgps)
            )
            if inserted != 0 {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.dgps.key, inserts: inserted)
                )
            }
        }

        return dgpss
    }
}
