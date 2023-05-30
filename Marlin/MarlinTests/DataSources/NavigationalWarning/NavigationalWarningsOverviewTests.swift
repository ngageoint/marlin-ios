//
//  NavigationalWarningsOverviewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class NavigationalWarningsOverviewTests: XCTestCase {

    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
        
        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource as! any BatchImportable.Type)
        }
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        
        UserDefaults.standard.setFilter(NavigationalWarning.key, filter: [])
        UserDefaults.standard.setSort(NavigationalWarning.key, sort: NavigationalWarning.defaultSort)
        
        persistentStore.viewContext.performAndWait {
            if let nws = persistentStore.viewContext.fetchAll(NavigationalWarning.self) {
                for nw in nws {
                    persistentStore.viewContext.delete(nw)
                }
            }
        }
        
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                let e5 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
                    if let count = try? self.persistentStore.countOfObjects(NavigationalWarning.self) {
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
            if let nws = persistentStore.viewContext.fetchAll(NavigationalWarning.self) {
                for nw in nws {
                    persistentStore.viewContext.delete(nw)
                }
            }
        }
        completion(nil)
    }
    
    func testNavWarningNoCurrentArea() throws {
        var warnings: [NavigationalWarning] = []
        persistentStore.viewContext.performAndWait {
            let navWarning = NavigationalWarning(context: persistentStore.viewContext)
            navWarning.msgYear = 2022
            navWarning.msgNumber = 1177
            navWarning.navArea = "4"
            navWarning.subregion = "11,26"
            navWarning.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning.status = "A"
            navWarning.issueDate = Date()
            navWarning.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
            
            warnings.append(navWarning)
            
            let navWarning2 = NavigationalWarning(context: persistentStore.viewContext)
            navWarning2.msgYear = 2022
            navWarning2.msgNumber = 1178
            navWarning2.navArea = "A"
            navWarning2.subregion = "11,26"
            navWarning2.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning2.status = "A"
            navWarning2.issueDate = Date()
            navWarning2.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
            
            warnings.append(navWarning2)
            
            let navWarning3 = NavigationalWarning(context: persistentStore.viewContext)
            navWarning3.msgYear = 2022
            navWarning3.msgNumber = 1179
            navWarning3.navArea = "A"
            navWarning3.subregion = "11,26"
            navWarning3.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning3.status = "A"
            navWarning3.issueDate = Date()
            navWarning3.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
            
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
        }
        
        struct Container: View {

            @ObservedObject var passThrough: PassThrough
            @EnvironmentObject var locationManager: LocationManager

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationView {
                    NavigationalWarningsOverview()
                        .environmentObject(locationManager)
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.currentNavArea = nil

        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(mockLocationManager as LocationManager)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "NAVAREA IV")
        tester().waitForView(withAccessibilityLabel: "HYDROLANT")
    }
    
    func testNavWarningCurrentArea() throws {
        var warnings: [NavigationalWarning] = []
        persistentStore.viewContext.performAndWait {
            let navWarning = NavigationalWarning(context: persistentStore.viewContext)
            navWarning.msgYear = 2022
            navWarning.msgNumber = 1177
            navWarning.navArea = "4"
            navWarning.subregion = "11,26"
            navWarning.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning.status = "A"
            navWarning.issueDate = Date()
            navWarning.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
            
            warnings.append(navWarning)
            
            let navWarning2 = NavigationalWarning(context: persistentStore.viewContext)
            navWarning2.msgYear = 2022
            navWarning2.msgNumber = 1178
            navWarning2.navArea = "A"
            navWarning2.subregion = "11,26"
            navWarning2.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning2.status = "A"
            navWarning2.issueDate = Date()
            navWarning2.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
            
            warnings.append(navWarning2)
            
            let navWarning3 = NavigationalWarning(context: persistentStore.viewContext)
            navWarning3.msgYear = 2022
            navWarning3.msgNumber = 1179
            navWarning3.navArea = "A"
            navWarning3.subregion = "11,26"
            navWarning3.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning3.status = "A"
            navWarning3.issueDate = Date()
            navWarning3.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
            
            warnings.append(navWarning3)
            
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            @Published var navArea: NavigationalWarningNavArea?
        }
        
        struct Container<Location>: View where Location: LocationManagerProtocol {
            @EnvironmentObject var locationManager: LocationManager
            @ObservedObject var passThrough: PassThrough
            var location: Location
            
            init(passThrough: PassThrough, location: Location) {
                self.passThrough = passThrough
                self.location = location
            }
            
            var body: some View {
                NavigationView {
                    NavigationalWarningsOverview()
                        .environmentObject(locationManager)
                }
                .onAppear {
                    GeneralLocation.shared.currentNavArea = .NAVAREA_IV
                    GeneralLocation.shared.currentNavAreaName = GeneralLocation.shared.currentNavArea?.name
//                    locationManager.currentNavArea = .NAVAREA_IV
                }
                .onChange(of: passThrough.navArea) { newValue in
                    locationManager.currentNavArea = newValue
                    GeneralLocation.shared.currentNavArea = newValue
                    GeneralLocation.shared.currentNavAreaName = newValue?.name
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.currentNavArea = nil
        
        let container = Container<MockLocationManager>(passThrough: passThrough, location: mockLocationManager)
            .environmentObject(appState)
            .environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(mockLocationManager as LocationManager)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "NAVAREA IV (Current)")
        tester().waitForView(withAccessibilityLabel: "HYDROLANT")
        
        passThrough.navArea = .HYDROLANT
        tester().waitForView(withAccessibilityLabel: "NAVAREA IV")
        tester().waitForView(withAccessibilityLabel: "HYDROLANT (Current)")
    }
}
