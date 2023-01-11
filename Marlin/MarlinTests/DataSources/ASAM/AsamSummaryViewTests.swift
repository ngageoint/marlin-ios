//
//  AsamSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/20/22.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class AsamSummaryViewTests: XCTestCase {
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

    func testLoading() {
        let newItem = Asam(context: persistentStore.viewContext)
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = "Boarding"
        newItem.victim = "Boat"
        
        let summary = AsamSummaryView(asam: newItem)
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadingNoHostility() {
        let newItem = Asam(context: persistentStore.viewContext)
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = nil
        newItem.victim = "Boat"
        
        let summary = AsamSummaryView(asam: newItem)
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boat")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadingNoVictim() {
        let newItem = Asam(context: persistentStore.viewContext)
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = "Boarding"
        newItem.victim = nil
        
        let summary = AsamSummaryView(asam: newItem)
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boarding")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadingShowMoreDetails() {
        let newItem = Asam(context: persistentStore.viewContext)
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = "Boarding"
        newItem.victim = "Boat"
        
        let summary = AsamSummaryView(asam: newItem, showMoreDetails: true)
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .ViewDataSource,
                    object: nil) { notification in
            
            let asam = try! XCTUnwrap(notification.object as? Asam)
            XCTAssertEqual(asam.hostility, "Boarding")
            XCTAssertEqual(asam.victim, "Boat")
            return true
        }
        tester().tapView(withAccessibilityLabel: "More Details")
        
        waitForExpectations(timeout: 10, handler: nil)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
    }
    
    func testLoadingShowMoreDetailsFalse() {
        let newItem = Asam(context: persistentStore.viewContext)
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = "Boarding"
        newItem.victim = "Boat"
        
        let summary = AsamSummaryView(asam: newItem, showMoreDetails: false)
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "focus")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .MapRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let asams = tapNotification.items as! [Asam]
            XCTAssertEqual(asams.count, 1)
            XCTAssertEqual(asams[0].hostility, "Boarding")
            XCTAssertEqual(asams[0].victim, "Boat")
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "Close")
        tester().tapView(withAccessibilityLabel: "Close")
    }

}
