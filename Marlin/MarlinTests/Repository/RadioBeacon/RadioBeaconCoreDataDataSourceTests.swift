//
//  RadioBeaconCoreDataDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import XCTest
import Combine
import CoreData

@testable import Marlin

final class RadioBeaconCoreDataDataSourceTests: XCTestCase {

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
        UserDefaults.standard.setSort(DataSources.radioBeacon.key, sort: DataSources.radioBeacon.filterable!.defaultSort)
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.radioBeacon)
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
        var newItem: RadioBeacon?
        persistentStore.viewContext.performAndWait {
            let rb = RadioBeacon(context: persistentStore.viewContext)

            rb.volumeNumber = "PUB 110"
            rb.aidType = "Radiobeacons"
            rb.geopoliticalHeading = "GREENLAND"
            rb.regionHeading = nil
            rb.precedingNote = nil
            rb.featureNumber = 10
            rb.name = "Ittoqqortoormit, Scoresbysund"
            rb.position = "70°29'11.99\"N \n21°58'20\"W"
            rb.characteristic = "SC\n(• • •  - • - • ).\n"
            rb.range = 200
            rb.sequenceText = nil
            rb.frequency = "343\nNON, A2A."
            rb.stationRemark = "Aeromarine."
            rb.postNote = nil
            rb.noticeNumber = 199706
            rb.removeFromList = "N"
            rb.deleteFlag = "N"
            rb.noticeWeek = "06"
            rb.noticeYear = "1997"
            rb.latitude = 1.0
            rb.longitude = 2.0
            rb.sectionHeader = "section"

            newItem = rb
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let dataSource = RadioBeaconCoreDataDataSource()

        XCTAssertEqual(dataSource.getCount(filters: nil), 1)
    }

    func testGetRadioBeacon() {

        var newItem: RadioBeacon?
        var newItem2: RadioBeacon?

        persistentStore.viewContext.performAndWait {
            let rb = RadioBeacon(context: persistentStore.viewContext)

            rb.volumeNumber = "PUB 110"
            rb.aidType = "Radiobeacons"
            rb.geopoliticalHeading = "GREENLAND"
            rb.regionHeading = nil
            rb.precedingNote = nil
            rb.featureNumber = 10
            rb.name = "Ittoqqortoormit, Scoresbysund"
            rb.position = "70°29'11.99\"N \n21°58'20\"W"
            rb.characteristic = "SC\n(• • •  - • - • ).\n"
            rb.range = 200
            rb.sequenceText = nil
            rb.frequency = "343\nNON, A2A."
            rb.stationRemark = "Aeromarine."
            rb.postNote = nil
            rb.noticeNumber = 199706
            rb.removeFromList = "N"
            rb.deleteFlag = "N"
            rb.noticeWeek = "06"
            rb.noticeYear = "1997"
            rb.latitude = 1.0
            rb.longitude = 2.0
            rb.sectionHeader = "section"

            newItem = rb

            let rb2 = RadioBeacon(context: persistentStore.viewContext)

            rb2.volumeNumber = "PUB 110"
            rb2.aidType = "Radiobeacons"
            rb2.geopoliticalHeading = "GREENLAND"
            rb2.regionHeading = nil
            rb2.precedingNote = nil
            rb2.featureNumber = 11
            rb2.name = "Ittoqqortoormit, Scoresbysund"
            rb2.position = "70°29'11.99\"N \n21°58'20\"W"
            rb2.characteristic = "SC\n(• • •  - • - • ).\n"
            rb2.range = 200
            rb2.sequenceText = nil
            rb2.frequency = "343\nNON, A2A."
            rb2.stationRemark = "Aeromarine."
            rb2.postNote = nil
            rb2.noticeNumber = 199706
            rb2.removeFromList = "N"
            rb2.deleteFlag = "N"
            rb2.noticeWeek = "06"
            rb2.noticeYear = "1997"
            rb2.latitude = 20.0
            rb2.longitude = 20.0
            rb2.sectionHeader = "section"

            newItem2 = rb2
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

        let dataSource = RadioBeaconCoreDataDataSource()

        let retrieved = dataSource.getRadioBeacon(featureNumber: Int(newItem.featureNumber), volumeNumber: newItem.volumeNumber)
        XCTAssertEqual(retrieved?.featureNumber, Int(newItem.featureNumber))
        XCTAssertEqual(retrieved?.volumeNumber, newItem.volumeNumber)

        let retrieved2 = dataSource.getRadioBeacon(featureNumber: Int(newItem2.featureNumber), volumeNumber: newItem2.volumeNumber)
        XCTAssertEqual(retrieved2?.featureNumber, Int(newItem2.featureNumber))
        XCTAssertEqual(retrieved2?.volumeNumber, newItem2.volumeNumber)

        let no = dataSource.getRadioBeacon(featureNumber: -1, volumeNumber: "no")
        XCTAssertNil(no)
    }

    func testGetNewestRadioBeacon() {
        var newItem: RadioBeacon?
        var newItem2: RadioBeacon?

        persistentStore.viewContext.performAndWait {
            let rb = RadioBeacon(context: persistentStore.viewContext)

            rb.volumeNumber = "PUB 110"
            rb.aidType = "Radiobeacons"
            rb.geopoliticalHeading = "GREENLAND"
            rb.regionHeading = nil
            rb.precedingNote = nil
            rb.featureNumber = 10
            rb.name = "Ittoqqortoormit, Scoresbysund"
            rb.position = "70°29'11.99\"N \n21°58'20\"W"
            rb.characteristic = "SC\n(• • •  - • - • ).\n"
            rb.range = 200
            rb.sequenceText = nil
            rb.frequency = "343\nNON, A2A."
            rb.stationRemark = "Aeromarine."
            rb.postNote = nil
            rb.noticeNumber = 199706
            rb.removeFromList = "N"
            rb.deleteFlag = "N"
            rb.noticeWeek = "06"
            rb.noticeYear = "1997"
            rb.latitude = 1.0
            rb.longitude = 2.0
            rb.sectionHeader = "section"

            newItem = rb

            let rb2 = RadioBeacon(context: persistentStore.viewContext)

            rb2.volumeNumber = "PUB 110"
            rb2.aidType = "Radiobeacons"
            rb2.geopoliticalHeading = "GREENLAND"
            rb2.regionHeading = nil
            rb2.precedingNote = nil
            rb2.featureNumber = 11
            rb2.name = "Ittoqqortoormit, Scoresbysund"
            rb2.position = "70°29'11.99\"N \n21°58'20\"W"
            rb2.characteristic = "SC\n(• • •  - • - • ).\n"
            rb2.range = 200
            rb2.sequenceText = nil
            rb2.frequency = "343\nNON, A2A."
            rb2.stationRemark = "Aeromarine."
            rb2.postNote = nil
            rb2.noticeNumber = 199706
            rb2.removeFromList = "N"
            rb2.deleteFlag = "N"
            rb2.noticeWeek = "06"
            rb2.noticeYear = "2000"
            rb2.latitude = 20.0
            rb2.longitude = 20.0
            rb2.sectionHeader = "section"

            newItem2 = rb2
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

        let dataSource = RadioBeaconCoreDataDataSource()

        let retrieved = dataSource.getNewestRadioBeacon()
        XCTAssertEqual(retrieved?.featureNumber, Int(newItem2.featureNumber))
        XCTAssertEqual(retrieved?.volumeNumber, newItem2.volumeNumber)
    }

    func testGetNewestEmpty() {
        let dataSource = RadioBeaconCoreDataDataSource()

        let retrieved = dataSource.getNewestRadioBeacon()
        XCTAssertNil(retrieved)
    }

    func testGetRadioBeaconsInBounds() async {
        var newItem: RadioBeaconModel?
        var newItem2: RadioBeaconModel?

        persistentStore.viewContext.performAndWait {
            let rb = RadioBeacon(context: persistentStore.viewContext)

            rb.volumeNumber = "PUB 110"
            rb.aidType = "Radiobeacons"
            rb.geopoliticalHeading = "GREENLAND"
            rb.regionHeading = nil
            rb.precedingNote = nil
            rb.featureNumber = 10
            rb.name = "Ittoqqortoormit, Scoresbysund"
            rb.position = "70°29'11.99\"N \n21°58'20\"W"
            rb.characteristic = "SC\n(• • •  - • - • ).\n"
            rb.range = 200
            rb.sequenceText = nil
            rb.frequency = "343\nNON, A2A."
            rb.stationRemark = "Aeromarine."
            rb.postNote = nil
            rb.noticeNumber = 199706
            rb.removeFromList = "N"
            rb.deleteFlag = "N"
            rb.noticeWeek = "06"
            rb.noticeYear = "1997"
            rb.latitude = 1.0
            rb.longitude = 1.0
            rb.sectionHeader = "section"

            newItem = RadioBeaconModel(radioBeacon: rb)

            let rb2 = RadioBeacon(context: persistentStore.viewContext)

            rb2.volumeNumber = "PUB 110"
            rb2.aidType = "Radiobeacons"
            rb2.geopoliticalHeading = "GREENLAND"
            rb2.regionHeading = nil
            rb2.precedingNote = nil
            rb2.featureNumber = 11
            rb2.name = "Ittoqqortoormit, Scoresbysund"
            rb2.position = "70°29'11.99\"N \n21°58'20\"W"
            rb2.characteristic = "SC\n(• • •  - • - • ).\n"
            rb2.range = 200
            rb2.sequenceText = nil
            rb2.frequency = "343\nNON, A2A."
            rb2.stationRemark = "Aeromarine."
            rb2.postNote = nil
            rb2.noticeNumber = 199706
            rb2.removeFromList = "N"
            rb2.deleteFlag = "N"
            rb2.noticeWeek = "06"
            rb2.noticeYear = "2000"
            rb2.latitude = 20.0
            rb2.longitude = 20.0
            rb2.sectionHeader = "section"

            newItem2 = RadioBeaconModel(radioBeacon: rb2)
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

        let dataSource = RadioBeaconCoreDataDataSource()

        let retrieved = await dataSource.getRadioBeaconsInBounds(filters: nil, minLatitude: 19, maxLatitude: 21, minLongitude: 19, maxLongitude: 21)
        XCTAssertEqual(retrieved.count, 1)
        XCTAssertEqual(retrieved[0].featureNumber, Int(exactly: newItem2.featureNumber!)!)
        let retrieved2 = await dataSource.getRadioBeaconsInBounds(filters: nil, minLatitude: 0, maxLatitude: 1, minLongitude: 0, maxLongitude: 1)
        XCTAssertEqual(retrieved2.count, 1)
        XCTAssertEqual(retrieved2[0].featureNumber, Int(exactly: newItem.featureNumber!)!)
        let retrieved3 = await dataSource.getRadioBeaconsInBounds(filters: nil, minLatitude: 0, maxLatitude: 21, minLongitude: 0, maxLongitude: 21)
        XCTAssertEqual(retrieved3.count, 2)
    }

    func testPublisher() async {
        UserDefaults.standard.setSort(DataSources.radioBeacon.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Feature Number",
                    key: #keyPath(RadioBeacon.featureNumber),
                    type: .int
                ),
                ascending: false,
                section: false
            )
        ])
        var newItem: RadioBeacon?
        persistentStore.viewContext.performAndWait {
            let rb = RadioBeacon(context: persistentStore.viewContext)

            rb.volumeNumber = "PUB 110"
            rb.aidType = "Radiobeacons"
            rb.geopoliticalHeading = "GREENLAND"
            rb.regionHeading = nil
            rb.precedingNote = nil
            rb.featureNumber = 10
            rb.name = "Ittoqqortoormit, Scoresbysund"
            rb.position = "70°29'11.99\"N \n21°58'20\"W"
            rb.characteristic = "SC\n(• • •  - • - • ).\n"
            rb.range = 200
            rb.sequenceText = nil
            rb.frequency = "343\nNON, A2A."
            rb.stationRemark = "Aeromarine."
            rb.postNote = nil
            rb.noticeNumber = 199706
            rb.removeFromList = "N"
            rb.deleteFlag = "N"
            rb.noticeWeek = "06"
            rb.noticeYear = "1997"
            rb.latitude = 1.0
            rb.longitude = 1.0
            rb.sectionHeader = "section"

            newItem = rb
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [RadioBeaconItem])
            case failure(error: Error)

            fileprivate var rows: [RadioBeaconItem] {
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
        let dataSource = RadioBeaconCoreDataDataSource()

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.radioBeacons(
                filters: UserDefaults.standard.filter(DataSources.radioBeacon),
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
        var newItem2: RadioBeacon?
        persistentStore.viewContext.performAndWait {
            let rb2 = RadioBeacon(context: persistentStore.viewContext)

            rb2.volumeNumber = "PUB 110"
            rb2.aidType = "Radiobeacons"
            rb2.geopoliticalHeading = "GREENLAND"
            rb2.regionHeading = nil
            rb2.precedingNote = nil
            rb2.featureNumber = 11
            rb2.name = "Ittoqqortoormit, Scoresbysund"
            rb2.position = "70°29'11.99\"N \n21°58'20\"W"
            rb2.characteristic = "SC\n(• • •  - • - • ).\n"
            rb2.range = 200
            rb2.sequenceText = nil
            rb2.frequency = "343\nNON, A2A."
            rb2.stationRemark = "Aeromarine."
            rb2.postNote = nil
            rb2.noticeNumber = 199706
            rb2.removeFromList = "N"
            rb2.deleteFlag = "N"
            rb2.noticeWeek = "06"
            rb2.noticeYear = "2000"
            rb2.latitude = 20.0
            rb2.longitude = 20.0
            rb2.sectionHeader = "section"

            newItem2 = rb2
            try? persistentStore.viewContext.save()
        }
        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 2)

        await fulfillment(of: [expecation2], timeout: 5)
    }

    func testPublisherWithSectionHeader() async {
        UserDefaults.standard.setSort(DataSources.radioBeacon.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Feature Number",
                    key: #keyPath(RadioBeacon.featureNumber),
                    type: .int
                ),
                ascending: false,
                section: true
            )
        ])
        var newItem: RadioBeacon?
        persistentStore.viewContext.performAndWait {
            let rb = RadioBeacon(context: persistentStore.viewContext)

            rb.volumeNumber = "PUB 110"
            rb.aidType = "Radiobeacons"
            rb.geopoliticalHeading = "GREENLAND"
            rb.regionHeading = nil
            rb.precedingNote = nil
            rb.featureNumber = 10
            rb.name = "Ittoqqortoormit, Scoresbysund"
            rb.position = "70°29'11.99\"N \n21°58'20\"W"
            rb.characteristic = "SC\n(• • •  - • - • ).\n"
            rb.range = 200
            rb.sequenceText = nil
            rb.frequency = "343\nNON, A2A."
            rb.stationRemark = "Aeromarine."
            rb.postNote = nil
            rb.noticeNumber = 199706
            rb.removeFromList = "N"
            rb.deleteFlag = "N"
            rb.noticeWeek = "06"
            rb.noticeYear = "1997"
            rb.latitude = 1.0
            rb.longitude = 1.0
            rb.sectionHeader = "section"

            newItem = rb
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [RadioBeaconItem])
            case failure(error: Error)

            fileprivate var rows: [RadioBeaconItem] {
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
        let dataSource = RadioBeaconCoreDataDataSource()

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.radioBeacons(
                filters: UserDefaults.standard.filter(DataSources.radioBeacon),
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

        NSLog("Rows \(state.rows)")
        let item = state.rows[0]
        switch item {
        case .listItem(_):
            XCTFail()
        case .sectionHeader(let header):
            XCTAssertEqual(header, "10")
        }
        let item1 = state.rows[1]
        switch item1 {
        case .listItem(let asam):
            XCTAssertEqual(asam.featureNumber, 10)
        case .sectionHeader(_):
            XCTFail()
        }

        NSLog("Insert a new one")
        var newItem2: RadioBeacon?
        persistentStore.viewContext.performAndWait {
            let rb2 = RadioBeacon(context: persistentStore.viewContext)

            rb2.volumeNumber = "PUB 110"
            rb2.aidType = "Radiobeacons"
            rb2.geopoliticalHeading = "GREENLAND"
            rb2.regionHeading = nil
            rb2.precedingNote = nil
            rb2.featureNumber = 11
            rb2.name = "Ittoqqortoormit, Scoresbysund"
            rb2.position = "70°29'11.99\"N \n21°58'20\"W"
            rb2.characteristic = "SC\n(• • •  - • - • ).\n"
            rb2.range = 200
            rb2.sequenceText = nil
            rb2.frequency = "343\nNON, A2A."
            rb2.stationRemark = "Aeromarine."
            rb2.postNote = nil
            rb2.noticeNumber = 199706
            rb2.removeFromList = "N"
            rb2.deleteFlag = "N"
            rb2.noticeWeek = "06"
            rb2.noticeYear = "2000"
            rb2.latitude = 20.0
            rb2.longitude = 20.0
            rb2.sectionHeader = "section"

            newItem2 = rb2
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
            XCTAssertEqual(header, "11")
        }
        let itema1 = state.rows[1]
        switch itema1 {
        case .listItem(let asam):
            XCTAssertEqual(asam.featureNumber, 11)
        case .sectionHeader(_):
            XCTFail()
        }
        let itema2 = state.rows[2]
        switch itema2 {
        case .listItem(_):
            XCTFail()
        case .sectionHeader(let header):
            XCTAssertEqual(header, "10")
        }
        let itema3 = state.rows[3]
        switch itema3 {
        case .listItem(let asam):
            XCTAssertEqual(asam.featureNumber, 10)
        case .sectionHeader(_):
            XCTFail()
        }
    }

    func testInsert() async {
        var rb = RadioBeaconModel()

        rb.volumeNumber = "PUB 110"
        rb.aidType = "Radiobeacons"
        rb.geopoliticalHeading = "GREENLAND"
        rb.regionHeading = nil
        rb.precedingNote = nil
        rb.featureNumber = 10
        rb.name = "Ittoqqortoormit, Scoresbysund"
        rb.position = "70°29'11.99\"N \n21°58'20\"W"
        rb.characteristic = "SC\n(• • •  - • - • ).\n"
        rb.range = 200
        rb.sequenceText = nil
        rb.frequency = "343\nNON, A2A."
        rb.stationRemark = "Aeromarine."
        rb.postNote = nil
        rb.noticeNumber = 199706
        rb.removeFromList = "N"
        rb.deleteFlag = "N"
        rb.noticeWeek = "06"
        rb.noticeYear = "1997"
        rb.latitude = 1.0
        rb.longitude = 1.0
        rb.sectionHeader = "section"

        let dataSource = RadioBeaconCoreDataDataSource()

        let inserted = await dataSource.insert(radioBeacons: [rb])
        XCTAssertEqual(1, inserted)

        let retrieved = dataSource.getRadioBeacon(featureNumber: rb.featureNumber, volumeNumber: rb.volumeNumber)
        XCTAssertEqual(retrieved?.featureNumber, rb.featureNumber)
        XCTAssertEqual(retrieved?.volumeNumber, rb.volumeNumber)
    }

    func testGetRadioBeacons() async {
        var rb = RadioBeaconModel()

        rb.volumeNumber = "PUB 110"
        rb.aidType = "Radiobeacons"
        rb.geopoliticalHeading = "GREENLAND"
        rb.regionHeading = nil
        rb.precedingNote = nil
        rb.featureNumber = 10
        rb.name = "Ittoqqortoormit, Scoresbysund"
        rb.position = "70°29'11.99\"N \n21°58'20\"W"
        rb.characteristic = "SC\n(• • •  - • - • ).\n"
        rb.range = 200
        rb.sequenceText = nil
        rb.frequency = "343\nNON, A2A."
        rb.stationRemark = "Aeromarine."
        rb.postNote = nil
        rb.noticeNumber = 199706
        rb.removeFromList = "N"
        rb.deleteFlag = "N"
        rb.noticeWeek = "06"
        rb.noticeYear = "1997"
        rb.latitude = 1.0
        rb.longitude = 1.0
        rb.sectionHeader = "section"

        let dataSource = RadioBeaconCoreDataDataSource()

        let inserted = await dataSource.insert(radioBeacons: [rb])
        XCTAssertEqual(1, inserted)

        let retrieved = await dataSource.getRadioBeacons(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "featureNumber", key: "featureNumber", type: .int), comparison: DataSourceFilterComparison.equals, valueInt: rb.featureNumber)])
        XCTAssertEqual(1, retrieved.count)
        XCTAssertEqual(retrieved[0].featureNumber, rb.featureNumber)
        XCTAssertEqual(retrieved[0].volumeNumber, rb.volumeNumber)

        let retrievedNone = await dataSource.getRadioBeacons(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "featureNumber", key: "featureNumber", type: .int), comparison: DataSourceFilterComparison.equals, valueInt: -1)])
        XCTAssertEqual(0, retrievedNone.count)
    }

}
