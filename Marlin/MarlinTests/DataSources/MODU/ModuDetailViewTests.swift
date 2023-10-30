//
//  ModuDetailViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class ModuDetailViewTests: XCTestCase {
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
        var newItem: Modu?
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
            
            newItem = modu
            try? persistentStore.viewContext.save()
        }
        
        guard let newItem = newItem else {
            XCTFail()
            return
        }

        let repository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        
        let detailView = newItem.detailView.environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForView(withAccessibilityLabel: newItem.dateString)
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertEqual(model?.snackbarModel?.message, "Location \(UserDefaults.standard.coordinateDisplay.format(coordinate: newItem.coordinate)) copied to clipboard")
            XCTAssertEqual(UIPasteboard.general.string, "\(UserDefaults.standard.coordinateDisplay.format(coordinate: newItem.coordinate))")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let modu = tapNotification.items as! [ModuModel]
            XCTAssertEqual(modu.count, 1)
            XCTAssertEqual(modu[0].name, "ABAN II")
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapView(withAccessibilityLabel: "dismiss popup")
        
        tester().waitForView(withAccessibilityLabel: newItem.rigStatus)
        tester().waitForView(withAccessibilityLabel: newItem.specialStatus)
        tester().waitForView(withAccessibilityLabel: "\(newItem.distance)")
        tester().waitForView(withAccessibilityLabel: newItem.navArea)
        tester().waitForView(withAccessibilityLabel: "\(newItem.subregion)")
        
        BookmarkHelper().verifyBookmarkButton(viewContext: persistentStore.viewContext, bookmarkable: newItem)
    }
}
