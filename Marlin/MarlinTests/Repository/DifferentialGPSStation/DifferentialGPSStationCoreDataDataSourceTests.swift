//
//  DifferentialGPSStationCoreDataDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/12/24.
//

import Foundation
import Combine
import CoreData

@testable import Marlin

final class DifferentialGPSStationCoreDataDataSourceTests: XCTestCase {

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
        UserDefaults.standard.setSort(DataSources.dgps.key, sort: DataSources.dgps.filterable!.defaultSort)
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.dgps)
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
        var newItem: DifferentialGPSStation?
        persistentStore.viewContext.performAndWait {
            var dgps = DifferentialGPSStation(context: persistentStore.viewContext)
            dgps.volumeNumber = "PUB 112"
            dgps.aidType = "Differential GPS Stations"
            dgps.geopoliticalHeading = "KOREA"
            dgps.regionHeading = "region heading"
            dgps.sectionHeader = "KOREA: region heading"
            dgps.precedingNote = "preceeding note"
            dgps.featureNumber = 6
            dgps.name = "Chojin Dan Lt"
            dgps.position = "1°00'00\"N \n2°00'00.00\"E"
            dgps.latitude = 1.0
            dgps.longitude = 2.0
            dgps.stationID = "T670\nR740\nR741"
            dgps.range = 100
            dgps.frequency = 292
            dgps.transferRate = 200
            dgps.remarks = "Message types: 3, 5, 7, 9, 16."
            dgps.postNote = "post note"
            dgps.noticeNumber = 201134
            dgps.removeFromList = "N"
            dgps.deleteFlag = "N"
            dgps.noticeWeek = "34"
            dgps.noticeYear = "2011"

            newItem = dgps
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let dataSource = DGPSStationCoreDataDataSource()
        InjectedValues[\.dgpsLocalDataSource] = dataSource
        XCTAssertEqual(dataSource.getCount(filters: nil), 1)
    }

    func testGetDifferentialGPSStation() {
        var newItem: DifferentialGPSStation?
        var newItem2: DifferentialGPSStation?
        persistentStore.viewContext.performAndWait {
            let dgps = DifferentialGPSStation(context: persistentStore.viewContext)
            dgps.volumeNumber = "PUB 112"
            dgps.aidType = "Differential GPS Stations"
            dgps.geopoliticalHeading = "KOREA"
            dgps.regionHeading = "region heading"
            dgps.sectionHeader = "KOREA: region heading"
            dgps.precedingNote = "preceeding note"
            dgps.featureNumber = 6
            dgps.name = "Chojin Dan Lt"
            dgps.position = "1°00'00\"N \n2°00'00.00\"E"
            dgps.latitude = 1.0
            dgps.longitude = 2.0
            dgps.stationID = "T670\nR740\nR741"
            dgps.range = 100
            dgps.frequency = 292
            dgps.transferRate = 200
            dgps.remarks = "Message types: 3, 5, 7, 9, 16."
            dgps.postNote = "post note"
            dgps.noticeNumber = 201134
            dgps.removeFromList = "N"
            dgps.deleteFlag = "N"
            dgps.noticeWeek = "34"
            dgps.noticeYear = "2011"

            newItem = dgps

            let dgps2 = DifferentialGPSStation(context: persistentStore.viewContext)
            dgps2.volumeNumber = "PUB 112"
            dgps2.aidType = "Differential GPS Stations"
            dgps2.geopoliticalHeading = "KOREA"
            dgps2.regionHeading = "region heading"
            dgps2.sectionHeader = "KOREA: region heading"
            dgps2.precedingNote = "preceeding note"
            dgps2.featureNumber = 7
            dgps2.name = "Chojin Dan Lt"
            dgps2.position = "1°00'00\"N \n2°00'00.00\"E"
            dgps2.latitude = 1.0
            dgps2.longitude = 2.0
            dgps2.stationID = "T670\nR740\nR741"
            dgps2.range = 100
            dgps2.frequency = 292
            dgps2.transferRate = 200
            dgps2.remarks = "Message types: 3, 5, 7, 9, 16."
            dgps2.postNote = "post note"
            dgps2.noticeNumber = 202234
            dgps2.removeFromList = "N"
            dgps2.deleteFlag = "N"
            dgps2.noticeWeek = "34"
            dgps2.noticeYear = "2022"

            newItem2 = dgps2
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

        let dataSource = DGPSStationCoreDataDataSource()
        InjectedValues[\.dgpsLocalDataSource] = dataSource
        let retrieved = dataSource.getDifferentialGPSStation(featureNumber: Int(newItem.featureNumber), volumeNumber: newItem.volumeNumber)
        XCTAssertEqual(retrieved?.featureNumber, Int(newItem.featureNumber))
        XCTAssertEqual(retrieved?.volumeNumber, newItem.volumeNumber)

        let retrieved2 = dataSource.getDifferentialGPSStation(featureNumber: Int(newItem2.featureNumber), volumeNumber: newItem2.volumeNumber)
        XCTAssertEqual(retrieved2?.featureNumber, Int(newItem2.featureNumber))
        XCTAssertEqual(retrieved2?.volumeNumber, newItem2.volumeNumber)

        let no = dataSource.getDifferentialGPSStation(featureNumber: Int(-1), volumeNumber: "no")
        XCTAssertNil(no)
    }

    func testGetNewestDifferentialGPSStation() {
        var newItem: DifferentialGPSStation?
        var newItem2: DifferentialGPSStation?
        persistentStore.viewContext.performAndWait {
            let dgps = DifferentialGPSStation(context: persistentStore.viewContext)
            dgps.volumeNumber = "PUB 112"
            dgps.aidType = "Differential GPS Stations"
            dgps.geopoliticalHeading = "KOREA"
            dgps.regionHeading = "region heading"
            dgps.sectionHeader = "KOREA: region heading"
            dgps.precedingNote = "preceeding note"
            dgps.featureNumber = 6
            dgps.name = "Chojin Dan Lt"
            dgps.position = "1°00'00\"N \n2°00'00.00\"E"
            dgps.latitude = 1.0
            dgps.longitude = 2.0
            dgps.stationID = "T670\nR740\nR741"
            dgps.range = 100
            dgps.frequency = 292
            dgps.transferRate = 200
            dgps.remarks = "Message types: 3, 5, 7, 9, 16."
            dgps.postNote = "post note"
            dgps.noticeNumber = 201134
            dgps.removeFromList = "N"
            dgps.deleteFlag = "N"
            dgps.noticeWeek = "34"
            dgps.noticeYear = "2011"

            newItem = dgps

            let dgps2 = DifferentialGPSStation(context: persistentStore.viewContext)
            dgps2.volumeNumber = "PUB 112"
            dgps2.aidType = "Differential GPS Stations"
            dgps2.geopoliticalHeading = "KOREA"
            dgps2.regionHeading = "region heading"
            dgps2.sectionHeader = "KOREA: region heading"
            dgps2.precedingNote = "preceeding note"
            dgps2.featureNumber = 7
            dgps2.name = "Chojin Dan Lt"
            dgps2.position = "1°00'00\"N \n2°00'00.00\"E"
            dgps2.latitude = 1.0
            dgps2.longitude = 2.0
            dgps2.stationID = "T670\nR740\nR741"
            dgps2.range = 100
            dgps2.frequency = 292
            dgps2.transferRate = 200
            dgps2.remarks = "Message types: 3, 5, 7, 9, 16."
            dgps2.postNote = "post note"
            dgps2.noticeNumber = 202034
            dgps2.removeFromList = "N"
            dgps2.deleteFlag = "N"
            dgps2.noticeWeek = "34"
            dgps2.noticeYear = "2020"

            newItem2 = dgps2
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

        let dataSource = DGPSStationCoreDataDataSource()
        InjectedValues[\.dgpsLocalDataSource] = dataSource
        let retrieved = dataSource.getNewestDifferentialGPSStation()
        XCTAssertEqual(retrieved?.featureNumber, Int(newItem2.featureNumber))
        XCTAssertEqual(retrieved?.volumeNumber, newItem2.volumeNumber)

    }

    func testGetNewestEmpty() {
        let dataSource = DGPSStationCoreDataDataSource()

        let retrieved = dataSource.getNewestDifferentialGPSStation()
        XCTAssertNil(retrieved)
    }

    func testGetDgpsInBounds() async {
        var newItem: DGPSStationModel?
        var newItem2: DGPSStationModel?
        persistentStore.viewContext.performAndWait {
            let dgps = DifferentialGPSStation(context: persistentStore.viewContext)
            dgps.volumeNumber = "PUB 112"
            dgps.aidType = "Differential GPS Stations"
            dgps.geopoliticalHeading = "KOREA"
            dgps.regionHeading = "region heading"
            dgps.sectionHeader = "KOREA: region heading"
            dgps.precedingNote = "preceeding note"
            dgps.featureNumber = 6
            dgps.name = "Chojin Dan Lt"
            dgps.position = "1°00'00\"N \n2°00'00.00\"E"
            dgps.latitude = 1.0
            dgps.longitude = 1.0
            dgps.stationID = "T670\nR740\nR741"
            dgps.range = 100
            dgps.frequency = 292
            dgps.transferRate = 200
            dgps.remarks = "Message types: 3, 5, 7, 9, 16."
            dgps.postNote = "post note"
            dgps.noticeNumber = 201134
            dgps.removeFromList = "N"
            dgps.deleteFlag = "N"
            dgps.noticeWeek = "34"
            dgps.noticeYear = "2011"

            newItem = DGPSStationModel(differentialGPSStation: dgps)

            let dgps2 = DifferentialGPSStation(context: persistentStore.viewContext)
            dgps2.volumeNumber = "PUB 112"
            dgps2.aidType = "Differential GPS Stations"
            dgps2.geopoliticalHeading = "KOREA"
            dgps2.regionHeading = "region heading"
            dgps2.sectionHeader = "KOREA: region heading"
            dgps2.precedingNote = "preceeding note"
            dgps2.featureNumber = 7
            dgps2.name = "Chojin Dan Lt"
            dgps2.position = "1°00'00\"N \n2°00'00.00\"E"
            dgps2.latitude = 20.0
            dgps2.longitude = 20.0
            dgps2.stationID = "T670\nR740\nR741"
            dgps2.range = 100
            dgps2.frequency = 292
            dgps2.transferRate = 200
            dgps2.remarks = "Message types: 3, 5, 7, 9, 16."
            dgps2.postNote = "post note"
            dgps2.noticeNumber = 202034
            dgps2.removeFromList = "N"
            dgps2.deleteFlag = "N"
            dgps2.noticeWeek = "34"
            dgps2.noticeYear = "2020"

            newItem2 = DGPSStationModel(differentialGPSStation: dgps2)
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

        let dataSource = DGPSStationCoreDataDataSource()
        InjectedValues[\.dgpsLocalDataSource] = dataSource
        let retrieved = await dataSource.getDifferentialGPSStationsInBounds(filters: nil, minLatitude: 19, maxLatitude: 21, minLongitude: 19, maxLongitude: 21)
        XCTAssertEqual(retrieved.count, 1)
        XCTAssertEqual(retrieved[0].featureNumber, Int(exactly: newItem2.featureNumber!)!)
        XCTAssertEqual(retrieved[0].volumeNumber, newItem2.volumeNumber)
        let retrieved2 = await dataSource.getDifferentialGPSStationsInBounds(filters: nil, minLatitude: 0, maxLatitude: 2, minLongitude: 0, maxLongitude: 2)
        XCTAssertEqual(retrieved2.count, 1)
        XCTAssertEqual(retrieved2[0].featureNumber, Int(exactly: newItem.featureNumber!)!)
        XCTAssertEqual(retrieved2[0].volumeNumber, newItem.volumeNumber)
        let retrieved3 = await dataSource.getDifferentialGPSStationsInBounds(filters: nil, minLatitude: 0, maxLatitude: 21, minLongitude: 0, maxLongitude: 21)
        XCTAssertEqual(retrieved3.count, 2)
    }

    func testPublisher() async {

        UserDefaults.standard.setSort(DataSources.dgps.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Feature Number",
                    key: #keyPath(DifferentialGPSStation.featureNumber),
                    type: .int),
                ascending: true,
                section: false)
        ])

        var newItem: DifferentialGPSStation?
        persistentStore.viewContext.performAndWait {
            let dgps = DifferentialGPSStation(context: persistentStore.viewContext)
            dgps.volumeNumber = "PUB 112"
            dgps.aidType = "Differential GPS Stations"
            dgps.geopoliticalHeading = "KOREA"
            dgps.regionHeading = "region heading"
            dgps.sectionHeader = "KOREA: region heading"
            dgps.precedingNote = "preceeding note"
            dgps.featureNumber = 6
            dgps.name = "Chojin Dan Lt"
            dgps.position = "1°00'00\"N \n2°00'00.00\"E"
            dgps.latitude = 1.0
            dgps.longitude = 1.0
            dgps.stationID = "T670\nR740\nR741"
            dgps.range = 100
            dgps.frequency = 292
            dgps.transferRate = 200
            dgps.remarks = "Message types: 3, 5, 7, 9, 16."
            dgps.postNote = "post note"
            dgps.noticeNumber = 201134
            dgps.removeFromList = "N"
            dgps.deleteFlag = "N"
            dgps.noticeWeek = "34"
            dgps.noticeYear = "2011"

            newItem = dgps
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [DGPSStationItem])
            case failure(error: Error)

            fileprivate var rows: [DGPSStationItem] {
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
        let dataSource = DGPSStationCoreDataDataSource()
        InjectedValues[\.dgpsLocalDataSource] = dataSource
        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.dgps(
                filters: UserDefaults.standard.filter(DataSources.dgps),
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
        var newItem2: DifferentialGPSStation?
        persistentStore.viewContext.performAndWait {
            let dgps2 = DifferentialGPSStation(context: persistentStore.viewContext)
            dgps2.volumeNumber = "PUB 112"
            dgps2.aidType = "Differential GPS Stations"
            dgps2.geopoliticalHeading = "KOREA"
            dgps2.regionHeading = "region heading"
            dgps2.sectionHeader = "KOREA: region heading"
            dgps2.precedingNote = "preceeding note"
            dgps2.featureNumber = 7
            dgps2.name = "Chojin Dan Lt"
            dgps2.position = "1°00'00\"N \n2°00'00.00\"E"
            dgps2.latitude = 20.0
            dgps2.longitude = 20.0
            dgps2.stationID = "T670\nR740\nR741"
            dgps2.range = 100
            dgps2.frequency = 292
            dgps2.transferRate = 200
            dgps2.remarks = "Message types: 3, 5, 7, 9, 16."
            dgps2.postNote = "post note"
            dgps2.noticeNumber = 202034
            dgps2.removeFromList = "N"
            dgps2.deleteFlag = "N"
            dgps2.noticeWeek = "34"
            dgps2.noticeYear = "2020"

            newItem2 = dgps2
            try? persistentStore.viewContext.save()
        }
        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 2)

        await fulfillment(of: [expecation2], timeout: 5)
    }

    func testPublisherWithSectionHeader() async {
        UserDefaults.standard.setSort(DataSources.dgps.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Feature Number",
                    key: #keyPath(DifferentialGPSStation.featureNumber),
                    type: .int),
                ascending: false,
                section: true)
        ])

        var newItem: DifferentialGPSStation?
        persistentStore.viewContext.performAndWait {
            let dgps = DifferentialGPSStation(context: persistentStore.viewContext)
            dgps.volumeNumber = "PUB 112"
            dgps.aidType = "Differential GPS Stations"
            dgps.geopoliticalHeading = "KOREA"
            dgps.regionHeading = "region heading"
            dgps.sectionHeader = "KOREA: region heading"
            dgps.precedingNote = "preceeding note"
            dgps.featureNumber = 6
            dgps.name = "Chojin Dan Lt"
            dgps.position = "1°00'00\"N \n2°00'00.00\"E"
            dgps.latitude = 1.0
            dgps.longitude = 1.0
            dgps.stationID = "T670\nR740\nR741"
            dgps.range = 100
            dgps.frequency = 292
            dgps.transferRate = 200
            dgps.remarks = "Message types: 3, 5, 7, 9, 16."
            dgps.postNote = "post note"
            dgps.noticeNumber = 201134
            dgps.removeFromList = "N"
            dgps.deleteFlag = "N"
            dgps.noticeWeek = "34"
            dgps.noticeYear = "2011"

            newItem = dgps
            try? persistentStore.viewContext.save()
        }
        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [DGPSStationItem])
            case failure(error: Error)

            fileprivate var rows: [DGPSStationItem] {
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
        let dataSource = DGPSStationCoreDataDataSource()
        InjectedValues[\.dgpsLocalDataSource] = dataSource
        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.dgps(
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

        await fulfillment(of: [expecation1])

        let item = state.rows[0]
        switch item {
        case .listItem(_):
            XCTFail()
        case .sectionHeader(let header):
            XCTAssertEqual(header, "6")
        }
        let item1 = state.rows[1]
        switch item1 {
        case .listItem(let dgps):
            XCTAssertEqual(dgps.featureNumber, 6)
        case .sectionHeader(_):
            XCTFail()
        }

        NSLog("Insert a new one")
        var newItem2: DifferentialGPSStation?
        persistentStore.viewContext.performAndWait {
            let dgps2 = DifferentialGPSStation(context: persistentStore.viewContext)
            dgps2.volumeNumber = "PUB 112"
            dgps2.aidType = "Differential GPS Stations"
            dgps2.geopoliticalHeading = "KOREA"
            dgps2.regionHeading = "region heading"
            dgps2.sectionHeader = "KOREA: region heading"
            dgps2.precedingNote = "preceeding note"
            dgps2.featureNumber = 7
            dgps2.name = "Chojin Dan Lt"
            dgps2.position = "1°00'00\"N \n2°00'00.00\"E"
            dgps2.latitude = 20.0
            dgps2.longitude = 20.0
            dgps2.stationID = "T670\nR740\nR741"
            dgps2.range = 100
            dgps2.frequency = 292
            dgps2.transferRate = 200
            dgps2.remarks = "Message types: 3, 5, 7, 9, 16."
            dgps2.postNote = "post note"
            dgps2.noticeNumber = 202034
            dgps2.removeFromList = "N"
            dgps2.deleteFlag = "N"
            dgps2.noticeWeek = "34"
            dgps2.noticeYear = "2020"

            newItem2 = dgps2
            try? persistentStore.viewContext.save()
        }
        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 4)

        await fulfillment(of: [expecation2])

        let itema = state.rows[0]
        switch itema {
        case .listItem(_):
            XCTFail()
        case .sectionHeader(let header):
            XCTAssertEqual(header, "7")
        }
        let itema1 = state.rows[1]
        switch itema1 {
        case .listItem(let dgps):
            XCTAssertEqual(dgps.featureNumber, 7)
        case .sectionHeader(_):
            XCTFail()
        }
        let itema2 = state.rows[2]
        switch itema2 {
        case .listItem(_):
            XCTFail()
        case .sectionHeader(let header):
            XCTAssertEqual(header, "6")
        }
        let itema3 = state.rows[3]
        switch itema3 {
        case .listItem(let dgps):
            XCTAssertEqual(dgps.featureNumber, 6)
        case .sectionHeader(_):
            XCTFail()
        }
    }

    func testInsert() async {
        var dgps = DGPSStationModel()
        dgps.volumeNumber = "PUB 112"
        dgps.aidType = "Differential GPS Stations"
        dgps.geopoliticalHeading = "KOREA"
        dgps.regionHeading = "region heading"
        dgps.sectionHeader = "KOREA: region heading"
        dgps.precedingNote = "preceeding note"
        dgps.featureNumber = 6
        dgps.name = "Chojin Dan Lt"
        dgps.position = "1°00'00\"N \n2°00'00.00\"E"
        dgps.latitude = 1.0
        dgps.longitude = 1.0
        dgps.stationID = "T670\nR740\nR741"
        dgps.range = 100
        dgps.frequency = 292
        dgps.transferRate = 200
        dgps.remarks = "Message types: 3, 5, 7, 9, 16."
        dgps.postNote = "post note"
        dgps.noticeNumber = 201134
        dgps.removeFromList = "N"
        dgps.deleteFlag = "N"
        dgps.noticeWeek = "34"
        dgps.noticeYear = "2011"

        let dataSource = DGPSStationCoreDataDataSource()
        InjectedValues[\.dgpsLocalDataSource] = dataSource
        
        let inserted = await dataSource.insert(dgpss: [dgps])
        XCTAssertEqual(1, inserted)

        let retrieved = dataSource.getDifferentialGPSStation(featureNumber: dgps.featureNumber, volumeNumber: dgps.volumeNumber)
        XCTAssertEqual(retrieved?.featureNumber, dgps.featureNumber)
        XCTAssertEqual(retrieved?.volumeNumber, dgps.volumeNumber)
    }

    func testGetAsams() async {
        var dgps = DGPSStationModel()
        dgps.volumeNumber = "PUB 112"
        dgps.aidType = "Differential GPS Stations"
        dgps.geopoliticalHeading = "KOREA"
        dgps.regionHeading = "region heading"
        dgps.sectionHeader = "KOREA: region heading"
        dgps.precedingNote = "preceeding note"
        dgps.featureNumber = 6
        dgps.name = "Chojin Dan Lt"
        dgps.position = "1°00'00\"N \n2°00'00.00\"E"
        dgps.latitude = 1.0
        dgps.longitude = 1.0
        dgps.stationID = "T670\nR740\nR741"
        dgps.range = 100
        dgps.frequency = 292
        dgps.transferRate = 200
        dgps.remarks = "Message types: 3, 5, 7, 9, 16."
        dgps.postNote = "post note"
        dgps.noticeNumber = 201134
        dgps.removeFromList = "N"
        dgps.deleteFlag = "N"
        dgps.noticeWeek = "34"
        dgps.noticeYear = "2011"

        let dataSource = DGPSStationCoreDataDataSource()
        InjectedValues[\.dgpsLocalDataSource] = dataSource

        let inserted = await dataSource.insert(dgpss: [dgps])
        XCTAssertEqual(1, inserted)

        let retrieved = await dataSource.getDifferentialGPSStations(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "featureNumber", key: "featureNumber", type: .int), comparison: DataSourceFilterComparison.equals, valueInt: dgps.featureNumber)])
        print("retrieved \(retrieved)")
        XCTAssertEqual(1, retrieved.count)
        XCTAssertEqual(retrieved[0].featureNumber, dgps.featureNumber)
        XCTAssertEqual(retrieved[0].volumeNumber, dgps.volumeNumber)

        let retrievedNone = await dataSource.getDifferentialGPSStations(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "featureNumber", key: "featureNumber", type: .int), comparison: DataSourceFilterComparison.equals, valueInt: -9)])
        XCTAssertEqual(0, retrievedNone.count)
    }

}
