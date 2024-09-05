//
//  LightCoreDataDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/13/24.
//

import Foundation
import Combine
import CoreData

@testable import Marlin

final class LightCoreDataDataSourceTests: XCTestCase {

    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)

    override func setUp(completion: @escaping (Error?) -> Void) {
        Task.init {
            await TestHelpers.asyncGetKeyWindowVisible()
        }
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
        UserDefaults.standard.setSort(DataSources.light.key, sort: DataSources.light.filterable!.defaultSort)
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.light)
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)

        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
    }

    override func tearDown() {
    }

    func testCount() {
        var newItem: Light?
        persistentStore.viewContext.performAndWait {
            let light = Light(context: persistentStore.viewContext)

            light.characteristicNumber = 1
            light.volumeNumber = "PUB 110"
            light.featureNumber = "14840"
            light.noticeWeek = "06"
            light.noticeYear = "2015"
            light.latitude = 1.0
            light.longitude = 2.0
            light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light.range = nil
            light.sectionHeader = "Section"
            light.structure = "Yellow pedestal, red band; 7.\n"
            light.name = "-Outer."

            let light2 = Light(context: persistentStore.viewContext)

            light2.characteristicNumber = 1
            light2.volumeNumber = "PUB 111"
            light2.featureNumber = "14840"
            light2.noticeWeek = "06"
            light2.noticeYear = "2015"
            light2.latitude = 1.0
            light2.longitude = 2.0
            light2.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light2.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light2.range = nil
            light2.sectionHeader = "Section"
            light2.structure = "Yellow pedestal, red band; 7.\n"
            light2.name = "-Outer."

            newItem = light
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let dataSource = LightCoreDataDataSource()

        XCTAssertEqual(dataSource.getCount(filters: nil), 2)
        XCTAssertEqual(dataSource.volumeCount(volumeNumber: "PUB 110"), 1)
    }

    func testGetLight() {
        var newItem: Light?
        var newItem2: Light?
        persistentStore.viewContext.performAndWait {
            let light = Light(context: persistentStore.viewContext)
            light.characteristicNumber = 1
            light.volumeNumber = "PUB 110"
            light.featureNumber = "14840"
            light.noticeWeek = "06"
            light.noticeYear = "2015"
            light.latitude = 1.0
            light.longitude = 2.0
            light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light.range = nil
            light.sectionHeader = "Section"
            light.structure = "Yellow pedestal, red band; 7.\n"
            light.name = "-Outer."
            newItem = light

            let light2 = Light(context: persistentStore.viewContext)
            light2.characteristicNumber = 1
            light2.volumeNumber = "PUB 110"
            light2.featureNumber = "14841"
            light2.noticeWeek = "06"
            light2.noticeYear = "2015"
            light2.latitude = 1.0
            light2.longitude = 2.0
            light2.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light2.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light2.range = nil
            light2.sectionHeader = "Section"
            light2.structure = "Yellow pedestal, red band; 7.\n"
            light2.name = "-Outer."

            newItem2 = light2
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        guard let newItem2 = newItem2 else {
            XCTFail()
            return
        }

        let dataSource = LightCoreDataDataSource()

        let retrievedLights = dataSource.getLight(featureNumber: "14841", volumeNumber: "PUB 110")
        let retrieved = retrievedLights![0]
        XCTAssertEqual(retrieved.featureNumber, newItem2.featureNumber)
        XCTAssertEqual(retrieved.volumeNumber, newItem2.volumeNumber)

        let retrievedLights2 = dataSource.getLight(featureNumber: "14840", volumeNumber: "PUB 110")
        let retrieved2 = retrievedLights2![0]
        XCTAssertEqual(retrieved2.featureNumber, newItem.featureNumber)
        XCTAssertEqual(retrieved2.volumeNumber, newItem.volumeNumber)

        let no = dataSource.getLight(featureNumber:"no", volumeNumber:"PUB 110")
        XCTAssertEqual(no?.count, 0)
    }

    func testGetCharacteristic() {
        var newItem: Light?
        var newItem2: Light?
        persistentStore.viewContext.performAndWait {
            let light = Light(context: persistentStore.viewContext)
            light.characteristicNumber = 1
            light.volumeNumber = "PUB 110"
            light.featureNumber = "14840"
            light.noticeWeek = "06"
            light.noticeYear = "2015"
            light.latitude = 1.0
            light.longitude = 2.0
            light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light.range = nil
            light.sectionHeader = "Section"
            light.structure = "Yellow pedestal, red band; 7.\n"
            light.name = "-Outer."
            newItem = light

            let light2 = Light(context: persistentStore.viewContext)
            light2.characteristicNumber = 2
            light2.volumeNumber = "PUB 110"
            light2.featureNumber = "14840"
            light2.noticeWeek = "06"
            light2.noticeYear = "2015"
            light2.latitude = 1.0
            light2.longitude = 2.0
            light2.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light2.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light2.range = nil
            light2.sectionHeader = "Section"
            light2.structure = "Yellow pedestal, red band; 7.\n"
            light2.name = "-Outer."

            newItem2 = light2
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        guard let newItem2 = newItem2 else {
            XCTFail()
            return
        }

        let dataSource = LightCoreDataDataSource()

        let retrieved = dataSource.getCharacteristic(featureNumber: "14840", volumeNumber: "PUB 110", characteristicNumber: 1)
        XCTAssertEqual(retrieved?.featureNumber, newItem.featureNumber)
        XCTAssertEqual(retrieved?.volumeNumber, newItem.volumeNumber)
        XCTAssertEqual(retrieved?.characteristicNumber, 1)

        let retrieved2 = dataSource.getCharacteristic(featureNumber: "14840", volumeNumber: "PUB 110", characteristicNumber: 2)
        XCTAssertEqual(retrieved2?.featureNumber, newItem.featureNumber)
        XCTAssertEqual(retrieved2?.volumeNumber, newItem.volumeNumber)
        XCTAssertEqual(retrieved2?.characteristicNumber, 2)

        let no = dataSource.getCharacteristic(featureNumber: "14840", volumeNumber: "PUB 110", characteristicNumber: 3)
        XCTAssertNil(no)
    }

    func testGetNewestLight() {
        var newItem: Light?
        var newItem2: Light?
        persistentStore.viewContext.performAndWait {
            let light = Light(context: persistentStore.viewContext)
            light.characteristicNumber = 1
            light.volumeNumber = "PUB 110"
            light.featureNumber = "14840"
            light.noticeWeek = "05"
            light.noticeYear = "2015"
            light.noticeNumber = 201505
            light.latitude = 1.0
            light.longitude = 2.0
            light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light.range = nil
            light.sectionHeader = "Section"
            light.structure = "Yellow pedestal, red band; 7.\n"
            light.name = "-Outer."
            newItem = light

            let light2 = Light(context: persistentStore.viewContext)
            light2.characteristicNumber = 1
            light2.volumeNumber = "PUB 110"
            light2.featureNumber = "14841"
            light2.noticeWeek = "06"
            light2.noticeYear = "2015"
            light2.noticeNumber = 201506
            light2.latitude = 1.0
            light2.longitude = 2.0
            light2.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light2.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light2.range = nil
            light2.sectionHeader = "Section"
            light2.structure = "Yellow pedestal, red band; 7.\n"
            light2.name = "-Outer."

            newItem2 = light2
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        guard let newItem2 = newItem2 else {
            XCTFail()
            return
        }

        let dataSource = LightCoreDataDataSource()

        let retrieved = dataSource.getNewestLight(volumeNumber: "PUB 110")
        XCTAssertEqual(retrieved?.featureNumber, newItem2.featureNumber)
        XCTAssertEqual(retrieved?.volumeNumber, newItem2.volumeNumber)
    }

    func testGetLightsInBounds() async {
        var newItem: LightModel?
        var newItem2: LightModel?
        persistentStore.viewContext.performAndWait {
            let light = Light(context: persistentStore.viewContext)
            light.characteristicNumber = 1
            light.volumeNumber = "PUB 110"
            light.featureNumber = "14840"
            light.noticeWeek = "05"
            light.noticeYear = "2015"
            light.noticeNumber = 201505
            light.latitude = 20.0
            light.longitude = 20.0
            light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light.range = nil
            light.sectionHeader = "Section"
            light.structure = "Yellow pedestal, red band; 7.\n"
            light.name = "-Outer."
            newItem = LightModel(light: light)

            let light2 = Light(context: persistentStore.viewContext)
            light2.characteristicNumber = 1
            light2.volumeNumber = "PUB 110"
            light2.featureNumber = "14841"
            light2.noticeWeek = "06"
            light2.noticeYear = "2015"
            light2.noticeNumber = 201506
            light2.latitude = 1.0
            light2.longitude = 1.0
            light2.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light2.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light2.range = nil
            light2.sectionHeader = "Section"
            light2.structure = "Yellow pedestal, red band; 7.\n"
            light2.name = "-Outer."

            newItem2 = LightModel(light: light2)
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        guard let newItem2 = newItem2 else {
            XCTFail()
            return
        }

        let dataSource = LightCoreDataDataSource()

        let retrieved = await dataSource.getLightsInBounds(filters: nil, minLatitude: 19, maxLatitude: 21, minLongitude: 19, maxLongitude: 21)
        XCTAssertEqual(retrieved.count, 1)
        XCTAssertEqual(retrieved[0].featureNumber, newItem.featureNumber)
        let retrieved2 = await dataSource.getLightsInBounds(filters: nil, minLatitude: 0, maxLatitude: 2, minLongitude: 0, maxLongitude: 2)
        XCTAssertEqual(retrieved2.count, 1)
        XCTAssertEqual(retrieved2[0].featureNumber, newItem2.featureNumber)
        let retrieved3 = await dataSource.getLightsInBounds(filters: nil, minLatitude: 0, maxLatitude: 21, minLongitude: 0, maxLongitude: 21)
        XCTAssertEqual(retrieved3.count, 2)
    }

    func testPublisher() async {
        UserDefaults.standard.setSort(DataSources.light.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Feature Number",
                    key: #keyPath(Light.featureNumber),
                    type: .int),
                ascending: true,
                section: false)
        ])

        var newItem: Light?
        persistentStore.viewContext.performAndWait {
            let light = Light(context: persistentStore.viewContext)
            light.characteristicNumber = 1
            light.volumeNumber = "PUB 110"
            light.featureNumber = "14840"
            light.noticeWeek = "05"
            light.noticeYear = "2015"
            light.noticeNumber = 201505
            light.latitude = 20.0
            light.longitude = 20.0
            light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light.range = nil
            light.sectionHeader = "Section"
            light.structure = "Yellow pedestal, red band; 7.\n"
            light.name = "-Outer."
            newItem = light
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [LightItem])
            case failure(error: Error)

            fileprivate var rows: [LightItem] {
                if case let .loaded(rows: rows) = self {
                    return rows
                } else {
                    return []
                }
            }
        }
        enum TriggerId: Hashable {
            case reload
            case loadMore
        }
        var state: State = .loading

        let trigger = Trigger()
        let dataSource = LightCoreDataDataSource()

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.lights(
                filters: UserDefaults.standard.filter(DataSources.light),
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .scan([]) { $0 + $1 }
            .map { State.loaded(rows: $0) }
            .catch { error in
                XCTFail()
                return Just(State.failure(error: error))
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { recieve in
            switch(state, recieve) {
            case (.loaded, .loaded):
                state = recieve
            default:
                state = recieve
            }
        }
        .store(in: &disposables)

        let expecation1 = expectation(for: state.rows.count == 1)

        await fulfillment(of: [expecation1], timeout: 5)

        NSLog("Insert a new one")
        var newItem2: Light?
        persistentStore.viewContext.performAndWait {
            let light = Light(context: persistentStore.viewContext)
            light.characteristicNumber = 1
            light.volumeNumber = "PUB 110"
            light.featureNumber = "14841"
            light.noticeWeek = "05"
            light.noticeYear = "2015"
            light.noticeNumber = 201505
            light.latitude = 20.0
            light.longitude = 20.0
            light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light.range = nil
            light.sectionHeader = "Section"
            light.structure = "Yellow pedestal, red band; 7.\n"
            light.name = "-Outer."
            newItem2 = light
            try? persistentStore.viewContext.save()
        }
        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 2)

        await fulfillment(of: [expecation2], timeout: 5)
    }

    func testPublisherWithSectionHeader() async {
        UserDefaults.standard.setSort(DataSources.light.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Feature Number",
                    key: #keyPath(Light.featureNumber),
                    type: .string),
                ascending: true,
                section: true)
        ])

        var newItem: Light?
        persistentStore.viewContext.performAndWait {
            let light = Light(context: persistentStore.viewContext)
            light.characteristicNumber = 1
            light.volumeNumber = "PUB 110"
            light.featureNumber = "14840"
            light.noticeWeek = "05"
            light.noticeYear = "2015"
            light.noticeNumber = 201505
            light.latitude = 20.0
            light.longitude = 20.0
            light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light.range = nil
            light.sectionHeader = "Section"
            light.structure = "Yellow pedestal, red band; 7.\n"
            light.name = "-Outer."
            newItem = light
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [LightItem])
            case failure(error: Error)

            fileprivate var rows: [LightItem] {
                if case let .loaded(rows: rows) = self {
                    return rows
                } else {
                    return []
                }
            }
        }
        enum TriggerId: Hashable {
            case reload
            case loadMore
        }
        var state: State = .loading

        let trigger = Trigger()
        let dataSource = LightCoreDataDataSource()

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.lights(
                filters: UserDefaults.standard.filter(DataSources.light),
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .scan([]) { $0 + $1 }
            .map { State.loaded(rows: $0) }
            .catch { error in
                XCTFail()
                return Just(State.failure(error: error))
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { recieve in
            switch(state, recieve) {
            case (.loaded, .loaded):
                state = recieve
            default:
                state = recieve
            }
        }
        .store(in: &disposables)

        let expecation1 = expectation(for: state.rows.count == 2)

        await fulfillment(of: [expecation1], timeout: 5)

        let item = state.rows[0]
        switch item {
        case .listItem(_):
            XCTFail()
        case .sectionHeader(let header):
            XCTAssertEqual(header, "14840")
        }
        let item1 = state.rows[1]
        switch item1 {
        case .listItem(let light):
            XCTAssertEqual(light.featureNumber, "14840")
        case .sectionHeader(_):
            XCTFail()
        }

        NSLog("Insert a new one")
        var newItem2: Light?
        persistentStore.viewContext.performAndWait {
            let light = Light(context: persistentStore.viewContext)
            light.characteristicNumber = 1
            light.volumeNumber = "PUB 110"
            light.featureNumber = "14841"
            light.noticeWeek = "05"
            light.noticeYear = "2015"
            light.noticeNumber = 201505
            light.latitude = 20.0
            light.longitude = 20.0
            light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light.range = nil
            light.sectionHeader = "Section"
            light.structure = "Yellow pedestal, red band; 7.\n"
            light.name = "-Outer."
            newItem2 = light
            try? persistentStore.viewContext.save()
        }
        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 4)

        await fulfillment(of: [expecation2], timeout: 5)

        let itema = state.rows[0]
        switch itema {
        case .listItem(_):
            XCTFail()
        case .sectionHeader(let header):
            XCTAssertEqual(header, "14840")
        }
        let itema1 = state.rows[1]
        switch itema1 {
        case .listItem(let light):
            XCTAssertEqual(light.featureNumber, "14840")
        case .sectionHeader(_):
            XCTFail()
        }
        let itema2 = state.rows[2]
        switch itema2 {
        case .listItem(_):
            XCTFail()
        case .sectionHeader(let header):
            XCTAssertEqual(header, "14841")
        }
        let itema3 = state.rows[3]
        switch itema3 {
        case .listItem(let light):
            XCTAssertEqual(light.featureNumber, "14841")
        case .sectionHeader(_):
            XCTFail()
        }
    }

    func testInsert() async {
        var light = LightModel()
        light.characteristicNumber = 1
        light.volumeNumber = "PUB 110"
        light.featureNumber = "14841"
        light.noticeWeek = "05"
        light.noticeYear = "2015"
        light.noticeNumber = 201505
        light.latitude = 20.0
        light.longitude = 20.0
        light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
        light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
        light.range = "W. 14 ; R. 11 ; G. 11"
        light.sectionHeader = "Section"
        light.structure = "Yellow pedestal, red band; 7.\n"
        light.name = "-Outer."
        light.requiresPostProcessing = true

        let processed = expectation(forNotification: .DataSourceProcessed,
                                    object: nil) { notification in
            XCTAssertEqual((notification.object as? DataSourceUpdatedNotification)?.key, DataSources.light.key)
            return true
        }

        let dataSource = LightCoreDataDataSource()

        let inserted = await dataSource.insert(lights: [light])
        await fulfillment(of: [processed], timeout: 10)

        XCTAssertEqual(1, inserted)

        let retrieved = dataSource.getCharacteristic(featureNumber: light.featureNumber, volumeNumber: light.volumeNumber, characteristicNumber: 1)
        XCTAssertEqual(retrieved?.featureNumber, light.featureNumber)
        XCTAssertEqual(retrieved?.volumeNumber, light.volumeNumber)
        XCTAssertEqual(retrieved?.characteristicNumber, light.characteristicNumber)

        let lights = dataSource.getLight(featureNumber:light.featureNumber, volumeNumber: light.volumeNumber)!
        XCTAssertEqual(lights.count, 1)
        let light1 = lights[0]
        XCTAssertNotNil(light1)
        let ranges = light1.lightRange
        XCTAssertNotNil(ranges)
        XCTAssertEqual(ranges?.count, 3)
        let red = ranges?.first(where: { model in
            model.color == "R"
        })
        XCTAssertNotNil(red)
        XCTAssertEqual(red?.range, 11.0)
        let green = ranges?.first(where: { model in
            model.color == "G"
        })
        XCTAssertNotNil(green)
        XCTAssertEqual(green?.range, 11.0)
        let white = ranges?.first(where: { model in
            model.color == "W"
        })
        XCTAssertNotNil(white)
        XCTAssertEqual(white?.range, 14.0)
    }

    func testGetLights() async {
        var light = LightModel()
        light.characteristicNumber = 1
        light.volumeNumber = "PUB 110"
        light.featureNumber = "14841"
        light.noticeWeek = "05"
        light.noticeYear = "2015"
        light.noticeNumber = 201505
        light.latitude = 20.0
        light.longitude = 20.0
        light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
        light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
        light.range = nil
        light.sectionHeader = "Section"
        light.structure = "Yellow pedestal, red band; 7.\n"
        light.name = "-Outer."

        let dataSource = LightCoreDataDataSource()

        let inserted = await dataSource.insert(lights: [light])
        XCTAssertEqual(1, inserted)

        let retrieved = await dataSource.getLights(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "featureNumber", key: "featureNumber", type: .string), comparison: DataSourceFilterComparison.equals, valueString: light.featureNumber)])
        XCTAssertEqual(1, retrieved.count)
        XCTAssertEqual(retrieved[0].featureNumber, light.featureNumber)
        XCTAssertEqual(retrieved[0].volumeNumber, light.volumeNumber)

        let retrievedNone = await dataSource.getLights(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "featureNumber", key: "featureNumber", type: .string), comparison: DataSourceFilterComparison.equals, valueString: "no")])
        XCTAssertEqual(0, retrievedNone.count)


    }

}
