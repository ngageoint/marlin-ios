//
//  PortCoreDataDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import Combine
import CoreData

@testable import Marlin

final class PortCoreDataDataSourceTests: XCTestCase {
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
        var newItem: Marlin.Port?
        persistentStore.viewContext.performAndWait {
            let port = Marlin.Port(context: persistentStore.viewContext)
            port.portNumber = 5
            port.longitude = 1.0
            port.latitude = 1.0
            newItem = port
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let dataSource = PortCoreDataDataSource()

        XCTAssertEqual(dataSource.getCount(filters: nil), 1)
    }

    func testGetPort() {
        var newItem: Marlin.Port?
        var newItem2: Marlin.Port?
        persistentStore.viewContext.performAndWait {
            let port = Marlin.Port(context: persistentStore.viewContext)
            port.portNumber = 5
            port.longitude = 1.0
            port.latitude = 1.0
            newItem = port

            let port2 = Marlin.Port(context: persistentStore.viewContext)
            port2.portNumber = 6
            port2.longitude = 20.0
            port2.latitude = 20.0
            newItem2 = port2

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

        let dataSource = PortCoreDataDataSource()

        let retrieved = dataSource.getPort(portNumber: 5)
        XCTAssertEqual(retrieved?.portNumber, Int(newItem.portNumber))

        let retrieved2 = dataSource.getPort(portNumber: 6)
        XCTAssertEqual(retrieved2?.portNumber, Int(newItem2.portNumber))

        let no = dataSource.getPort(portNumber: -1)
        XCTAssertNil(no)
    }

    func testGetPortsInBounds() async {
        var newItem: Marlin.Port?
        var newItem2: Marlin.Port?
        persistentStore.viewContext.performAndWait {
            let port = Marlin.Port(context: persistentStore.viewContext)
            port.portNumber = 5
            port.longitude = 1.0
            port.latitude = 1.0
            newItem = port

            let port2 = Marlin.Port(context: persistentStore.viewContext)
            port2.portNumber = 6
            port2.longitude = 20.0
            port2.latitude = 20.0
            newItem2 = port2

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

        let dataSource = PortCoreDataDataSource()

        let retrieved = await dataSource.getPortsInBounds(filters: nil, minLatitude: 19, maxLatitude: 21, minLongitude: 19, maxLongitude: 21)
        XCTAssertEqual(retrieved.count, 1)
        XCTAssertEqual(retrieved[0].portNumber, Int(newItem2.portNumber))
        let retrieved2 = await dataSource.getPortsInBounds(filters: nil, minLatitude: 0, maxLatitude: 1, minLongitude: 0, maxLongitude: 1)
        XCTAssertEqual(retrieved2.count, 1)
        XCTAssertEqual(retrieved2[0].portNumber, Int(newItem.portNumber))
        let retrieved3 = await dataSource.getPortsInBounds(filters: nil, minLatitude: 0, maxLatitude: 21, minLongitude: 0, maxLongitude: 21)
        XCTAssertEqual(retrieved3.count, 2)
    }

    func testPublisher() async {
        UserDefaults.standard.setSort(DataSources.port.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Port Number",
                    key: #keyPath(Marlin.Port.portNumber),
                    type: .int),
                ascending: false,
                section: false)
        ])

        var newItem: Marlin.Port?
        var newItem2: Marlin.Port?
        persistentStore.viewContext.performAndWait {
            let port = Marlin.Port(context: persistentStore.viewContext)
            port.portNumber = 5
            port.longitude = 1.0
            port.latitude = 1.0
            newItem = port
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [PortItem])
            case failure(error: Error)

            fileprivate var rows: [PortItem] {
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
        let dataSource = PortCoreDataDataSource()

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.ports(
                filters: UserDefaults.standard.filter(DataSources.port),
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
        persistentStore.viewContext.performAndWait {
            let port2 = Marlin.Port(context: persistentStore.viewContext)
            port2.portNumber = 6
            port2.longitude = 20.0
            port2.latitude = 20.0
            newItem2 = port2

            try? persistentStore.viewContext.save()
        }
        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 2)

        await fulfillment(of: [expecation2], timeout: 5)
    }

    func testPublisherWithSectionHeader() async {
        UserDefaults.standard.setSort(DataSources.port.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Port Number",
                    key: #keyPath(Marlin.Port.portNumber),
                    type: .int),
                ascending: false,
                section: true)
        ])

        var newItem: Marlin.Port?
        var newItem2: Marlin.Port?
        persistentStore.viewContext.performAndWait {
            let port = Marlin.Port(context: persistentStore.viewContext)
            port.portNumber = 5
            port.longitude = 1.0
            port.latitude = 1.0
            newItem = port
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [PortItem])
            case failure(error: Error)

            fileprivate var rows: [PortItem] {
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
        let dataSource = PortCoreDataDataSource()

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.ports(
                filters: UserDefaults.standard.filter(DataSources.port),
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
            XCTAssertEqual(header, "5")
        }
        let item1 = state.rows[1]
        switch item1 {
        case .listItem(let port):
            XCTAssertEqual(port.portNumber, 5)
        case .sectionHeader(_):
            XCTFail()
        }

        NSLog("Insert a new one")
        persistentStore.viewContext.performAndWait {
            let port2 = Marlin.Port(context: persistentStore.viewContext)
            port2.portNumber = 6
            port2.longitude = 20.0
            port2.latitude = 20.0
            newItem2 = port2

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
            XCTAssertEqual(header, "6")
        }
        let itema1 = state.rows[1]
        switch itema1 {
        case .listItem(let port):
            XCTAssertEqual(port.portNumber, 6)
        case .sectionHeader(_):
            XCTFail()
        }
        let itema2 = state.rows[2]
        switch itema2 {
        case .listItem(_):
            XCTFail()
        case .sectionHeader(let header):
            XCTAssertEqual(header, "5")
        }
        let itema3 = state.rows[3]
        switch itema3 {
        case .listItem(let port):
            XCTAssertEqual(port.portNumber, 5)
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

    func testGetPorts() async {
        var port = PortModel(portNumber: 5)
        port.longitude = 1.0
        port.latitude = 1.0

        let dataSource = PortCoreDataDataSource()

        let inserted = await dataSource.insert(ports: [port])
        XCTAssertEqual(1, inserted)

        let retrieved = await dataSource.getPorts(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "portNumber", key: "portNumber", type: .int), comparison: DataSourceFilterComparison.equals, valueInt: port.portNumber)])
        XCTAssertEqual(1, retrieved.count)
        XCTAssertEqual(retrieved[0].portNumber, port.portNumber)

        let retrievedNone = await dataSource.getPorts(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "portNumber", key: "portNumber", type: .int), comparison: DataSourceFilterComparison.equals, valueInt: -1)])
        XCTAssertEqual(0, retrievedNone.count)
    }
}
