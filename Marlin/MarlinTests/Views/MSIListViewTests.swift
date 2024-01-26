//
//  MSIListViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/2/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class MSIListViewTests: XCTestCase {

    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource.definition)
        }
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        
        UserDefaults.standard.setFilter(Modu.key, filter: [])
        UserDefaults.standard.setSort(Modu.key, sort: Modu.defaultSort)

        persistentStore.viewContext.performAndWait {
            if let modus = persistentStore.viewContext.fetchAll(Modu.self) {
                for modu in modus {
                    persistentStore.viewContext.delete(modu)
                }
            }
        }
        
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                let e5 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
                    if let count = try? self.persistentStore.countOfObjects(Modu.self) {
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
            if let modus = persistentStore.viewContext.fetchAll(Modu.self) {
                for modu in modus {
                    persistentStore.viewContext.delete(modu)
                }
            }
        }
        completion(nil)
    }

    func testOneSectionList() throws {
        UserDefaults.standard.setSort(Modu.key, sort: [])
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

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 0)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 1.0
            modu2.longitude = 2.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63

            try? persistentStore.viewContext.save()
        }

        class PassThrough: ObservableObject {

        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var router: MarlinRouter = MarlinRouter()
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    MSIListView<Modu, EmptyView, EmptyView, EmptyView>()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let repository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForView(withAccessibilityLabel: "ABAN II2")
    }
    
    func testZeroItemList() throws {
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    MSIListView<Modu, EmptyView, EmptyView, EmptyView>()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Modu.fullDataSourceName)
    }

    func testAddItemsList() throws {
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    MSIListView<Modu, EmptyView, EmptyView, EmptyView>()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let repository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))

        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Modu.fullDataSourceName)

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

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 0)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 1.0
            modu2.longitude = 2.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63

            try? persistentStore.viewContext.save()
        }

        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForView(withAccessibilityLabel: "ABAN II2")
    }

    func testAddItemsListWithSectionKey() throws {

        UserDefaults.standard.setSort(Modu.key, sort: [DataSourceSortParameter(property:DataSourceProperty(name: "Nav Area", key: #keyPath(Modu.navArea), type: .string), ascending: false, section: true)])
        UserDefaults.standard.setFilter(Modu.key, filter: [])

        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    MSIListView<Modu, EmptyView, EmptyView, EmptyView>()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let repository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))

        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Modu.fullDataSourceName)

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

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 0)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 1.0
            modu2.longitude = 2.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63

            try? persistentStore.viewContext.save()
        }

        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForView(withAccessibilityLabel: "ABAN II2")

        // these are no longer accessibility elements as of Xcode 14.3
//        tester().waitForView(withAccessibilityLabel: "Boarding2")
//        tester().waitForView(withAccessibilityLabel: "Boarding")
    }

    func testFilteredList() throws {

        UserDefaults.standard.setSort(Modu.key, sort: Modu.defaultSort)
        UserDefaults.standard.setFilter(Modu.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: #keyPath(Modu.date), type: .date), comparison: .window, windowUnits: DataSourceWindowUnits.last30Days)])

        persistentStore.viewContext.performAndWait {
            let modu = Modu(context: persistentStore.viewContext)

            modu.name = "ABAN II"
            modu.date = Date()
            modu.rigStatus = "Active"
            modu.specialStatus = "Wide Berth Requested"
            modu.distance = 5
            modu.latitude = 1.0
            modu.longitude = 2.0
            modu.position = "16°20'30.6\"N \n81°55'27\"E"
            modu.navArea = "HYDROPAC"
            modu.region = 6
            modu.subregion = 63

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 0)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 1.0
            modu2.longitude = 2.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63

            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    MSIListView<Modu, EmptyView, EmptyView, EmptyView>()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let repository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))

        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Modu.fullDataSourceName)

        tester().waitForView(withAccessibilityLabel: "1 filter")

        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "ABAN II2")
    }
    
    func testClearFilter() throws {
        
        UserDefaults.standard.setSort(Modu.key, sort: Modu.defaultSort)
        UserDefaults.standard.setFilter(Modu.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: #keyPath(Modu.date), type: .date), comparison: .window, windowUnits: DataSourceWindowUnits.last30Days)])

        persistentStore.viewContext.performAndWait {
            let modu = Modu(context: persistentStore.viewContext)

            modu.name = "ABAN II"
            modu.date = Date()
            modu.rigStatus = "Active"
            modu.specialStatus = "Wide Berth Requested"
            modu.distance = 5
            modu.latitude = 1.0
            modu.longitude = 2.0
            modu.position = "16°20'30.6\"N \n81°55'27\"E"
            modu.navArea = "HYDROPAC"
            modu.region = 6
            modu.subregion = 63

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 0)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 1.0
            modu2.longitude = 2.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63

            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @EnvironmentObject var locationManager: LocationManager
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    MSIListView<Modu, EmptyView, EmptyView, EmptyView>()
                        .environmentObject(locationManager)
                }
                .environmentObject(router)
            }
        }
        
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        let appState = AppState()
        let passThrough = PassThrough()
        
        let repository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))

        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(mockLocationManager as LocationManager)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Modu.fullDataSourceName)

        tester().waitForView(withAccessibilityLabel: "1 filter")
        
        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "ABAN II2")

        tester().tapView(withAccessibilityLabel: "Filter")
        tester().waitForView(withAccessibilityLabel: "remove filter 0")
        tester().tapView(withAccessibilityLabel: "remove filter 0")
        
        tester().tapView(withAccessibilityLabel: "Close Filter")
        
        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForView(withAccessibilityLabel: "ABAN II2")
    }
    
    func testChangeSort() throws {
        
        UserDefaults.standard.setSort(Modu.key, sort: [DataSourceSortParameter(property:DataSourceProperty(name: "Name", key: #keyPath(Modu.name), type: .string), ascending: false)])
        UserDefaults.standard.setFilter(Modu.key, filter: [])

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

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 0)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 1.0
            modu2.longitude = 2.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63

            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    MSIListView<Modu, EmptyView, EmptyView, EmptyView>()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let repository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))

        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Modu.fullDataSourceName)

        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForView(withAccessibilityLabel: "ABAN II2")
        // these are no longer accessibility elements as of Xcode 14.3
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding")
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding2")
        
        tester().tapView(withAccessibilityLabel: "Sort")
        tester().waitForView(withAccessibilityLabel: "Group by primary sort field")
        tester().tapView(withAccessibilityLabel: "Group by primary sort field")
        
        tester().tapView(withAccessibilityLabel: "Close Sort")
        
        // these are no longer accessibility elements as of Xcode 14.3
//        tester().waitForView(withAccessibilityLabel: "Boarding")
//        tester().waitForView(withAccessibilityLabel: "Boarding2")
    }
    
    func testSectionHeaderSublist() throws {
        
        UserDefaults.standard.setSort(Modu.key, sort: [DataSourceSortParameter(property:DataSourceProperty(name: "Nav Area", key: #keyPath(Modu.navArea), type: .string), ascending: false)])
        UserDefaults.standard.setFilter(Modu.key, filter: [])

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

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 0)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 1.0
            modu2.longitude = 2.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC2"
            modu2.region = 6
            modu2.subregion = 63

            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @State var router: MarlinRouter = MarlinRouter()
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    MSIListView<Modu, EmptyView, EmptyView, EmptyView>(sectionHeaderIsSubList: true)
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let repository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))

        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Modu.fullDataSourceName)

        tester().waitForView(withAccessibilityLabel: "All")
        tester().tapView(withAccessibilityLabel: "All")
        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForView(withAccessibilityLabel: "ABAN II2")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "HYDROPAC")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "HYDROPAC2")
        tester().tapView(withAccessibilityLabel: "Back")
        
        tester().tapView(withAccessibilityLabel: "Sort")
        tester().waitForView(withAccessibilityLabel: "Group by primary sort field")
        tester().tapView(withAccessibilityLabel: "Group by primary sort field")
        
        tester().tapView(withAccessibilityLabel: "Close Sort")
        
        tester().waitForView(withAccessibilityLabel: "HYDROPAC")
        tester().waitForView(withAccessibilityLabel: "HYDROPAC2")
    }
    
    func testSectionHeaderSublistWithGroupedSublist() throws {
        
        UserDefaults.standard.setSort(Modu.key, sort: [DataSourceSortParameter(property:DataSourceProperty(name: "Nav Area", key: #keyPath(Modu.navArea), type: .string), ascending: false, section: true)])
        UserDefaults.standard.setFilter(Modu.key, filter: [])

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

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 0)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 1.0
            modu2.longitude = 2.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC2"
            modu2.region = 6
            modu2.subregion = 63

            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    MSIListView<Modu, EmptyView, EmptyView, EmptyView>(sectionHeaderIsSubList: true, sectionGroupNameBuilder: { section in
                        "\(section.name) Header"
                    })
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let repository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))

        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Modu.fullDataSourceName)
        tester().waitForView(withAccessibilityLabel: "HYDROPAC2 Header")
        tester().waitForView(withAccessibilityLabel: "HYDROPAC2")
        tester().tapView(withAccessibilityLabel: "HYDROPAC2")
        tester().waitForView(withAccessibilityLabel: "ABAN II2")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "HYDROPAC")
        tester().tapView(withAccessibilityLabel: "Back")
        
        tester().waitForView(withAccessibilityLabel: "HYDROPAC Header")
        tester().waitForView(withAccessibilityLabel: "HYDROPAC")
        tester().tapView(withAccessibilityLabel: "HYDROPAC")
        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "HYDROPAC2")
        tester().tapView(withAccessibilityLabel: "Back")
        tester().wait(forTimeInterval: 5)
    }
    
    func testSectionContent() throws {
        
        UserDefaults.standard.setSort(Modu.key, sort: [DataSourceSortParameter(property:DataSourceProperty(name: "Nav Area", key: #keyPath(Modu.navArea), type: .string), ascending: false)])
        UserDefaults.standard.setFilter(Modu.key, filter: [])

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

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 0)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 1.0
            modu2.longitude = 2.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63

            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    MSIListView<Modu, EmptyView, AnyView, EmptyView>(sectionHeaderIsSubList: true, sectionNameBuilder: { section in
                        return "MODU SECTION \(section.name) (\(section.items.count))"
                    }, sectionViewBuilder: { _ in EmptyView()}, content: { section in
                        AnyView(Text("content of the section \(section.name) \(section.items.count)"))
                    }, emptyView: {})
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let repository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))

        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Modu.fullDataSourceName)

        tester().waitForView(withAccessibilityLabel: "MODU SECTION All (2)")
        tester().tapView(withAccessibilityLabel: "MODU SECTION All (2)")
        tester().waitForView(withAccessibilityLabel: "content of the section All 2")
        tester().tapView(withAccessibilityLabel: "Back")
        
        tester().tapView(withAccessibilityLabel: "Sort")
        tester().waitForView(withAccessibilityLabel: "Group by primary sort field")
        tester().tapView(withAccessibilityLabel: "Group by primary sort field")
        
        tester().tapView(withAccessibilityLabel: "Close Sort")
        
        tester().waitForView(withAccessibilityLabel: "MODU SECTION HYDROPAC (1)")
        tester().waitForView(withAccessibilityLabel: "MODU SECTION HYDROPAC2 (1)")
    }
    
    func testTapItems() throws {
        UserDefaults.standard.setSort(Modu.key, sort: [])
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

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 0)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 1.0
            modu2.longitude = 2.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63

            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    MSIListView<Modu, EmptyView, EmptyView, EmptyView>()
                        .marlinRoutes()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let repository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointCoreDataDataSource(context: persistentStore.viewContext))
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(routeWaypointRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "ABAN II summary")

        tester().tapView(withAccessibilityLabel: "ABAN II summary")
        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().tapView(withAccessibilityLabel: "Back")
        
        tester().waitForView(withAccessibilityLabel: "ABAN II2 summary")
        tester().tapView(withAccessibilityLabel: "ABAN II2 summary")
        tester().waitForView(withAccessibilityLabel: "ABAN II2")
        tester().tapView(withAccessibilityLabel: "Back")
    }
    
    func testWatchFocusedItem() throws {
        UserDefaults.standard.setSort(Modu.key, sort: [])
        var firstModu: Modu?
        var secondModu: Modu?
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
            firstModu = modu

            let modu2 = Modu(context: persistentStore.viewContext)

            modu2.name = "ABAN II2"
            modu2.date = Date(timeIntervalSince1970: 0)
            modu2.rigStatus = "Active"
            modu2.specialStatus = "Wide Berth Requested"
            modu2.distance = 5
            modu2.latitude = 1.0
            modu2.longitude = 2.0
            modu2.position = "16°20'30.6\"N \n81°55'27\"E"
            modu2.navArea = "HYDROPAC"
            modu2.region = 6
            modu2.subregion = 63
            secondModu = modu2

            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            @Published var item: (any DataSource)?
            @Published var date: Date = Date()
        }
        
        struct Container: View {
            @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
            @State var router: MarlinRouter = MarlinRouter()

            @ObservedObject var passThrough: PassThrough
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    MSIListView<Modu, EmptyView, EmptyView, EmptyView>(focusedItem: itemWrapper, watchFocusedItem: true)
                        .marlinRoutes()
                }
                .onChange(of: passThrough.date) { newValue in
                    print("change date to \(newValue)")
                    itemWrapper.dataSource = passThrough.item
                    itemWrapper.date = Date()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let repository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointCoreDataDataSource(context: persistentStore.viewContext))
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(routeWaypointRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "ABAN II summary")

        passThrough.item = firstModu
        passThrough.date = Date()
        
        tester().waitForView(withAccessibilityLabel: "ABAN II")
//        tester().waitForView(withAccessibilityLabel: firstAsam?.asamDescription)
//        tester().waitForView(withAccessibilityLabel: firstAsam?.hostility)
//        tester().waitForView(withAccessibilityLabel: firstAsam?.victim)
//        tester().waitForView(withAccessibilityLabel: firstAsam?.reference)
//        tester().waitForView(withAccessibilityLabel: firstAsam?.subreg)
//        tester().waitForView(withAccessibilityLabel: firstAsam?.navArea)
//        tester().waitForView(withAccessibilityLabel: firstAsam?.dateString)

        passThrough.item = secondModu
        passThrough.date = Date()

        XCTAssertEqual(secondModu?.itemTitle, "ABAN II2")
        tester().waitForView(withAccessibilityLabel: "ABAN II2")
//        tester().waitForView(withAccessibilityLabel: secondAsam?.asamDescription)
//        tester().waitForView(withAccessibilityLabel: secondAsam?.hostility)
//        tester().waitForView(withAccessibilityLabel: secondAsam?.victim)
//        tester().waitForView(withAccessibilityLabel: secondAsam?.reference)
//        tester().waitForView(withAccessibilityLabel: secondAsam?.subreg)
//        tester().waitForView(withAccessibilityLabel: secondAsam?.navArea)
//        tester().waitForView(withAccessibilityLabel: secondAsam?.dateString)
        tester().tapView(withAccessibilityLabel: "Back")
    }

}
