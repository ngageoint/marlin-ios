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
    var persistentStore: PersistentStore = PersistenceController.memory
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
        persistentStore = PersistenceController.memory
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

}
