////
////  BookmarkListTests.swift
////  MarlinTests
////
////  Created by Daniel Barela on 8/9/23.
////
//
//import XCTest
//import CoreData
//import Combine
//import SwiftUI
//
//@testable import Marlin
//
//final class BookmarkListTests: XCTestCase {
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
//    func testEmptyState() throws {
//        UserDefaults.standard.setSort(Asam.key, sort: [])
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
//            let asam2 = Asam(context: persistentStore.viewContext)
//            asam2.asamDescription = "description2"
//            asam2.longitude = 2.0
//            asam2.latitude = 2.0
//            asam2.date = Date(timeIntervalSince1970: 100000)
//            asam2.navArea = "XI"
//            asam2.reference = "2022-102"
//            asam2.subreg = "71"
//            asam2.position = "2°00'00\"N \n2°00'00\"E"
//            asam2.hostility = "Boarding2"
//            asam2.victim = "Boat2"
//            
//            try? persistentStore.viewContext.save()
//        }
//        
//        class PassThrough: ObservableObject {
//            
//        }
//        
//        struct Container: View {
//            @ObservedObject var passThrough: PassThrough
//            @State var path: NavigationPath = NavigationPath()
//            init(passThrough: PassThrough) {
//                self.passThrough = passThrough
//            }
//            
//            var body: some View {
//                NavigationStack(path: $path) {
//                    BookmarkListView(path: $path)
//                }
//            }
//        }
//        let appState = AppState()
//        let passThrough = PassThrough()
//        
//        let container = Container(passThrough: passThrough)
//            .environmentObject(appState)
//        
//        let controller = UIHostingController(rootView: container)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        
//        tester().waitForView(withAccessibilityLabel: "No Bookmarks")
//    }
//    
//    func testOneBookmark() throws {
//        UserDefaults.standard.setSort(Asam.key, sort: [])
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
//            let asam2 = Asam(context: persistentStore.viewContext)
//            asam2.asamDescription = "description2"
//            asam2.longitude = 2.0
//            asam2.latitude = 2.0
//            asam2.date = Date(timeIntervalSince1970: 100000)
//            asam2.navArea = "XI"
//            asam2.reference = "2022-102"
//            asam2.subreg = "71"
//            asam2.position = "2°00'00\"N \n2°00'00\"E"
//            asam2.hostility = "Boarding2"
//            asam2.victim = "Boat2"
//            
//            try? persistentStore.viewContext.save()
//        }
//        
//        struct Container: View {
//            @State var path: NavigationPath = NavigationPath()
//
//            var body: some View {
//                NavigationStack(path: $path) {
//                    BookmarkListView(path: $path)
//                }
//            }
//        }
//        let appState = AppState()
//        
//        let container = Container()
//            .environmentObject(appState)
//            .environment(\.managedObjectContext, persistentStore.viewContext)
//        
//        let controller = UIHostingController(rootView: container)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        
//        tester().waitForView(withAccessibilityLabel: "Cool bookmark notes")
//    }
//    
//    func testTwoBookmarksDifferentTypes() throws {
//        UserDefaults.standard.setSort(Asam.key, sort: [])
//        var bookmarkedModu: Modu?
//        var bookmarkedAsam: Asam?
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
//            bookmark.notes = "Cool ASAM bookmark notes"
//            
//            bookmarkedAsam = asam
//            
//            let asam2 = Asam(context: persistentStore.viewContext)
//            asam2.asamDescription = "description2"
//            asam2.longitude = 2.0
//            asam2.latitude = 2.0
//            asam2.date = Date(timeIntervalSince1970: 100000)
//            asam2.navArea = "XI"
//            asam2.reference = "2022-102"
//            asam2.subreg = "71"
//            asam2.position = "2°00'00\"N \n2°00'00\"E"
//            asam2.hostility = "Boarding2"
//            asam2.victim = "Boat2"
//            
//            let modu = Modu(context: persistentStore.viewContext)
//            
//            modu.name = "ABAN II"
//            modu.date = Date(timeIntervalSince1970: 0)
//            modu.rigStatus = "Active"
//            modu.specialStatus = "Wide Berth Requested"
//            modu.distance = 5
//            modu.latitude = 1.0
//            modu.longitude = 2.0
//            modu.position = "16°20'30.6\"N \n81°55'27\"E"
//            modu.navArea = "HYDROPAC"
//            modu.region = 6
//            modu.subregion = 63
//            
//            bookmarkedModu = modu
//            
//            let bookmark2 = Bookmark(context: persistentStore.viewContext)
//            bookmark2.id = modu.itemKey
//            bookmark2.dataSource = modu.key
//            bookmark2.timestamp = Date(timeIntervalSince1970: 10000)
//            bookmark2.notes = "Cool MODU bookmark notes"
//            
//            try? persistentStore.viewContext.save()
//        }
//        
//        struct Container: View {
//            @State var path: NavigationPath = NavigationPath()
//            
//            var body: some View {
//                NavigationStack(path: $path) {
//                    BookmarkListView(path: $path)
//                }
//            }
//        }
//        let appState = AppState()
//        
//        let container = Container()
//            .environmentObject(appState)
//            .environment(\.managedObjectContext, persistentStore.viewContext)
//        
//        let controller = UIHostingController(rootView: container)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        
//        tester().waitForView(withAccessibilityLabel: "Cool ASAM bookmark notes")
//        tester().waitForView(withAccessibilityLabel: "Cool MODU bookmark notes")
//        
//        tester().tapView(withAccessibilityLabel: "remove bookmark \(bookmarkedModu?.itemKey ?? "")")
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "remove bookmark \(bookmarkedModu?.itemKey ?? "")")
//        
//        tester().tapView(withAccessibilityLabel: "remove bookmark \(bookmarkedAsam?.itemKey ?? "")")
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "remove bookmark \(bookmarkedAsam?.itemKey ?? "")")
//        
//        tester().waitForView(withAccessibilityLabel: "No Bookmarks")
//    }
//}
