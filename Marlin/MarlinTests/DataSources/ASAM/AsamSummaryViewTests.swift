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
        var asam: Asam?
        persistentStore.viewContext.performAndWait {
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
            asam = newItem
            try? persistentStore.viewContext.save()
        }
        guard let newItem = asam else {
            XCTFail()
            return
        }
        
        let repository = AsamRepository(localDataSource: AsamCoreDataDataSource(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        
        let summary = AsamSummaryView(asam: AsamModel(asam:newItem))
            .environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
              
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
        
        BookmarkHelper().verifyBookmarkButton(viewContext: persistentStore.viewContext, bookmarkable: newItem)
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
        
        let repository = AsamRepository(localDataSource: AsamCoreDataDataSource(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        
        let summary = AsamSummaryView(asam: AsamModel(asam: newItem))
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
              
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
        
        let repository = AsamRepository(localDataSource: AsamCoreDataDataSource(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        
        let summary = AsamSummaryView(asam: AsamModel(asam: newItem))
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
              
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
        
        let repository = AsamRepository(localDataSource: AsamCoreDataDataSource(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))

        let summary = AsamSummaryView(asam: AsamModel(asam: newItem), showMoreDetails: true)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
             
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .ViewDataSource,
                    object: nil) { notification in
            let vds = try! XCTUnwrap(notification.object as? ViewDataSource)
            let asam = try! XCTUnwrap(vds.dataSource as? AsamModel)
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
        
        let repository = AsamRepository(localDataSource: AsamCoreDataDataSource(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        
        let summary = AsamSummaryView(asam: AsamModel(asam: newItem), showMoreDetails: false)
            .environmentObject(repository)
              
            .environmentObject(bookmarkRepository)
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "focus")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let asams = tapNotification.items as! [Asam]
            XCTAssertEqual(asams.count, 1)
            XCTAssertEqual(asams[0].reference, "2022-100")
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapView(withAccessibilityLabel: "dismiss popup")
    }

}
