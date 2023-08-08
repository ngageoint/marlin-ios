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
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource as! any BatchImportable.Type)
        }
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        
        UserDefaults.standard.setFilter(Asam.key, filter: [])
        UserDefaults.standard.setSort(Asam.key, sort: Asam.defaultSort)
        
        persistentStore.viewContext.performAndWait {
            if let asams = persistentStore.viewContext.fetchAll(Asam.self) {
                for asam in asams {
                    persistentStore.viewContext.delete(asam)
                }
            }
        }
        
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                let e5 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
                    if let count = try? self.persistentStore.countOfObjects(Asam.self) {
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
            if let asams = persistentStore.viewContext.fetchAll(Asam.self) {
                for asam in asams {
                    persistentStore.viewContext.delete(asam)
                }
            }
        }
        completion(nil)
    }

    func testOneSectionList() throws {
        UserDefaults.standard.setSort(Asam.key, sort: [])
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"
            
            try? persistentStore.viewContext.save()
        }

        class PassThrough: ObservableObject {

        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var path: NavigationPath = NavigationPath()
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $path) {
                    MSIListView<Asam, EmptyView, EmptyView, EmptyView>(path: $path)
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        tester().waitForView(withAccessibilityLabel: "Boarding2: Boat2")
    }
    
    func testZeroItemList() throws {
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough
            @State var path: NavigationPath = NavigationPath()
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $path) {
                    MSIListView<Asam, EmptyView, EmptyView, EmptyView>(path: $path)
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Asam.fullDataSourceName)
    }

    func testAddItemsList() throws {
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var path: NavigationPath = NavigationPath()
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $path) {
                    MSIListView<Asam, EmptyView, EmptyView, EmptyView>(path: $path)
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Asam.fullDataSourceName)

        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"

            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"

            try? persistentStore.viewContext.save()
        }

        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        tester().waitForView(withAccessibilityLabel: "Boarding2: Boat2")
    }

    func testAddItemsListWithSectionKey() throws {

        UserDefaults.standard.setSort(Asam.key, sort: [DataSourceSortParameter(property:DataSourceProperty(name: "Hostility", key: #keyPath(Asam.hostility), type: .string), ascending: false, section: true)])
        UserDefaults.standard.setFilter(Asam.key, filter: [])

        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var path: NavigationPath = NavigationPath()
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $path) {
                    MSIListView<Asam, EmptyView, EmptyView, EmptyView>(path: $path)
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Asam.fullDataSourceName)

        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"

            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"

            try? persistentStore.viewContext.save()
        }

        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        tester().waitForView(withAccessibilityLabel: "Boarding2: Boat2")
        
        // these are no longer accessibility elements as of Xcode 14.3
//        tester().waitForView(withAccessibilityLabel: "Boarding2")
//        tester().waitForView(withAccessibilityLabel: "Boarding")
    }

    func testFilteredList() throws {

        UserDefaults.standard.setSort(Asam.key, sort: Asam.defaultSort)
        UserDefaults.standard.setFilter(Asam.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: #keyPath(Asam.date), type: .date), comparison: .window, windowUnits: DataSourceWindowUnits.last30Days)])

        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"

            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"

            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var path: NavigationPath = NavigationPath()
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $path) {
                    MSIListView<Asam, EmptyView, EmptyView, EmptyView>(path: $path)
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Asam.fullDataSourceName)
        
        tester().waitForView(withAccessibilityLabel: "1 filter")

        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding2: Boat2")
    }
    
    func testClearFilter() throws {
        
        UserDefaults.standard.setSort(Asam.key, sort: Asam.defaultSort)
        UserDefaults.standard.setFilter(Asam.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: #keyPath(Asam.date), type: .date), comparison: .window, windowUnits: DataSourceWindowUnits.last30Days)])
        
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"
            
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @EnvironmentObject var locationManager: LocationManager
            @State var path: NavigationPath = NavigationPath()
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $path) {
                    MSIListView<Asam, EmptyView, EmptyView, EmptyView>(path: $path)
                        .environmentObject(locationManager)
                }
            }
        }
        
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(mockLocationManager as LocationManager)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Asam.fullDataSourceName)
        
        tester().waitForView(withAccessibilityLabel: "1 filter")
        
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding2: Boat2")
        
        tester().tapView(withAccessibilityLabel: "Filter")
        tester().waitForView(withAccessibilityLabel: "remove filter 0")
        tester().tapView(withAccessibilityLabel: "remove filter 0")
        
        tester().tapView(withAccessibilityLabel: "Close Filter")
        
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        tester().waitForView(withAccessibilityLabel: "Boarding2: Boat2")
    }
    
    func testChangeSort() throws {
        
        UserDefaults.standard.setSort(Asam.key, sort: [DataSourceSortParameter(property:DataSourceProperty(name: "Hostility", key: #keyPath(Asam.hostility), type: .string), ascending: false)])
        UserDefaults.standard.setFilter(Asam.key, filter: [])
        
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"
            
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var path: NavigationPath = NavigationPath()
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $path) {
                    MSIListView<Asam, EmptyView, EmptyView, EmptyView>(path: $path)
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Asam.fullDataSourceName)
                
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        tester().waitForView(withAccessibilityLabel: "Boarding2: Boat2")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding2")
        
        tester().tapView(withAccessibilityLabel: "Sort")
        tester().waitForView(withAccessibilityLabel: "Group by primary sort field")
        tester().tapView(withAccessibilityLabel: "Group by primary sort field")
        
        tester().tapView(withAccessibilityLabel: "Close Sort")
        
        // these are no longer accessibility elements as of Xcode 14.3
//        tester().waitForView(withAccessibilityLabel: "Boarding")
//        tester().waitForView(withAccessibilityLabel: "Boarding2")
    }
    
    func testSectionHeaderSublist() throws {
        
        UserDefaults.standard.setSort(Asam.key, sort: [DataSourceSortParameter(property:DataSourceProperty(name: "Hostility", key: #keyPath(Asam.hostility), type: .string), ascending: false)])
        UserDefaults.standard.setFilter(Asam.key, filter: [])
        
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"
            
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @State var path: NavigationPath = NavigationPath()
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $path) {
                    MSIListView<Asam, EmptyView, EmptyView, EmptyView>(path: $path, sectionHeaderIsSubList: true)
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Asam.fullDataSourceName)
        
        tester().waitForView(withAccessibilityLabel: "All")
        tester().tapView(withAccessibilityLabel: "All")
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        tester().waitForView(withAccessibilityLabel: "Boarding2: Boat2")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding2")
        tester().tapView(withAccessibilityLabel: "Back")
        
        tester().tapView(withAccessibilityLabel: "Sort")
        tester().waitForView(withAccessibilityLabel: "Group by primary sort field")
        tester().tapView(withAccessibilityLabel: "Group by primary sort field")
        
        tester().tapView(withAccessibilityLabel: "Close Sort")
        
        tester().waitForView(withAccessibilityLabel: "Boarding")
        tester().waitForView(withAccessibilityLabel: "Boarding2")
    }
    
    func testSectionHeaderSublistWithGroupedSublist() throws {
        
        UserDefaults.standard.setSort(Asam.key, sort: [DataSourceSortParameter(property:DataSourceProperty(name: "Hostility", key: #keyPath(Asam.hostility), type: .string), ascending: false, section: true)])
        UserDefaults.standard.setFilter(Asam.key, filter: [])
        
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"
            
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var path: NavigationPath = NavigationPath()
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $path) {
                    MSIListView<Asam, EmptyView, EmptyView, EmptyView>(path: $path, sectionHeaderIsSubList: true, sectionGroupNameBuilder: { section in
                        "\(section.name) Header"
                    })
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Asam.fullDataSourceName)
        tester().waitForView(withAccessibilityLabel: "Boarding2 Header")
        tester().waitForView(withAccessibilityLabel: "Boarding2")
        tester().tapView(withAccessibilityLabel: "Boarding2")
        tester().waitForView(withAccessibilityLabel: "Boarding2: Boat2")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding")
        tester().tapView(withAccessibilityLabel: "Back")
        
        tester().waitForView(withAccessibilityLabel: "Boarding Header")
        tester().waitForView(withAccessibilityLabel: "Boarding")
        tester().tapView(withAccessibilityLabel: "Boarding")
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding2")
        tester().tapView(withAccessibilityLabel: "Back")
        tester().wait(forTimeInterval: 5)
    }
    
    func testSectionContent() throws {
        
        UserDefaults.standard.setSort(Asam.key, sort: [DataSourceSortParameter(property:DataSourceProperty(name: "Hostility", key: #keyPath(Asam.hostility), type: .string), ascending: false)])
        UserDefaults.standard.setFilter(Asam.key, filter: [])
        
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"
            
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var path: NavigationPath = NavigationPath()
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $path) {
                    MSIListView<Asam, EmptyView, AnyView, EmptyView>(path: $path, sectionHeaderIsSubList: true, sectionNameBuilder: { section in
                        return "ASAM SECTION \(section.name) (\(section.items.count))"
                    }, sectionViewBuilder: { _ in EmptyView()}, content: { section in
                        AnyView(Text("content of the section \(section.name) \(section.items.count)"))
                    }, emptyView: {})
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: Asam.fullDataSourceName)
        
        tester().waitForView(withAccessibilityLabel: "ASAM SECTION All (2)")
        tester().tapView(withAccessibilityLabel: "ASAM SECTION All (2)")
        tester().waitForView(withAccessibilityLabel: "content of the section All 2")
        tester().tapView(withAccessibilityLabel: "Back")
        
        tester().tapView(withAccessibilityLabel: "Sort")
        tester().waitForView(withAccessibilityLabel: "Group by primary sort field")
        tester().tapView(withAccessibilityLabel: "Group by primary sort field")
        
        tester().tapView(withAccessibilityLabel: "Close Sort")
        
        tester().waitForView(withAccessibilityLabel: "ASAM SECTION Boarding (1)")
        tester().waitForView(withAccessibilityLabel: "ASAM SECTION Boarding2 (1)")
    }
    
    func testTapItems() throws {
        UserDefaults.standard.setSort(Asam.key, sort: [])
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"
            
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @State var path: NavigationPath = NavigationPath()
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $path) {
                    MSIListView<Asam, EmptyView, EmptyView, EmptyView>(path: $path)
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat summary")
        
        tester().tapView(withAccessibilityLabel: "Boarding: Boat summary")
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        tester().tapView(withAccessibilityLabel: "Back")
        
        tester().waitForView(withAccessibilityLabel: "Boarding2: Boat2 summary")
        tester().tapView(withAccessibilityLabel: "Boarding2: Boat2 summary")
        tester().waitForView(withAccessibilityLabel: "Boarding2: Boat2")
        tester().tapView(withAccessibilityLabel: "Back")
    }
    
    func testWatchFocusedItem() throws {
        UserDefaults.standard.setSort(Asam.key, sort: [])
        var firstAsam: Asam?
        var secondAsam: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            firstAsam = asam
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"
            secondAsam = asam2
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            @Published var item: (any DataSource)?
            @Published var date: Date = Date()
        }
        
        struct Container: View {
            @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
            @State var path: NavigationPath = NavigationPath()
            
            @ObservedObject var passThrough: PassThrough
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $path) {
                    MSIListView<Asam, EmptyView, EmptyView, EmptyView>(path: $path, focusedItem: itemWrapper, watchFocusedItem: true)
                }
                .onChange(of: passThrough.date) { newValue in
                    print("change date to \(newValue)")
                    itemWrapper.dataSource = passThrough.item
                    itemWrapper.date = Date()
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat summary")

        passThrough.item = firstAsam
        passThrough.date = Date()
        
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        tester().waitForView(withAccessibilityLabel: firstAsam?.asamDescription)
        tester().waitForView(withAccessibilityLabel: firstAsam?.hostility)
        tester().waitForView(withAccessibilityLabel: firstAsam?.victim)
        tester().waitForView(withAccessibilityLabel: firstAsam?.reference)
        tester().waitForView(withAccessibilityLabel: firstAsam?.subreg)
        tester().waitForView(withAccessibilityLabel: firstAsam?.navArea)
        tester().waitForView(withAccessibilityLabel: firstAsam?.dateString)

        passThrough.item = secondAsam
        passThrough.date = Date()

        XCTAssertEqual(secondAsam?.itemTitle, "Boarding2: Boat2")
        tester().waitForView(withAccessibilityLabel: "Boarding2: Boat2")
        tester().waitForView(withAccessibilityLabel: secondAsam?.asamDescription)
        tester().waitForView(withAccessibilityLabel: secondAsam?.hostility)
        tester().waitForView(withAccessibilityLabel: secondAsam?.victim)
        tester().waitForView(withAccessibilityLabel: secondAsam?.reference)
        tester().waitForView(withAccessibilityLabel: secondAsam?.subreg)
        tester().waitForView(withAccessibilityLabel: secondAsam?.navArea)
        tester().waitForView(withAccessibilityLabel: secondAsam?.dateString)
        tester().tapView(withAccessibilityLabel: "Back")
    }

}
