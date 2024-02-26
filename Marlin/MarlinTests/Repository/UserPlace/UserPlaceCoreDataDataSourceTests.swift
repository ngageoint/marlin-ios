//
//  UserPlaceCoreDataDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/26/24.
//

import Foundation
import Combine
import CoreData

@testable import Marlin

final class UserPlaceCoreDataDataSourceTests: XCTestCase {

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
        UserDefaults.standard.setSort(DataSources.userPlace.key, sort: DataSources.userPlace.filterable!.defaultSort)

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

    func testCount() async {
        let dataSource = UserPlaceCoreDataDataSource()
        let count = await dataSource.getCount(filters: nil)
        XCTAssertEqual(count, 0)

        let date = Date()
        persistentStore.viewContext.performAndWait {
            let place = UserPlace(context: persistentStore.viewContext)
            place.name = "My Place"
            place.date = date
            place.longitude = 1.0
            place.latitude = 1.0
            place.maxLongitude = 1.0
            place.maxLatitude = 1.0
            place.minLongitude = 1.0
            place.minLatitude = 1.0
            place.json = "json"
            try? persistentStore.viewContext.save()
        }

        let count2 = await dataSource.getCount(filters: nil)
        XCTAssertEqual(count2, 1)
    }

    func testInsertAndGet() async {
        let dataSource = UserPlaceCoreDataDataSource()
        let count = await dataSource.getCount(filters: nil)
        XCTAssertEqual(count, 0)
        let date = Date()

        var place = UserPlaceModel()
        place.name = "My Place"
        place.date = date
        place.longitude = 1.0
        place.latitude = 1.0
        place.maxLongitude = 1.0
        place.maxLatitude = 1.0
        place.minLongitude = 1.0
        place.minLatitude = 1.0
        place.json = "json"

        let newPlace = await dataSource.insert(userPlace: place)
        let count2 = await dataSource.getCount(filters: nil)
        XCTAssertEqual(count2, 1)

        XCTAssertNotNil(newPlace!.uri)
        XCTAssertEqual(newPlace!.name, place.name)
        XCTAssertEqual(newPlace!.date, place.date)
        XCTAssertEqual(newPlace!.longitude, place.longitude)
        XCTAssertEqual(newPlace!.latitude, place.latitude)
        XCTAssertEqual(newPlace!.maxLongitude, place.maxLongitude)
        XCTAssertEqual(newPlace!.maxLatitude, place.maxLatitude)
        XCTAssertEqual(newPlace!.minLongitude, place.minLongitude)
        XCTAssertEqual(newPlace!.minLatitude, place.minLatitude)
        XCTAssertEqual(newPlace!.json, place.json)

        let retrieved = await dataSource.getUserPlace(uri: newPlace!.uri!)
        XCTAssertEqual(newPlace!.name, retrieved!.name)
        XCTAssertEqual(newPlace!.date, retrieved!.date)
        XCTAssertEqual(newPlace!.longitude, retrieved!.longitude)
        XCTAssertEqual(newPlace!.latitude, retrieved!.latitude)
        XCTAssertEqual(newPlace!.maxLongitude, retrieved!.maxLongitude)
        XCTAssertEqual(newPlace!.maxLatitude, retrieved!.maxLatitude)
        XCTAssertEqual(newPlace!.minLongitude, retrieved!.minLongitude)
        XCTAssertEqual(newPlace!.minLatitude, retrieved!.minLatitude)
        XCTAssertEqual(newPlace!.json, retrieved!.json)
        XCTAssertEqual(newPlace!.uri, retrieved!.uri)
    }

    func testGetInBounds() async {
        let dataSource = UserPlaceCoreDataDataSource()
        let count = await dataSource.getCount(filters: nil)
        XCTAssertEqual(count, 0)
        let date = Date()

        var place = UserPlaceModel()
        place.name = "My Place"
        place.date = date
        place.longitude = 1.0
        place.latitude = 1.0
        place.maxLongitude = 1.0
        place.maxLatitude = 1.0
        place.minLongitude = 1.0
        place.minLatitude = 1.0
        place.json = "json"

        var place2 = UserPlaceModel()
        place2.name = "My Place2"
        place2.date = date
        place2.longitude = 10.0
        place2.latitude = 10.0
        place2.maxLongitude = 10.0
        place2.maxLatitude = 10.0
        place2.minLongitude = 10.0
        place2.minLatitude = 10.0
        place2.json = "json"

        let inserted1 = await dataSource.insert(userPlace: place)
        let inserted2 = await dataSource.insert(userPlace: place2)
        let count2 = await dataSource.getCount(filters: nil)
        XCTAssertEqual(count2, 2)

        let places = await dataSource.getUserPlacesInBounds(filters: nil, minLatitude: 0, maxLatitude: 2, minLongitude: 0, maxLongitude: 2)
        XCTAssertEqual(places.count, 1)

        let newPlace = places[0]
        XCTAssertEqual(inserted1!.name, newPlace.name)
        XCTAssertEqual(inserted1!.date, newPlace.date)
        XCTAssertEqual(inserted1!.longitude, newPlace.longitude)
        XCTAssertEqual(inserted1!.latitude, newPlace.latitude)
        XCTAssertEqual(inserted1!.maxLongitude, newPlace.maxLongitude)
        XCTAssertEqual(inserted1!.maxLatitude, newPlace.maxLatitude)
        XCTAssertEqual(inserted1!.minLongitude, newPlace.minLongitude)
        XCTAssertEqual(inserted1!.minLatitude, newPlace.minLatitude)
        XCTAssertEqual(inserted1!.json, newPlace.json)
        XCTAssertEqual(inserted1!.uri, newPlace.uri)

        let places2 = await dataSource.getUserPlacesInBounds(filters: nil, minLatitude: 8, maxLatitude: 12, minLongitude: 8, maxLongitude: 12)
        XCTAssertEqual(places2.count, 1)

        let retrieved = places2[0]
        XCTAssertEqual(inserted2!.name, retrieved.name)
        XCTAssertEqual(inserted2!.date, retrieved.date)
        XCTAssertEqual(inserted2!.longitude, retrieved.longitude)
        XCTAssertEqual(inserted2!.latitude, retrieved.latitude)
        XCTAssertEqual(inserted2!.maxLongitude, retrieved.maxLongitude)
        XCTAssertEqual(inserted2!.maxLatitude, retrieved.maxLatitude)
        XCTAssertEqual(inserted2!.minLongitude, retrieved.minLongitude)
        XCTAssertEqual(inserted2!.minLatitude, retrieved.minLatitude)
        XCTAssertEqual(inserted2!.json, retrieved.json)
        XCTAssertEqual(inserted2!.uri, retrieved.uri)

        let places3 = await dataSource.getUserPlacesInBounds(filters: nil, minLatitude: 0, maxLatitude: 12, minLongitude: 0, maxLongitude: 12)
        XCTAssertEqual(places3.count, 2)
    }

    func testPublisher() async {
        let date = Date()
        var place = UserPlaceModel()
        place.name = "My Place"
        place.date = date
        place.longitude = 1.0
        place.latitude = 1.0
        place.maxLongitude = 1.0
        place.maxLatitude = 1.0
        place.minLongitude = 1.0
        place.minLatitude = 1.0
        place.json = "json"

        let dataSource = UserPlaceCoreDataDataSource()
        let inserted = await dataSource.insert(userPlace: place)

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [UserPlaceItem])
            case failure(error: Error)

            fileprivate var rows: [UserPlaceItem] {
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

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.userPlaces(
                filters: UserDefaults.standard.filter(DataSources.userPlace),
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
        var place2 = UserPlaceModel()
        place2.name = "My Place 2"
        place2.date = date
        place2.longitude = 1.0
        place2.latitude = 1.0
        place2.maxLongitude = 1.0
        place2.maxLatitude = 1.0
        place2.minLongitude = 1.0
        place2.minLatitude = 1.0
        place2.json = "json"
        let inserted2 = await dataSource.insert(userPlace: place2)

        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 2)

        await fulfillment(of: [expecation2], timeout: 5)
    }

    func testPublisherWithSectionHeader() async {
        UserDefaults.standard.setSort(DataSources.userPlace.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Name",
                    key: #keyPath(UserPlace.name),
                    type: .string),
                ascending: false,
                section: true)
        ])

        let date = Date()
        var place = UserPlaceModel()
        place.name = "My Place"
        place.date = date
        place.longitude = 1.0
        place.latitude = 1.0
        place.maxLongitude = 1.0
        place.maxLatitude = 1.0
        place.minLongitude = 1.0
        place.minLatitude = 1.0
        place.json = "json"

        let dataSource = UserPlaceCoreDataDataSource()
        let inserted = await dataSource.insert(userPlace: place)

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [UserPlaceItem])
            case failure(error: Error)

            fileprivate var rows: [UserPlaceItem] {
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

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.userPlaces(
                filters: UserDefaults.standard.filter(DataSources.userPlace),
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
            XCTAssertEqual(header, "My Place")
        }
        let item1 = state.rows[1]
        switch item1 {
        case .listItem(let userPlace):
            XCTAssertEqual(userPlace.latitude, 1.0)
        case .sectionHeader(_):
            XCTFail()
        }

        NSLog("Insert a new one")
        var place2 = UserPlaceModel()
        place2.name = "My Place 2"
        place2.date = date
        place2.longitude = 10.0
        place2.latitude = 10.0
        place2.maxLongitude = 10.0
        place2.maxLatitude = 10.0
        place2.minLongitude = 10.0
        place2.minLatitude = 10.0
        place2.json = "json"
        let inserted2 = await dataSource.insert(userPlace: place2)

        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 4)

        await fulfillment(of: [expecation2], timeout: 5)

        let itema = state.rows[0]
        switch itema {
        case .listItem(_):
            XCTFail()
        case .sectionHeader(let header):
            XCTAssertEqual(header, "My Place 2")
        }
        let itema1 = state.rows[1]
        switch itema1 {
        case .listItem(let userPlace):
            XCTAssertEqual(userPlace.latitude, 10.0)
        case .sectionHeader(_):
            XCTFail()
        }
        let itema2 = state.rows[2]
        switch itema2 {
        case .listItem(_):
            XCTFail()
        case .sectionHeader(let header):
            XCTAssertEqual(header, "My Place")
        }
        let itema3 = state.rows[3]
        switch itema3 {
        case .listItem(let userPlace):
            XCTAssertEqual(userPlace.latitude, 1.0)
        case .sectionHeader(_):
            XCTFail()
        }
    }
}
