//
//  AsamDetailViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/30/22.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class AsamDetailViewTests: XCTestCase {
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        Task.init {
            await TestHelpers.asyncGetKeyWindowVisible()
        }
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
        var newItem: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            newItem = asam
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        
        let repository = AsamRepositoryManager(repository: AsamCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        let view = AsamDetailView(reference: newItem.reference!)
            .environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        tester().waitForView(withAccessibilityLabel: newItem.asamDescription)
        tester().waitForView(withAccessibilityLabel: newItem.hostility)
        tester().waitForView(withAccessibilityLabel: newItem.victim)
        tester().waitForView(withAccessibilityLabel: newItem.reference)
        tester().waitForView(withAccessibilityLabel: newItem.subreg)
        tester().waitForView(withAccessibilityLabel: newItem.navArea)
        tester().waitForView(withAccessibilityLabel: newItem.dateString)

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
        var newItem: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = nil
            asam.victim = "Boat"
            
            newItem = asam
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let repository = AsamRepositoryManager(repository: AsamCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))

        let summary = AsamDetailView(reference: newItem.reference!)
            .environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boat")
        tester().waitForView(withAccessibilityLabel: newItem.asamDescription)
        tester().waitForView(withAccessibilityLabel: newItem.hostility)
        tester().waitForView(withAccessibilityLabel: newItem.victim)
        tester().waitForView(withAccessibilityLabel: newItem.reference)
        tester().waitForView(withAccessibilityLabel: newItem.subreg)
        tester().waitForView(withAccessibilityLabel: newItem.navArea)
        tester().waitForView(withAccessibilityLabel: newItem.dateString)

        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testLoadingNoVictim() {
        var newItem: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = nil
            
            newItem = asam
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let repository = AsamRepositoryManager(repository: AsamCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))

        let summary = AsamDetailView(reference: newItem.reference!)
            .environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boarding")

        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")

        waitForExpectations(timeout: 10, handler: nil)
    }

}
