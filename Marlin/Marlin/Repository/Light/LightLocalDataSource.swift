//
//  LightLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import Combine
import BackgroundTasks

private struct LightLocalDataSourceProviderKey: InjectionKey {
    static var currentValue: LightLocalDataSource = LightCoreDataDataSource()
}

extension InjectedValues {
    var lightLocalDataSource: LightLocalDataSource {
        get { Self[LightLocalDataSourceProviderKey.self] }
        set { Self[LightLocalDataSourceProviderKey.self] = newValue }
    }
}

protocol LightLocalDataSource: Sendable {

    func getCharacteristic(
        featureNumber: String?,
        volumeNumber: String?,
        characteristicNumber: Int64
    ) -> LightModel?

    func getLight(
        featureNumber: String?,
        volumeNumber: String?
    ) -> [LightModel]?

    func getNewestLight(
        volumeNumber: String
    ) -> LightModel?

    func getLightsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) async -> [LightModel]

    func lights(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[LightItem], Error>

    func getLights(
        filters: [DataSourceFilterParameter]?
    ) async -> [LightModel]
    
    func volumeCount(volumeNumber: String) -> Int
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    @discardableResult
    func insert(task: BGTask?, lights: [LightModel]) async -> Int
    func batchImport(from propertiesList: [LightModel]) async throws -> Int
    func postProcess() async
}
