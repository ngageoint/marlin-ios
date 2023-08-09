//
//  NavigationalWarningSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class NavigationalWarningSummaryViewTests: XCTestCase {
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
    
    override func tearDown(completion: @escaping (Error?) -> Void) {
        persistentStore.viewContext.performAndWait {
            if let nws = persistentStore.viewContext.fetchAll(NavigationalWarning.self) {
                for nw in nws {
                    persistentStore.viewContext.delete(nw)
                }
            }
            try? persistentStore.viewContext.save()
        }
        completion(nil)
    }
    
    func testLoading() {
        let nw = NavigationalWarning(context: persistentStore.viewContext)
        
        nw.cancelMsgNumber = 1
        nw.authority = "authority"
        nw.cancelDate = Date(timeIntervalSince1970: 0)
        nw.cancelMsgYear = 2020
        nw.cancelNavArea = "P"
        nw.issueDate = Date(timeIntervalSince1970: 0)
        nw.msgNumber = 2
        nw.msgYear = 2019
        nw.navArea = "P"
        nw.status = "status"
        nw.subregion = "subregion"
        nw.text = "text of the warning"
        
        let summary = nw.summary
            .setShowMoreDetails(false)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "HYDROPAC 2/2019 (subregion)")
        tester().waitForView(withAccessibilityLabel: "text of the warning")
        tester().waitForView(withAccessibilityLabel: nw.dateString)
        
        tester().wait(forTimeInterval: 1)
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "Close")
        tester().tapView(withAccessibilityLabel: "Close")
        
        BookmarkHelper().verifyBookmarkButton(viewContext: persistentStore.viewContext, bookmarkable: nw)

    }
}
