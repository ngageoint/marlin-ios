//
//  NavigationalWarningNavAreaListViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class NavigationalWarningNavAreaListViewTests: XCTestCase {

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

    func testOneNavWarning() throws {
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
            
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            var navArea: String
            var warnings: [NavigationalWarning]
            
            init(navArea: String, warnings: [NavigationalWarning]) {
                self.navArea = navArea
                self.warnings = warnings
            }
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationView {
                    NavigationalWarningNavAreaListView(warnings: passThrough.warnings, navArea: passThrough.navArea, mapName: "Navigational Warning List View Map")
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough(navArea: "4", warnings: warnings)
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: warnings[0].primaryKey)
    }
    
    func testALotOfNavWarnings() throws {
        var dateComponents = DateComponents()
        dateComponents.year = 2022
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.hour = 12
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        
        let year = Calendar.current.date(from: dateComponents)!
        var warnings: [NavigationalWarning] = []
        persistentStore.viewContext.performAndWait {
            for i in 1...12 {
                let navWarning = NavigationalWarning(context: persistentStore.viewContext)
                navWarning.msgYear = 2022
                navWarning.msgNumber = Int64(13 - i)
                navWarning.navArea = "4"
                navWarning.subregion = "11,26"
                navWarning.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
                navWarning.status = "A"
                navWarning.issueDate = Calendar.current.date(bySetting: .month, value: 13 - i, of: year)
                navWarning.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
                
                warnings.append(navWarning)
            }
            
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            var navArea: String
            var warnings: [NavigationalWarning]
            
            init(navArea: String, warnings: [NavigationalWarning]) {
                self.navArea = navArea
                self.warnings = warnings
            }
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationView {
                    NavigationalWarningNavAreaListView(warnings: passThrough.warnings, navArea: passThrough.navArea, mapName: "Navigational Warning List View Map")
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough(navArea: "4", warnings: warnings)
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "10 Unread Warnings")
        tester().scrollView(withAccessibilityIdentifier: "Navigation Warning Scroll", byFractionOfSizeHorizontal: 0, vertical: 1.0)
        tester().waitForAnimationsToFinish()
        tester().waitForAbsenceOfView(withAccessibilityLabel: "10 Unread Warnings")
    }
    
    func testALotOfNavWarningsScrollTopWithTap() throws {
        var dateComponents = DateComponents()
        dateComponents.year = 2022
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.hour = 12
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        
        let year = Calendar.current.date(from: dateComponents)!
        var warnings: [NavigationalWarning] = []
        persistentStore.viewContext.performAndWait {
            for i in 1...12 {
                let navWarning = NavigationalWarning(context: persistentStore.viewContext)
                navWarning.msgYear = 2022
                navWarning.msgNumber = Int64(13 - i)
                navWarning.navArea = "4"
                navWarning.subregion = "11,26"
                navWarning.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
                navWarning.status = "A"
                navWarning.issueDate = Calendar.current.date(bySetting: .month, value: 13 - i, of: year)
                navWarning.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
                
                warnings.append(navWarning)
            }
            
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            var navArea: String
            var warnings: [NavigationalWarning]
            
            init(navArea: String, warnings: [NavigationalWarning]) {
                self.navArea = navArea
                self.warnings = warnings
            }
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationView {
                    NavigationalWarningNavAreaListView(warnings: passThrough.warnings, navArea: passThrough.navArea, mapName: "Navigational Warning List View Map")
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough(navArea: "4", warnings: warnings)
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "10 Unread Warnings")
        tester().tapView(withAccessibilityLabel: "10 Unread Warnings")
        tester().waitForAnimationsToFinish()
        tester().waitForAbsenceOfView(withAccessibilityLabel: "10 Unread Warnings")
    }
    
    func testALotOfNavWarningsWithLastSeen() throws {
        var dateComponents = DateComponents()
        dateComponents.year = 2022
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.hour = 12
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        
        let year = Calendar.current.date(from: dateComponents)!
        var warnings: [NavigationalWarning] = []
        persistentStore.viewContext.performAndWait {
            for i in 1...12 {
                let navWarning = NavigationalWarning(context: persistentStore.viewContext)
                navWarning.msgYear = 2022
                navWarning.msgNumber = Int64(13 - i)
                navWarning.navArea = "4"
                navWarning.subregion = "11,26"
                navWarning.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
                navWarning.status = "A"
                navWarning.issueDate = Calendar.current.date(bySetting: .month, value: 13 - i, of: year)
                navWarning.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
                
                warnings.append(navWarning)
            }
            
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            var navArea: String
            var warnings: [NavigationalWarning]
            
            init(navArea: String, warnings: [NavigationalWarning]) {
                self.navArea = navArea
                self.warnings = warnings
            }
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationView {
                    NavigationalWarningNavAreaListView(warnings: passThrough.warnings, navArea: passThrough.navArea, mapName: "Navigational Warning List View Map")
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough(navArea: "4", warnings: warnings)
        
        UserDefaults.standard.setValue(warnings[5].primaryKey, forKey: "lastSeen-4")
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForAnimationsToFinish()
        
        tester().waitForView(withAccessibilityLabel: "5 Unread Warnings")
        tester().tapView(withAccessibilityLabel: "5 Unread Warnings")
        tester().waitForAnimationsToFinish()
        tester().waitForAbsenceOfView(withAccessibilityLabel: "5 Unread Warnings")
    }
    
    func testALotOfNavWarningsWithLastSeenThatDoesNotExist() throws {
        var dateComponents = DateComponents()
        dateComponents.year = 2022
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.hour = 12
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        
        let year = Calendar.current.date(from: dateComponents)!
        var warnings: [NavigationalWarning] = []
        persistentStore.viewContext.performAndWait {
            for i in 1...12 {
                let navWarning = NavigationalWarning(context: persistentStore.viewContext)
                navWarning.msgYear = 2022
                navWarning.msgNumber = Int64(13 - i)
                navWarning.navArea = "4"
                navWarning.subregion = "11,26"
                navWarning.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
                navWarning.status = "A"
                navWarning.issueDate = Calendar.current.date(bySetting: .month, value: 13 - i, of: year)
                navWarning.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
                
                warnings.append(navWarning)
            }
            
            try? persistentStore.viewContext.save()
        }
        
        class PassThrough: ObservableObject {
            var navArea: String
            var warnings: [NavigationalWarning]
            
            init(navArea: String, warnings: [NavigationalWarning]) {
                self.navArea = navArea
                self.warnings = warnings
            }
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationView {
                    NavigationalWarningNavAreaListView(warnings: passThrough.warnings, navArea: passThrough.navArea, mapName: "Navigational Warning List View Map")
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough(navArea: "4", warnings: warnings)
        
        UserDefaults.standard.setValue("no", forKey: "lastSeen-4")
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForAnimationsToFinish()
        
        tester().waitForView(withAccessibilityLabel: "10 Unread Warnings")
        tester().tapView(withAccessibilityLabel: "10 Unread Warnings")
        tester().waitForAnimationsToFinish()
        tester().waitForAbsenceOfView(withAccessibilityLabel: "10 Unread Warnings")
    }

}
