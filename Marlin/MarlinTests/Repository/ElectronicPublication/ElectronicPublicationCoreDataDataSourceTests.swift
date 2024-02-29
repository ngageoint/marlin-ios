//
//  ElectronicPublicationCoreDataDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation
import Combine
import CoreData

@testable import Marlin

final class ElectronicPublicationCoreDataDataSourceTests: XCTestCase {

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
        UserDefaults.standard.setSort(DataSources.epub.key, sort: DataSources.epub.filterable!.defaultSort)
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.epub)
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
        var newItem: ElectronicPublication?
        persistentStore.viewContext.performAndWait {
            let epub = ElectronicPublication(context: persistentStore.viewContext)

            epub.pubTypeId = 9
            epub.pubDownloadId = 3
            epub.fullPubFlag = false
            epub.pubDownloadOrder = 1
            epub.pubDownloadDisplayName = "Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
            epub.pubsecId = 129
            epub.odsEntryId = 22266
            epub.sectionOrder = 1
            epub.sectionName = "UpdatedPub110bk"
            epub.sectionDisplayName = "Pub 110 - Updated to NTM 44/22"
            epub.sectionLastModified = Date(timeIntervalSince1970: 0)
            epub.contentId = 16694312
            epub.internalPath = "NIMA_LOL/Pub110"
            epub.filenameBase = "UpdatedPub110bk"
            epub.fileExtension = "pdf"
            epub.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf"
            epub.fileSize = 2389496
            epub.uploadTime = Date(timeIntervalSince1970: 0)
            epub.fullFilename = "UpdatedPub110bk.pdf"
            epub.pubsecLastModified = Date(timeIntervalSince1970: 0)
            epub.isDownloaded = false
            epub.isDownloading = true
            newItem = epub
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let dataSource = PublicationCoreDataDataSource()

        XCTAssertEqual(dataSource.getCount(filters: nil), 1)
    }

    func testGetElectronicPublication() {
        var newItem: ElectronicPublication?
        var newItem2: ElectronicPublication?
        persistentStore.viewContext.performAndWait {
            let epub = ElectronicPublication(context: persistentStore.viewContext)

            epub.pubTypeId = 9
            epub.pubDownloadId = 3
            epub.fullPubFlag = false
            epub.pubDownloadOrder = 1
            epub.pubDownloadDisplayName = "Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
            epub.pubsecId = 129
            epub.odsEntryId = 22266
            epub.sectionOrder = 1
            epub.sectionName = "UpdatedPub110bk"
            epub.sectionDisplayName = "Pub 110 - Updated to NTM 44/22"
            epub.sectionLastModified = Date(timeIntervalSince1970: 0)
            epub.contentId = 16694312
            epub.internalPath = "NIMA_LOL/Pub110"
            epub.filenameBase = "UpdatedPub110bk"
            epub.fileExtension = "pdf"
            epub.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf"
            epub.fileSize = 2389496
            epub.uploadTime = Date(timeIntervalSince1970: 0)
            epub.fullFilename = "UpdatedPub110bk.pdf"
            epub.pubsecLastModified = Date(timeIntervalSince1970: 0)
            epub.isDownloaded = false
            epub.isDownloading = true
            newItem = epub

            let epub2 = ElectronicPublication(context: persistentStore.viewContext)

            epub2.pubTypeId = 9
            epub2.pubDownloadId = 4
            epub2.fullPubFlag = false
            epub2.pubDownloadOrder = 1
            epub2.pubDownloadDisplayName = "2Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
            epub2.pubsecId = 122
            epub2.odsEntryId = 22267
            epub2.sectionOrder = 1
            epub2.sectionName = "2UpdatedPub110bk"
            epub2.sectionDisplayName = "Pub 110 - 2Updated to NTM 44/22"
            epub2.sectionLastModified = Date(timeIntervalSince1970: 0)
            epub2.contentId = 16694312
            epub2.internalPath = "NIMA_LOL/Pub110"
            epub2.filenameBase = "2UpdatedPub110bk"
            epub2.fileExtension = "pdf"
            epub2.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/2UpdatedPub110bk.pdf"
            epub2.fileSize = 2389496
            epub2.uploadTime = Date(timeIntervalSince1970: 0)
            epub2.fullFilename = "2UpdatedPub110bk.pdf"
            epub2.pubsecLastModified = Date(timeIntervalSince1970: 0)
            epub2.isDownloaded = false
            epub2.isDownloading = true
            newItem2 = epub2
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

        let dataSource = PublicationCoreDataDataSource()

        let retrieved = dataSource.getPublication(s3Key: newItem.s3Key)
        XCTAssertEqual(retrieved?.s3Key, newItem.s3Key)

        let retrieved2 = dataSource.getPublication(s3Key: newItem2.s3Key)
        XCTAssertEqual(retrieved2?.s3Key, newItem2.s3Key)

        let no = dataSource.getPublication(s3Key: "Nope")
        XCTAssertNil(no)
    }

    func testPublisher() async {
        UserDefaults.standard.setSort(DataSources.epub.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Section Name",
                    key: #keyPath(ElectronicPublication.sectionName),
                    type: .string),
                ascending: false,
                section: false)
        ])

        var newItem: ElectronicPublication?
        persistentStore.viewContext.performAndWait {
            let epub = ElectronicPublication(context: persistentStore.viewContext)

            epub.pubTypeId = 9
            epub.pubDownloadId = 3
            epub.fullPubFlag = false
            epub.pubDownloadOrder = 1
            epub.pubDownloadDisplayName = "Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
            epub.pubsecId = 129
            epub.odsEntryId = 22266
            epub.sectionOrder = 1
            epub.sectionName = "UpdatedPub110bk"
            epub.sectionDisplayName = "Pub 110 - Updated to NTM 44/22"
            epub.sectionLastModified = Date(timeIntervalSince1970: 0)
            epub.contentId = 16694312
            epub.internalPath = "NIMA_LOL/Pub110"
            epub.filenameBase = "UpdatedPub110bk"
            epub.fileExtension = "pdf"
            epub.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf"
            epub.fileSize = 2389496
            epub.uploadTime = Date(timeIntervalSince1970: 0)
            epub.fullFilename = "UpdatedPub110bk.pdf"
            epub.pubsecLastModified = Date(timeIntervalSince1970: 0)
            epub.isDownloaded = false
            epub.isDownloading = true
            newItem = epub
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [PublicationItem])
            case failure(error: Error)

            fileprivate var rows: [PublicationItem] {
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
        let dataSource = PublicationCoreDataDataSource()

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.pubs(
                filters: UserDefaults.standard.filter(DataSources.epub),
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

        let itema = state.rows[0]
        switch itema {
        case .listItem(let epub):
            XCTAssertEqual(epub.s3Key, "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf")
        default:
            XCTFail()
        }

        NSLog("Insert a new one")
        var newItem2: ElectronicPublication?
        persistentStore.viewContext.performAndWait {
            let epub2 = ElectronicPublication(context: persistentStore.viewContext)

            epub2.pubTypeId = 9
            epub2.pubDownloadId = 4
            epub2.fullPubFlag = false
            epub2.pubDownloadOrder = 1
            epub2.pubDownloadDisplayName = "2Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
            epub2.pubsecId = 122
            epub2.odsEntryId = 22267
            epub2.sectionOrder = 1
            epub2.sectionName = "2UpdatedPub110bk"
            epub2.sectionDisplayName = "Pub 110 - 2Updated to NTM 44/22"
            epub2.sectionLastModified = Date(timeIntervalSince1970: 0)
            epub2.contentId = 16694312
            epub2.internalPath = "NIMA_LOL/Pub110"
            epub2.filenameBase = "2UpdatedPub110bk"
            epub2.fileExtension = "pdf"
            epub2.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/2UpdatedPub110bk.pdf"
            epub2.fileSize = 2389496
            epub2.uploadTime = Date(timeIntervalSince1970: 0)
            epub2.fullFilename = "2UpdatedPub110bk.pdf"
            epub2.pubsecLastModified = Date(timeIntervalSince1970: 0)
            epub2.isDownloaded = false
            epub2.isDownloading = true
            newItem2 = epub2
            try? persistentStore.viewContext.save()
        }
        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 2)

        await fulfillment(of: [expecation2], timeout: 5)

        let itema1 = state.rows[0]
        switch itema1 {
        case .listItem(let epub):
            XCTAssertEqual(epub.s3Key, "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf")
        default:
            XCTFail()
        }
        let item1 = state.rows[1]
        switch item1 {
        case .listItem(let epub):
            XCTAssertEqual(epub.s3Key, "16694312/SFH00000/NIMA_LOL/Pub110/2UpdatedPub110bk.pdf")
        default:
            XCTFail()
        }
    }

    func testPublisherWithSectionHeader() async {
        UserDefaults.standard.setSort(DataSources.epub.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Section Display Name",
                    key: #keyPath(ElectronicPublication.sectionDisplayName),
                    type: .string),
                ascending: false,
                section: true)
        ])

        
        var newItem: ElectronicPublication?
        persistentStore.viewContext.performAndWait {
            let epub = ElectronicPublication(context: persistentStore.viewContext)

            epub.pubTypeId = 9
            epub.pubDownloadId = 3
            epub.fullPubFlag = false
            epub.pubDownloadOrder = 1
            epub.pubDownloadDisplayName = "Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
            epub.pubsecId = 129
            epub.odsEntryId = 22266
            epub.sectionOrder = 1
            epub.sectionName = "UpdatedPub110bk"
            epub.sectionDisplayName = "Pub 110 - Updated to NTM 44/22"
            epub.sectionLastModified = Date(timeIntervalSince1970: 0)
            epub.contentId = 16694312
            epub.internalPath = "NIMA_LOL/Pub110"
            epub.filenameBase = "UpdatedPub110bk"
            epub.fileExtension = "pdf"
            epub.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf"
            epub.fileSize = 2389496
            epub.uploadTime = Date(timeIntervalSince1970: 0)
            epub.fullFilename = "UpdatedPub110bk.pdf"
            epub.pubsecLastModified = Date(timeIntervalSince1970: 0)
            epub.isDownloaded = false
            epub.isDownloading = true
            newItem = epub
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [PublicationItem])
            case failure(error: Error)

            fileprivate var rows: [PublicationItem] {
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
        let dataSource = PublicationCoreDataDataSource()

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.pubs(
                filters: UserDefaults.standard.filter(DataSources.epub),
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
        case .sectionHeader(let header):
            XCTAssertEqual(header, "Pub 110 - Updated to NTM 44/22")
        default:
            XCTFail()
        }
        let item1 = state.rows[1]
        switch item1 {
        case .listItem(let epub):
            XCTAssertEqual(epub.s3Key, "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf")
        default:
            XCTFail()
        }

        NSLog("Insert a new one")
        var newItem2: ElectronicPublication?
        persistentStore.viewContext.performAndWait {
            let epub2 = ElectronicPublication(context: persistentStore.viewContext)

            epub2.pubTypeId = 9
            epub2.pubDownloadId = 4
            epub2.fullPubFlag = false
            epub2.pubDownloadOrder = 1
            epub2.pubDownloadDisplayName = "2Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
            epub2.pubsecId = 122
            epub2.odsEntryId = 22267
            epub2.sectionOrder = 1
            epub2.sectionName = "2UpdatedPub110bk"
            epub2.sectionDisplayName = "Pub 110 - 2Updated to NTM 44/22"
            epub2.sectionLastModified = Date(timeIntervalSince1970: 0)
            epub2.contentId = 16694312
            epub2.internalPath = "NIMA_LOL/Pub110"
            epub2.filenameBase = "2UpdatedPub110bk"
            epub2.fileExtension = "pdf"
            epub2.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/2UpdatedPub110bk.pdf"
            epub2.fileSize = 2389496
            epub2.uploadTime = Date(timeIntervalSince1970: 0)
            epub2.fullFilename = "2UpdatedPub110bk.pdf"
            epub2.pubsecLastModified = Date(timeIntervalSince1970: 0)
            epub2.isDownloaded = false
            epub2.isDownloading = true
            newItem2 = epub2
            try? persistentStore.viewContext.save()
        }
        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 4)

        await fulfillment(of: [expecation2], timeout: 5)

        let itema = state.rows[0]
        switch itema {
        case .sectionHeader(let header):
            XCTAssertEqual(header, "Pub 110 - Updated to NTM 44/22")
        default:
            XCTFail()
        }
        let itema1 = state.rows[1]
        switch itema1 {
        case .listItem(let epub):
            XCTAssertEqual(epub.s3Key, "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf")
        default:
            XCTFail()
        }
        let itema2 = state.rows[2]
        switch itema2 {
        case .sectionHeader(let header):
            XCTAssertEqual(header, "Pub 110 - 2Updated to NTM 44/22")
        default:
            XCTFail()
        }
        let itema3 = state.rows[3]
        switch itema3 {
        case .listItem(let epub):
            XCTAssertEqual(epub.s3Key, "16694312/SFH00000/NIMA_LOL/Pub110/2UpdatedPub110bk.pdf")
        default:
            XCTFail()
        }
    }

    func testSectionHeadersPublisher() async {
        var newItem: ElectronicPublication?
        persistentStore.viewContext.performAndWait {
            let epub = ElectronicPublication(context: persistentStore.viewContext)

            epub.pubTypeId = 9
            epub.pubDownloadId = 3
            epub.fullPubFlag = false
            epub.pubDownloadOrder = 1
            epub.pubDownloadDisplayName = "Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
            epub.pubsecId = 129
            epub.odsEntryId = 22266
            epub.sectionOrder = 1
            epub.sectionName = "UpdatedPub110bk"
            epub.sectionDisplayName = "Pub 110 - Updated to NTM 44/22"
            epub.sectionLastModified = Date(timeIntervalSince1970: 0)
            epub.contentId = 16694312
            epub.internalPath = "NIMA_LOL/Pub110"
            epub.filenameBase = "UpdatedPub110bk"
            epub.fileExtension = "pdf"
            epub.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf"
            epub.fileSize = 2389496
            epub.uploadTime = Date(timeIntervalSince1970: 0)
            epub.fullFilename = "UpdatedPub110bk.pdf"
            epub.pubsecLastModified = Date(timeIntervalSince1970: 0)
            epub.isDownloaded = false
            epub.isDownloading = true
            newItem = epub
            try? persistentStore.viewContext.save()
        }

        var disposables = Set<AnyCancellable>()
        enum State {
            case loading
            case loaded(rows: [PublicationItem])
            case failure(error: Error)

            fileprivate var rows: [PublicationItem] {
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
        let dataSource = PublicationCoreDataDataSource()

        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, dataSource] in
            dataSource.sectionHeaders(
                filters: UserDefaults.standard.filter(DataSources.epub),
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

        let item = state.rows[0]
        switch item {
        case .pubType(type: let type, count: let count):
            XCTAssertEqual(type, PublicationTypeEnum.listOfLights)
        default:
            XCTFail()
        }

        NSLog("Insert a new one")
        var newItem2: ElectronicPublication?
        persistentStore.viewContext.performAndWait {
            let epub2 = ElectronicPublication(context: persistentStore.viewContext)

            epub2.pubTypeId = 10
            epub2.pubDownloadId = 4
            epub2.fullPubFlag = false
            epub2.pubDownloadOrder = 1
            epub2.pubDownloadDisplayName = "2Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
            epub2.pubsecId = 122
            epub2.odsEntryId = 22267
            epub2.sectionOrder = 1
            epub2.sectionName = "2UpdatedPub110bk"
            epub2.sectionDisplayName = "Pub 110 - 2Updated to NTM 44/22"
            epub2.sectionLastModified = Date(timeIntervalSince1970: 0)
            epub2.contentId = 16694312
            epub2.internalPath = "NIMA_LOL/Pub110"
            epub2.filenameBase = "2UpdatedPub110bk"
            epub2.fileExtension = "pdf"
            epub2.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/2UpdatedPub110bk.pdf"
            epub2.fileSize = 2389496
            epub2.uploadTime = Date(timeIntervalSince1970: 0)
            epub2.fullFilename = "2UpdatedPub110bk.pdf"
            epub2.pubsecLastModified = Date(timeIntervalSince1970: 0)
            epub2.isDownloaded = false
            epub2.isDownloading = true
            newItem2 = epub2
            try? persistentStore.viewContext.save()
        }
        trigger.activate(for: TriggerId.reload)
        let expecation2 = expectation(for: state.rows.count == 2)

        await fulfillment(of: [expecation2], timeout: 5)

        let itema = state.rows[0]
        switch itema {
        case .pubType(type: let type, count: let count):
            XCTAssertEqual(type, PublicationTypeEnum.listOfLights)
        default:
            XCTFail()
        }
        let itema2 = state.rows[1]
        switch itema2 {
        case .pubType(type: let type, count: let count):
            XCTAssertEqual(type, PublicationTypeEnum.radarNavigationAndManeuveringBoardManual)
        default:
            XCTFail()
        }
    }

    func testInsert() async {
        var epub = PublicationModel()

        epub.pubTypeId = 9
        epub.pubDownloadId = 3
        epub.fullPubFlag = false
        epub.pubDownloadOrder = 1
        epub.pubDownloadDisplayName = "Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
        epub.pubsecId = 129
        epub.odsEntryId = 22266
        epub.sectionOrder = 1
        epub.sectionName = "UpdatedPub110bk"
        epub.sectionDisplayName = "Pub 110 - Updated to NTM 44/22"
        epub.sectionLastModified = Date(timeIntervalSince1970: 0)
        epub.contentId = 16694312
        epub.internalPath = "NIMA_LOL/Pub110"
        epub.filenameBase = "UpdatedPub110bk"
        epub.fileExtension = "pdf"
        epub.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf"
        epub.fileSize = 2389496
        epub.uploadTime = Date(timeIntervalSince1970: 0)
        epub.fullFilename = "UpdatedPub110bk.pdf"
        epub.pubsecLastModified = Date(timeIntervalSince1970: 0)
        epub.isDownloaded = false
        epub.isDownloading = true

        let dataSource = PublicationCoreDataDataSource()

        let inserted = await dataSource.insert(epubs: [epub])
        XCTAssertEqual(1, inserted)

        let retrieved = dataSource.getPublication(s3Key: "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf")
        XCTAssertEqual(retrieved?.s3Key, epub.s3Key)
    }

    func testObserveElectronicPublication() async {
        var epub = PublicationModel()

        epub.pubTypeId = 9
        epub.pubDownloadId = 3
        epub.fullPubFlag = false
        epub.pubDownloadOrder = 1
        epub.pubDownloadDisplayName = "Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
        epub.pubsecId = 129
        epub.odsEntryId = 22266
        epub.sectionOrder = 1
        epub.sectionName = "UpdatedPub110bk"
        epub.sectionDisplayName = "Pub 110 - Updated to NTM 44/22"
        epub.sectionLastModified = Date(timeIntervalSince1970: 0)
        epub.contentId = 16694312
        epub.internalPath = "NIMA_LOL/Pub110"
        epub.filenameBase = "UpdatedPub110bk"
        epub.fileExtension = "pdf"
        epub.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf"
        epub.fileSize = 2389496
        epub.uploadTime = Date(timeIntervalSince1970: 0)
        epub.fullFilename = "UpdatedPub110bk.pdf"
        epub.pubsecLastModified = Date(timeIntervalSince1970: 0)
        epub.isDownloaded = false
        epub.isDownloading = false

        let dataSource = PublicationCoreDataDataSource()
        let inserted = await dataSource.insert(epubs: [epub])
        XCTAssertEqual(1, inserted)

        var disposables = Set<AnyCancellable>()

        dataSource.observePublication(s3Key: "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf")?
            .sink(receiveValue: { updatedObject in
                epub = updatedObject
            })
            .store(in: &disposables)

        persistentStore.viewContext.performAndWait {
            var fetched: ElectronicPublication? = persistentStore.viewContext.fetchFirst(ElectronicPublication.self, key: "s3Key", value: "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf")
            fetched?.isDownloading = true
            fetched?.downloadProgress = 0.5
            do {
                try persistentStore.viewContext.save()
            } catch {
                NSLog("Error updating \(error)")
            }
        }

        persistentStore.viewContext.performAndWait {
            var fetched: ElectronicPublication? = persistentStore.viewContext.fetchFirst(ElectronicPublication.self, key: "s3Key", value: "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf")
            fetched?.isDownloading = true
            fetched?.downloadProgress = 0.9
            do {
                try persistentStore.viewContext.save()
            } catch {
                NSLog("Error updating \(error)")
            }
        }

        print("disposables is \(disposables)")

        let expectation1 = expectation(for: epub.isDownloading == true)
        let expectation2 = expectation(for: epub.downloadProgress == 0.9)

        await fulfillment(of: [expectation1, expectation2], timeout: 5)
    }
}
