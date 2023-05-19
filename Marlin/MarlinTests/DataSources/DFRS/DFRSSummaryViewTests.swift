//
//  DFRSSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/24/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class DFRSSummaryViewTests: XCTestCase {
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DFRS.self as any BatchImportable.Type)
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
        let newItem = DFRS(context: persistentStore.viewContext)
        newItem.stationNumber = "1188.61\n2-1282"
        newItem.stationName = "Nos Galata Lt."
        newItem.stationType = "RDF"
        newItem.rxPosition = nil
        newItem.rxLongitude = -190.0
        newItem.rxLatitude = -190.0
        newItem.txPosition = "1°00'00\"N \n2°00'00\"E"
        newItem.txLongitude = 2.0
        newItem.txLatitude = 1.0
        newItem.frequency = "297.5 kHz, A2A."
        newItem.range = 5
        newItem.procedureText = "On request to Hydrographic Service, Varna."
        newItem.remarks = "Transmits !DG$."
        newItem.notes = "notes"
        newItem.areaName = "BULGARIA"
        
        let summary = newItem.summaryView(showMoreDetails: false)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "1188.61\n2-1282")
        tester().waitForView(withAccessibilityLabel: "Nos Galata Lt.")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "BULGARIA")
        tester().waitForView(withAccessibilityLabel: "notes")
        tester().waitForView(withAccessibilityLabel: "Transmits !DG$.")
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertEqual(model?.snackbarModel?.message, "Location 1° 00' 00\" N, 2° 00' 00\" E copied to clipboard")
            XCTAssertEqual(UIPasteboard.general.string, "1° 00' 00\" N, 2° 00' 00\" E")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let dfrs = tapNotification.items as! [DFRS]
            XCTAssertEqual(dfrs.count, 1)
            XCTAssertEqual(dfrs[0].stationName, "Nos Galata Lt.")
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "Close")
        tester().tapView(withAccessibilityLabel: "Close")
    }
    
    func testShowMoreDetails() {
        let newItem = DFRS(context: persistentStore.viewContext)
        newItem.stationNumber = "1188.61\n2-1282"
        newItem.stationName = "Nos Galata Lt."
        newItem.stationType = "RDF"
        newItem.rxPosition = nil
        newItem.rxLongitude = -190.0
        newItem.rxLatitude = -190.0
        newItem.txPosition = "1°00'00\"N \n2°00'00\"E"
        newItem.txLongitude = 2.0
        newItem.txLatitude = 1.0
        newItem.frequency = "297.5 kHz, A2A."
        newItem.range = 5
        newItem.procedureText = "On request to Hydrographic Service, Varna."
        newItem.remarks = "Transmits !DG$."
        newItem.notes = "notes"
        newItem.areaName = "BULGARIA"
        
        let summary = newItem.summaryView(showMoreDetails: true)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "1188.61\n2-1282")
        tester().waitForView(withAccessibilityLabel: "Nos Galata Lt.")
        tester().waitForView(withAccessibilityLabel: "BULGARIA")
        tester().waitForView(withAccessibilityLabel: "notes")
        tester().waitForView(withAccessibilityLabel: "Transmits !DG$.")
        
        expectation(forNotification: .ViewDataSource,
                    object: nil) { notification in
            let vds = try! XCTUnwrap(notification.object as? ViewDataSource)
            let dfrs = try! XCTUnwrap(vds.dataSource as? DFRS)
            XCTAssertEqual(dfrs.stationName, "Nos Galata Lt.")
            return true
        }
        tester().tapView(withAccessibilityLabel: "More Details")
        
        waitForExpectations(timeout: 10, handler: nil)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
    }
    
    func testShowSectionHeader() {
        let newItem = DFRS(context: persistentStore.viewContext)
        newItem.stationNumber = "1188.61\n2-1282"
        newItem.stationName = "Nos Galata Lt."
        newItem.stationType = "RDF"
        newItem.rxPosition = nil
        newItem.rxLongitude = -190.0
        newItem.rxLatitude = -190.0
        newItem.txPosition = "1°00'00\"N \n2°00'00\"E"
        newItem.txLongitude = 2.0
        newItem.txLatitude = 1.0
        newItem.frequency = "297.5 kHz, A2A."
        newItem.range = 5
        newItem.procedureText = "On request to Hydrographic Service, Varna."
        newItem.remarks = "Transmits !DG$."
        newItem.notes = "notes"
        newItem.areaName = "BULGARIA"
        
        let summary = newItem.summaryView(showMoreDetails: false, showSectionHeader: true)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "1188.61\n2-1282")
        tester().waitForView(withAccessibilityLabel: "Nos Galata Lt.")
        tester().waitForView(withAccessibilityLabel: "BULGARIA")
        tester().waitForView(withAccessibilityLabel: "notes")
        tester().waitForView(withAccessibilityLabel: "Transmits !DG$.")
        
        tester().waitForAbsenceOfView(withAccessibilityLabel: "More Details")
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let dfrs = tapNotification.items as! [DFRS]
            XCTAssertEqual(dfrs.count, 1)
            XCTAssertEqual(dfrs[0].stationName, "Nos Galata Lt.")
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
