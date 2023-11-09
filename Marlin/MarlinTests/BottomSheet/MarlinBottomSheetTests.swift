//
//  MarlinBottomSheetTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/1/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class MarlinBottomSheetTests: XCTestCase {
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
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = nil
    }
    
    private struct TestBottomSheet: View {
        @State var show: Bool = false
        @StateObject var bottomSheetItemList: BottomSheetItemList = BottomSheetItemList()
        var bottomSheetItems: [BottomSheetItem]
        let dismissBottomSheetPub = NotificationCenter.default.publisher(for: .DismissBottomSheet)
        
        var body: some View {
            HStack {
                Text("stack")
            }
            .sheet(isPresented: $show) {
                MarlinBottomSheet(itemList: bottomSheetItemList, focusNotification: .FocusMapOnItem)
            }
            .onAppear {
                self.bottomSheetItemList.bottomSheetItems = bottomSheetItems
                show.toggle()
            }
            .onReceive(dismissBottomSheetPub) { output in
                if show {
                    show.toggle()
                }
            }
        }
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
        
        let bottomSheetItem = BottomSheetItem(item: newItem, zoom: false)
        
        let repository = AsamRepository(localDataSource: AsamCoreDataDataSource(context: persistentStore.viewContext), remoteDataSource: AsamRemoteDataSource())
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        
        let view = TestBottomSheet(bottomSheetItems: [bottomSheetItem])
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "stack")
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        
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
        
        NotificationCenter.default.post(name: .DismissBottomSheet, object: nil)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding: Boat")
    }
    
    func testMultipleItems() {
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
        
        let bottomSheetItem = BottomSheetItem(item: newItem, zoom: false)
        
        let newItem2 = Modu(context: persistentStore.viewContext)
        newItem2.name = "name"
        newItem2.date = Date(timeIntervalSince1970: 0)
        newItem2.rigStatus = "Inactive"
        newItem2.specialStatus = "Wide Berth Requested"
        newItem2.longitude = 1.0
        newItem2.latitude = 1.0
        newItem2.position = "1°00'00\"N \n1°00'00\"E"
        newItem2.navArea = "HYDROPAC"
        newItem2.region = 6
        newItem2.subregion = 63
        
        let bottomSheetItem2 = BottomSheetItem(item: newItem2, zoom: false)
        
        let repository = AsamRepository(localDataSource: AsamCoreDataDataSource(context: persistentStore.viewContext), remoteDataSource: AsamRemoteDataSource())
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        let moduRepository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
        
        let view = TestBottomSheet(bottomSheetItems: [bottomSheetItem, bottomSheetItem2])
            .environmentObject(repository)
            .environmentObject(moduRepository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "stack")
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        
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
        
        tester().tapView(withAccessibilityLabel: "next")
        
        tester().waitForView(withAccessibilityLabel: "name")
        
        expectation(forNotification: .ViewDataSource,
                    object: nil) { notification in
            let vds = try! XCTUnwrap(notification.object as? ViewDataSource)
            let modu = try! XCTUnwrap(vds.dataSource as? ModuModel)
            XCTAssertEqual(modu.name, "name")
            XCTAssertEqual(modu.rigStatus, "Inactive")
            return true
        }
        tester().tapView(withAccessibilityLabel: "More Details")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().tapView(withAccessibilityLabel: "previous")
        tester().waitForView(withAccessibilityLabel: "stack")
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        
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
        
        NotificationCenter.default.post(name: .DismissBottomSheet, object: nil)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding: Boat")
    }
}
