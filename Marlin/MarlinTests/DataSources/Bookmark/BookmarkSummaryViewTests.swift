////
////  BookmarkSummaryViewTests.swift
////  MarlinTests
////
////  Created by Daniel Barela on 8/10/23.
////
//
//import XCTest
//
//import CoreData
//import Combine
//import SwiftUI
//
//@testable import Marlin
//
//final class BookmarkSummaryViewTests: XCTestCase {
//    
//    var cancellable = Set<AnyCancellable>()
//    var persistentStore: PersistentStore = PersistenceController.shared
//    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
//        .receive(on: RunLoop.main)
//    
//    override func setUp(completion: @escaping (Error?) -> Void) {
//        for item in DataSourceList().allTabs {
//            UserDefaults.standard.initialDataLoaded = false
//            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource as! any BatchImportable.Type)
//            UserDefaults.standard.setFilter(item.key, filter: [])
//            UserDefaults.standard.setSort(item.key, sort: item.dataSource.defaultSort)
//            
//            persistentStore.viewContext.performAndWait {
//                if let managed = item.dataSource as? NSManagedObject.Type {
//                    if let objects = persistentStore.viewContext.fetchAll(managed.self) {
//                        for object in objects {
//                            persistentStore.viewContext.delete(object)
//                        }
//                    }
//                }
//            }
//        }
//        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
//        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
//        
//        persistentStoreLoadedPub
//            .removeDuplicates()
//            .sink { output in
//                let e5 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
//                    if let count = try? self.persistentStore.countOfObjects(Asam.self) {
//                        return count == 0
//                    }
//                    return false
//                }), object: self.persistentStore.viewContext)
//                self.wait(for: [e5], timeout: 10)
//                completion(nil)
//            }
//            .store(in: &cancellable)
//        persistentStore.reset()
//        
//    }
//    override func tearDown(completion: @escaping (Error?) -> Void) {
//        persistentStore.viewContext.performAndWait {
//            for item in DataSourceList().allTabs {
//                if let managed = item.dataSource as? NSManagedObject.Type {
//                    if let objects = persistentStore.viewContext.fetchAll(managed.self) {
//                        for object in objects {
//                            persistentStore.viewContext.delete(object)
//                        }
//                    }
//                }
//            }
//        }
//        completion(nil)
//    }
//    
//    func testSummary() throws {
//        var newBookmark: Bookmark?
//        persistentStore.viewContext.performAndWait {
//            let asam = Asam(context: persistentStore.viewContext)
//            asam.asamDescription = "description"
//            asam.longitude = 1.0
//            asam.latitude = 1.0
//            asam.date = Date()
//            asam.navArea = "XI"
//            asam.reference = "2022-100"
//            asam.subreg = "71"
//            asam.position = "1°00'00\"N \n1°00'00\"E"
//            asam.hostility = "Boarding"
//            asam.victim = "Boat"
//            
//            let bookmark = Bookmark(context: persistentStore.viewContext)
//            bookmark.id = asam.itemKey
//            bookmark.dataSource = asam.key
//            bookmark.timestamp = Date(timeIntervalSince1970: 10000)
//            bookmark.notes = "Cool bookmark notes"
//            
//            newBookmark = bookmark
//            try? persistentStore.viewContext.save()
//        }
//        
//        guard let bookmark = newBookmark else {
//            XCTFail()
//            return
//        }
//        let summary = BookmarkSummary(bookmark: bookmark)
//            .environment(\.managedObjectContext, persistentStore.viewContext)
//        let controller = UIHostingController(rootView: summary)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        
//        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
//        tester().waitForView(withAccessibilityLabel: "Cool bookmark notes")
//    }
//}
