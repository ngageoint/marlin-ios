//
//  ElectronicPublicationListTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/13/23.
//

import XCTest
import Combine
import SwiftUI
import OHHTTPStubs

@testable import Marlin

final class ElectronicPublicationListTests: XCTestCase {
    
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()

        for dataSource in DataSourceDefinitions.allCases {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(dataSource.definition)
        }
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        
        UserDefaults.standard.setFilter(DataSources.epub.key, filter: [])
        UserDefaults.standard.setSort(DataSources.epub.key, sort: DataSources.epub.defaultSort)

        persistentStore.viewContext.performAndWait {
            if let epubs = persistentStore.viewContext.fetchAll(ElectronicPublication.self) {
                for epub in epubs {
                    persistentStore.viewContext.delete(epub)
                }
            }
        }
        
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                let e5 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
                    if let count = try? self.persistentStore.countOfObjects(ElectronicPublication.self) {
                        return count == 0
                    }
                    return false
                }), object: self.persistentStore.viewContext)
                self.wait(for: [e5], timeout: 10)
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
        
    }
    override func tearDown(completion: @escaping (Error?) -> Void) {
        persistentStore.viewContext.performAndWait {
            if let epubs = persistentStore.viewContext.fetchAll(ElectronicPublication.self) {
                for epub in epubs {
                    persistentStore.viewContext.delete(epub)
                }
            }
        }
        completion(nil)
    }
    
    func testOneSectionList() throws {
//        XCTFail()
        stub(condition: isScheme("https") && pathEndsWith("/publications/stored-pubs")) { request in
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("fullEpubList.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"]
            )
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

//        MSI.shared.loadData(type: ElectronicPublication.decodableRoot, dataType: ElectronicPublication.self)

        let bundle = MockBundle()
        bundle.mockPath = "fullEpubList.json"

        let localDataSource = ElectronicPublicationCoreDataDataSource()
        let operation = ElectronicPublicationInitialDataLoadOperation(localDataSource: localDataSource, bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationView {
                    ElectronicPublicationsSectionList()
                }
            }
        }
        let passThrough = PassThrough()
        let repository = ElectronicPublicationRepository(localDataSource: localDataSource, remoteDataSource: ElectronicPublicationRemoteDataSource())
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(electronicPublicationRepository: repository))

        let container = Container(passThrough: passThrough)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environment(\.managedObjectContext, persistentStore.viewContext)

        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        for publicationType in PublicationTypeEnum.allCases {
            if publicationType != .fleetGuides && publicationType != .unknown {
                tester().waitForView(withAccessibilityLabel: publicationType.description)
                tester().tapView(withAccessibilityLabel: publicationType.description)
                if publicationType == .atlasOfPilotCharts {
                    tester().waitForView(withAccessibilityLabel: "Pub. 109 - Atlas of Pilot Charts Indian Ocean, 4th Ed. 2001")
                    tester().tapView(withAccessibilityLabel: "Pub. 109 - Atlas of Pilot Charts Indian Ocean, 4th Ed. 2001")
                    tester().waitForView(withAccessibilityLabel: "Back")
                    tester().tapView(withAccessibilityLabel: "Back")
                } else if publicationType == .listOfLights {
                    tester().waitForView(withAccessibilityLabel: "Pub. 116 - Baltic Sea with Kattegat, Belts and Sound and Gulf of Bothnia")
                    tester().tapView(withAccessibilityLabel: "Pub. 116 - Baltic Sea with Kattegat, Belts and Sound and Gulf of Bothnia")
                    tester().waitForView(withAccessibilityLabel: "Back")
                    tester().tapView(withAccessibilityLabel: "Back")
                } else if publicationType == .sightReductionTablesForMarineNavigation {
                    tester().waitForView(withAccessibilityLabel: "Volume 1 - Latitudes 0°-15°, Inclusive")
                    tester().tapView(withAccessibilityLabel: "Volume 1 - Latitudes 0°-15°, Inclusive")
                    tester().waitForView(withAccessibilityLabel: "Back")
                    tester().tapView(withAccessibilityLabel: "Back")
                }
                tester().waitForView(withAccessibilityLabel: "Back")
                tester().tapView(withAccessibilityLabel: "Back")
            }
        }
    }

}
