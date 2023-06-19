//
//  NavigationalWarningAreaUnreadBadgeTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class NavigationalWarningAreaUnreadBadgeTests: XCTestCase {
    
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
                print("setup really done")
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
        print("setup donesih")
        
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
    
    func testNoneRead() throws {
        var warnings: [NavigationalWarning] = []
        persistentStore.viewContext.performAndWait {
            
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
        
        let view = NavigationalWarningAreaUnreadBadge(navArea: "A", warnings: warnings)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "2 Unread")
    }
    
    func testOneRead() throws {
        var warnings: [NavigationalWarning] = []
        persistentStore.viewContext.performAndWait {

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
                    NavigationalWarningAreaUnreadBadge(navArea: passThrough.navArea, warnings: passThrough.warnings)
                }
            }
        }
        
        UserDefaults.standard.setValue(warnings[1].primaryKey, forKey: "lastSeen-A")
        
        let appState = AppState()
        let passThrough = PassThrough(navArea: "A", warnings: warnings)
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "1 Unread")
    }
    
    func testAllRead() throws {
        print("all read")
        var warnings: [NavigationalWarning] = []
        persistentStore.viewContext.performAndWait {
            
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
                    NavigationalWarningAreaUnreadBadge(navArea: passThrough.navArea, warnings: passThrough.warnings)
                }
            }
        }
        
        UserDefaults.standard.setValue(warnings[0].primaryKey, forKey: "lastSeen-A")
        
        let appState = AppState()
        let passThrough = PassThrough(navArea: "A", warnings: warnings)
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAnimationsToFinish()
        tester().waitForAbsenceOfView(withAccessibilityLabel: "2 Unread")
    }

}
