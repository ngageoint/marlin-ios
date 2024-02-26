//
//  ModuCoreDataDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import Combine
import CoreData

@testable import Marlin

final class ModuCoreDataDataSourceTests: XCTestCase {

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
        UserDefaults.standard.setSort(DataSources.modu.key, sort: DataSources.modu.filterable!.defaultSort)
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.modu)
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
        var newItem: Modu?
        persistentStore.viewContext.performAndWait {
            let modu = Modu(context: persistentStore.viewContext)

            modu.name = "ABAN II"
            modu.date = Date(timeIntervalSince1970: 0)
            modu.rigStatus = "Active"
            modu.specialStatus = "Wide Berth Requested"
            modu.distance = 5
            modu.latitude = 1.0
            modu.longitude = 2.0
            modu.position = "16°20'30.6\"N \n81°55'27\"E"
            modu.navArea = "HYDROPAC"
            modu.region = 6
            modu.subregion = 63

            newItem = modu
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let dataSource = ModuCoreDataDataSource()

        XCTAssertEqual(dataSource.getCount(filters: nil), 1)
    }

    func testGetModu() {
        var newItem: Modu?
        var newItem2: Modu?
        persistentStore.viewContext.performAndWait {
            let modu = Modu(context: persistentStore.viewContext)

            modu.name = "ABAN II"
            modu.date = Date(timeIntervalSince1970: 0)
            modu.rigStatus = "Active"
            modu.specialStatus = "Wide Berth Requested"
            modu.distance = 5
            modu.latitude = 1.0
            modu.longitude = 1.0
            modu.position = "16°20'30.6\"N \n81°55'27\"E"
            modu.navArea = "HYDROPAC"
            modu.region = 6
            modu.subregion = 63

            newItem = modu

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 10000)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 20.0
            modu2.longitude = 20.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63

            newItem2 = modu2
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

        let dataSource = ModuCoreDataDataSource()

        let retrieved = dataSource.getModu(name: newItem.name)
        XCTAssertEqual(retrieved?.name, newItem.name)

        let retrieved2 = dataSource.getModu(name: newItem2.name)
        XCTAssertEqual(retrieved2?.name, newItem2.name)

        let no = dataSource.getModu(name: "Nope")
        XCTAssertNil(no)
    }

    func testGetNewestModu() {
        var newItem: Modu?
        var newItem2: Modu?
        persistentStore.viewContext.performAndWait {
            let modu = Modu(context: persistentStore.viewContext)

            modu.name = "ABAN II"
            modu.date = Date(timeIntervalSince1970: 0)
            modu.rigStatus = "Active"
            modu.specialStatus = "Wide Berth Requested"
            modu.distance = 5
            modu.latitude = 1.0
            modu.longitude = 1.0
            modu.position = "16°20'30.6\"N \n81°55'27\"E"
            modu.navArea = "HYDROPAC"
            modu.region = 6
            modu.subregion = 63

            newItem = modu

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 10000)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 20.0
            modu2.longitude = 20.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63

            newItem2 = modu2
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

        let dataSource = ModuCoreDataDataSource()
        
        let retrieved = dataSource.getNewestModu()
        XCTAssertEqual(retrieved?.name, newItem2.name)
    }

    func testGetNewestEmpty() {
        let dataSource = ModuCoreDataDataSource()

        let retrieved = dataSource.getNewestModu()
        XCTAssertNil(retrieved)
    }

    func testGetModuInBounds() async {
        var newItem: Modu?
        var newItem2: Modu?
        persistentStore.viewContext.performAndWait {
            let modu = Modu(context: persistentStore.viewContext)

            modu.name = "ABAN II"
            modu.date = Date(timeIntervalSince1970: 0)
            modu.rigStatus = "Active"
            modu.specialStatus = "Wide Berth Requested"
            modu.distance = 5
            modu.latitude = 1.0
            modu.longitude = 1.0
            modu.position = "16°20'30.6\"N \n81°55'27\"E"
            modu.navArea = "HYDROPAC"
            modu.region = 6
            modu.subregion = 63

            newItem = modu

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 10000)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 20.0
            modu2.longitude = 20.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63

            newItem2 = modu2
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

        let dataSource = ModuCoreDataDataSource()

        let retrieved = await dataSource.getModusInBounds(filters: nil, minLatitude: 19, maxLatitude: 21, minLongitude: 19, maxLongitude: 21)
        XCTAssertEqual(retrieved.count, 1)
        XCTAssertEqual(retrieved[0].name, newItem2.name)
        let retrieved2 = await dataSource.getModusInBounds(filters: nil, minLatitude: 0, maxLatitude: 1, minLongitude: 0, maxLongitude: 1)
        XCTAssertEqual(retrieved2.count, 1)
        XCTAssertEqual(retrieved2[0].name, newItem.name)
        let retrieved3 = await dataSource.getModusInBounds(filters: nil, minLatitude: 0, maxLatitude: 21, minLongitude: 0, maxLongitude: 21)
        XCTAssertEqual(retrieved3.count, 2)
    }

    func testPublisher() async {
        UserDefaults.standard.setSort(DataSources.modu.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Date",
                    key: #keyPath(Modu.date),
                    type: .date
                ),
                ascending: false
            )
        ])

        var newItem: Modu?
        persistentStore.viewContext.performAndWait {
            let modu = Modu(context: persistentStore.viewContext)

            modu.name = "ABAN II"
            modu.date = Date(timeIntervalSince1970: 0)
            modu.rigStatus = "Active"
            modu.specialStatus = "Wide Berth Requested"
            modu.distance = 5
            modu.latitude = 1.0
            modu.longitude = 1.0
            modu.position = "16°20'30.6\"N \n81°55'27\"E"
            modu.navArea = "HYDROPAC"
            modu.region = 6
            modu.subregion = 63

            newItem = modu
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [ModuItem])
            case failure(error: Error)

            fileprivate var rows: [ModuItem] {
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
        let dataSource = ModuCoreDataDataSource()

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.modus(
                filters: UserDefaults.standard.filter(DataSources.modu),
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
        var newItem2: Modu?
        persistentStore.viewContext.performAndWait {
            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 10000)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 20.0
            modu2.longitude = 20.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63

            newItem = modu2
            try? persistentStore.viewContext.save()
        }
        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 2)

        await fulfillment(of: [expecation2], timeout: 5)
    }

    func testPublisherWithSectionHeader() async {
        UserDefaults.standard.setSort(DataSources.modu.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Date",
                    key: #keyPath(Modu.date),
                    type: .date
                ),
                ascending: false,
                section: true
            )
        ])
        var newItem: Modu?
        persistentStore.viewContext.performAndWait {
            let modu = Modu(context: persistentStore.viewContext)

            modu.name = "ABAN II"
            modu.date = Date(timeIntervalSince1970: 0)
            modu.rigStatus = "Active"
            modu.specialStatus = "Wide Berth Requested"
            modu.distance = 5
            modu.latitude = 1.0
            modu.longitude = 1.0
            modu.position = "16°20'30.6\"N \n81°55'27\"E"
            modu.navArea = "HYDROPAC"
            modu.region = 6
            modu.subregion = 63

            newItem = modu
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [ModuItem])
            case failure(error: Error)

            fileprivate var rows: [ModuItem] {
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
        let dataSource = ModuCoreDataDataSource()

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.modus(
                filters: UserDefaults.standard.filter(DataSources.modu),
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
            XCTAssertEqual(header, "1969-12-31")
        }
        let item1 = state.rows[1]
        switch item1 {
        case .listItem(let modu):
            XCTAssertEqual(modu.name, "ABAN II")
        case .sectionHeader(_):
            XCTFail()
        }

        NSLog("Insert a new one")
        var newItem2: Modu?
        persistentStore.viewContext.performAndWait {
            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 1000000)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 20.0
            modu2.longitude = 20.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63

            newItem = modu2
            try? persistentStore.viewContext.save()
        }
        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 4)

        await fulfillment(of: [expecation2], timeout: 5)

        NSLog("rows: \(state.rows)")
        let itema = state.rows[0]
        switch itema {
        case .listItem(_):
            XCTFail()
        case .sectionHeader(let header):
            XCTAssertEqual(header, "1970-01-12")
        }
        let itema1 = state.rows[1]
        switch itema1 {
        case .listItem(let modu):
            XCTAssertEqual(modu.name, "ABAN II2")
        case .sectionHeader(_):
            XCTFail()
        }
        let itema2 = state.rows[2]
        switch itema2 {
        case .listItem(_):
            XCTFail()
        case .sectionHeader(let header):
            XCTAssertEqual(header, "1969-12-31")
        }
        let itema3 = state.rows[3]
        switch itema3 {
        case .listItem(let modu):
            XCTAssertEqual(modu.name, "ABAN II")
        case .sectionHeader(_):
            XCTFail()
        }
    }

    func testInsert() async {
        var modu2 = ModuModel()

        modu2.name = "ABAN II2"
        modu2.date = Date(timeIntervalSince1970: 1000000)
        modu2.rigStatus = "Active"
        modu2.specialStatus = "Wide Berth Requested"
        modu2.distance = 5
        modu2.latitude = 20.0
        modu2.longitude = 20.0
        modu2.position = "16°20'30.6\"N \n81°55'27\"E"
        modu2.navArea = "HYDROPAC"
        modu2.region = 6
        modu2.subregion = 63

        let dataSource = ModuCoreDataDataSource()

        let inserted = await dataSource.insert(modus: [modu2])
        XCTAssertEqual(1, inserted)

        let retrieved = dataSource.getModu(name: modu2.name)
        XCTAssertEqual(retrieved?.name, modu2.name)
    }

    func testGetModus() async {
        var modu2 = ModuModel()

        modu2.name = "ABAN II2"
        modu2.date = Date(timeIntervalSince1970: 1000000)
        modu2.rigStatus = "Active"
        modu2.specialStatus = "Wide Berth Requested"
        modu2.distance = 5
        modu2.latitude = 20.0
        modu2.longitude = 20.0
        modu2.position = "16°20'30.6\"N \n81°55'27\"E"
        modu2.navArea = "HYDROPAC"
        modu2.region = 6
        modu2.subregion = 63

        let dataSource = ModuCoreDataDataSource()
        let inserted = await dataSource.insert(modus: [modu2])
        XCTAssertEqual(1, inserted)

        let retrieved = await dataSource.getModus(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "name", key: "name", type: .string), comparison: DataSourceFilterComparison.equals, valueString: modu2.name)])
        XCTAssertEqual(1, retrieved.count)
        XCTAssertEqual(retrieved[0].name, modu2.name)

        let retrievedNone = await dataSource.getModus(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "name", key: "name", type: .string), comparison: DataSourceFilterComparison.equals, valueString: "no")])
        XCTAssertEqual(0, retrievedNone.count)
    }
}
