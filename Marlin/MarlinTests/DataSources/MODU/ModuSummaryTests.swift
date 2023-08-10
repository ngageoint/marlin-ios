//
//  ModuSummaryTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class ModuSummaryTests: XCTestCase {
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
        
        let summary = modu.summary
            .setShowMoreDetails(false)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Active")
        tester().waitForView(withAccessibilityLabel: "Wide Berth Requested")
        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForView(withAccessibilityLabel: modu.dateString)
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertEqual(model?.snackbarModel?.message, "Location \(UserDefaults.standard.coordinateDisplay.format(coordinate: modu.coordinate)) copied to clipboard")
            XCTAssertEqual(UIPasteboard.general.string, "\(UserDefaults.standard.coordinateDisplay.format(coordinate: modu.coordinate))")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let modu = tapNotification.items as! [Modu]
            XCTAssertEqual(modu.count, 1)
            XCTAssertEqual(modu[0].name, "ABAN II")
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "Close")
        tester().tapView(withAccessibilityLabel: "Close")
        
        BookmarkHelper().verifyBookmarkButton(viewContext: persistentStore.viewContext, bookmarkable: modu)
    }
    
    func testShowMoreDetails() {
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
        
        let summary = modu.summary
            .setShowMoreDetails(true)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Active")
        
        expectation(forNotification: .ViewDataSource,
                    object: nil) { notification in
            let vds = try! XCTUnwrap(notification.object as? ViewDataSource)
            let modu = try! XCTUnwrap(vds.dataSource as? Modu)
            XCTAssertEqual(modu.name, "ABAN II")
            return true
        }
        tester().tapView(withAccessibilityLabel: "More Details")
        
        waitForExpectations(timeout: 10, handler: nil)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
    }
}
