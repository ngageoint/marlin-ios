//
//  AsamCoreDataDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 10/31/23.
//

import XCTest
import Combine
import CoreData

@testable import Marlin

final class AsamCoreDataDataSourceTests: XCTestCase {
    
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        completion(XCTSkip("ASAMs are disabled."))
        Task.init {
            await TestHelpers.asyncGetKeyWindowVisible()
        }
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
        UserDefaults.standard.setSort(DataSources.asam.key, sort: DataSources.asam.filterable!.defaultSort)
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.asam)
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
        var newItem: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            newItem = asam
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let dataSource = AsamCoreDataDataSource()
        
        XCTAssertEqual(dataSource.getCount(filters: nil), 1)
    }
    
    func testGetAsam() {
        var newItem: Asam?
        var newItem2: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Ship"
            
            newItem = asam
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description"
            asam2.longitude = 1.0
            asam2.latitude = 1.0
            asam2.date = Date(timeIntervalSince1970: 0)
            asam2.navArea = "XI"
            asam2.reference = "2022-101"
            asam2.subreg = "71"
            asam2.position = "1°00'00\"N \n1°00'00\"E"
            asam2.hostility = "Boarding"
            asam2.victim = "Boat"
            
            newItem2 = asam2
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
        
        let dataSource = AsamCoreDataDataSource()
        
        let retrieved = dataSource.getAsam(reference: newItem.reference)
        XCTAssertEqual(retrieved?.reference, newItem.reference)
        XCTAssertEqual(retrieved?.victim, newItem.victim)
        
        let retrieved2 = dataSource.getAsam(reference: newItem2.reference)
        XCTAssertEqual(retrieved2?.reference, newItem2.reference)
        XCTAssertEqual(retrieved2?.victim, newItem2.victim)
        
        let no = dataSource.getAsam(reference: "Nope")
        XCTAssertNil(no)
    }

    func testGetNewestAsam() {
        var newItem: Asam?
        var newItem2: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Ship"

            newItem = asam

            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description"
            asam2.longitude = 1.0
            asam2.latitude = 1.0
            asam2.date = Date(timeIntervalSince1970: 10)
            asam2.navArea = "XI"
            asam2.reference = "2022-101"
            asam2.subreg = "71"
            asam2.position = "1°00'00\"N \n1°00'00\"E"
            asam2.hostility = "Boarding"
            asam2.victim = "Boat"

            newItem2 = asam2
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

        let dataSource = AsamCoreDataDataSource()

        let retrieved = dataSource.getNewestAsam()
        XCTAssertEqual(retrieved?.reference, newItem2.reference)
        XCTAssertEqual(retrieved?.victim, newItem2.victim)
    }

    func testGetNewestEmpty() {
        let dataSource = AsamCoreDataDataSource()

        let retrieved = dataSource.getNewestAsam()
        XCTAssertNil(retrieved)
    }

    func testGetAsamsInBounds() async {
        var newItem: AsamModel?
        var newItem2: AsamModel?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 20.0
            asam.latitude = 20.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Ship"

            newItem = AsamModel(asam: asam)

            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description"
            asam2.longitude = 1.0
            asam2.latitude = 1.0
            asam2.date = Date(timeIntervalSince1970: 10)
            asam2.navArea = "XI"
            asam2.reference = "2022-101"
            asam2.subreg = "71"
            asam2.position = "1°00'00\"N \n1°00'00\"E"
            asam2.hostility = "Boarding"
            asam2.victim = "Boat"

            newItem2 = AsamModel(asam: asam2)
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

        let dataSource = AsamCoreDataDataSource()

        let retrieved = await dataSource.getAsamsInBounds(filters: nil, minLatitude: 19, maxLatitude: 21, minLongitude: 19, maxLongitude: 21)
        XCTAssertEqual(retrieved.count, 1)
        XCTAssertEqual(retrieved[0].reference, newItem.reference)
        let retrieved2 = await dataSource.getAsamsInBounds(filters: nil, minLatitude: 0, maxLatitude: 1, minLongitude: 0, maxLongitude: 1)
        XCTAssertEqual(retrieved2.count, 1)
        XCTAssertEqual(retrieved2[0].reference, newItem2.reference)
        let retrieved3 = await dataSource.getAsamsInBounds(filters: nil, minLatitude: 0, maxLatitude: 21, minLongitude: 0, maxLongitude: 21)
        XCTAssertEqual(retrieved3.count, 2)
    }

    func testPublisher() async {
        var newItem: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 20.0
            asam.latitude = 20.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Ship"

            newItem = asam
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [AsamItem])
            case failure(error: Error)

            fileprivate var rows: [AsamItem] {
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
        let dataSource = AsamCoreDataDataSource()

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.asams(
                filters: UserDefaults.standard.filter(DataSources.asam),
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
        var newItem2: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 20.0
            asam.latitude = 20.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-200"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Ship"

            newItem2 = asam
            try? persistentStore.viewContext.save()
        }
        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 2)

        await fulfillment(of: [expecation2], timeout: 5)
    }

    func testPublisherWithSectionHeader() async {
        UserDefaults.standard.setSort(DataSources.asam.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Date",
                    key: #keyPath(Asam.date),
                    type: .date),
                ascending: false,
                section: true)
        ])

        var newItem: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 20.0
            asam.latitude = 20.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Ship"

            newItem = asam
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [AsamItem])
            case failure(error: Error)

            fileprivate var rows: [AsamItem] {
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
        let dataSource = AsamCoreDataDataSource()

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.asams(
                filters: UserDefaults.standard.filter(DataSources.asam),
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
        case .listItem(let asam):
            XCTAssertEqual(asam.reference, "2022-100")
        case .sectionHeader(_):
            XCTFail()
        }

        NSLog("Insert a new one")
        var newItem2: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 20.0
            asam.latitude = 20.0
            asam.date = Date(timeIntervalSince1970: 1000000)
            asam.navArea = "XI"
            asam.reference = "2022-200"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Ship"

            newItem2 = asam
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
            XCTAssertEqual(header, "1970-01-12")
        }
        let itema1 = state.rows[1]
        switch itema1 {
        case .listItem(let asam):
            XCTAssertEqual(asam.reference, "2022-200")
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
        case .listItem(let asam):
            XCTAssertEqual(asam.reference, "2022-100")
        case .sectionHeader(_):
            XCTFail()
        }
    }

    func testInsert() async {
        var asam = AsamModel()
        asam.asamDescription = "description"
        asam.longitude = 1.0
        asam.latitude = 1.0
        asam.date = Date(timeIntervalSince1970: 0)
        asam.navArea = "XI"
        asam.reference = "2022-100"
        asam.subreg = "71"
        asam.position = "1°00'00\"N \n1°00'00\"E"
        asam.hostility = "Boarding"
        asam.victim = "Ship"
        
        let dataSource = AsamCoreDataDataSource()

        let inserted = await dataSource.insert(asams: [asam])
        XCTAssertEqual(1, inserted)
        
        let retrieved = dataSource.getAsam(reference: asam.reference)
        XCTAssertEqual(retrieved?.reference, asam.reference)
        XCTAssertEqual(retrieved?.victim, asam.victim)
    }
    
    func testGetAsams() async {
        var asam = AsamModel()
        asam.asamDescription = "description"
        asam.longitude = 1.0
        asam.latitude = 1.0
        asam.date = Date(timeIntervalSince1970: 0)
        asam.navArea = "XI"
        asam.reference = "2022-100"
        asam.subreg = "71"
        asam.position = "1°00'00\"N \n1°00'00\"E"
        asam.hostility = "Boarding"
        asam.victim = "Ship"
        
        let dataSource = AsamCoreDataDataSource()
        
        let inserted = await dataSource.insert(asams: [asam])
        XCTAssertEqual(1, inserted)

        let retrieved = await dataSource.getAsams(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "reference", key: "reference", type: .string), comparison: DataSourceFilterComparison.equals, valueString: asam.reference)])
        XCTAssertEqual(1, retrieved.count)
        XCTAssertEqual(retrieved[0].reference, asam.reference)
        XCTAssertEqual(retrieved[0].victim, asam.victim)
        
        let retrievedNone = await dataSource.getAsams(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "reference", key: "reference", type: .string), comparison: DataSourceFilterComparison.equals, valueString: "no")])
        XCTAssertEqual(0, retrievedNone.count)
    }

}
