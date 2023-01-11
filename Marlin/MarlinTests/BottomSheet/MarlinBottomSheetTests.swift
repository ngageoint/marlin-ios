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
    
    private struct TestBottomSheet: View {
        @State var show: Bool = false
        @StateObject var bottomSheetItemList: BottomSheetItemList = BottomSheetItemList()
        var bottomSheetItems: [BottomSheetItem]
        
        var body: some View {
            HStack {
                Text("stack")
            }
            .bottomSheet(isPresented: $show) {
                MarlinBottomSheet(itemList: bottomSheetItemList)
            }
            .onAppear {
                self.bottomSheetItemList.bottomSheetItems = bottomSheetItems
                show.toggle()
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
        
        let bottomSheetItem = BottomSheetItem(item: newItem)
        
        let view = TestBottomSheet(bottomSheetItems: [bottomSheetItem])
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "stack")
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        
        expectation(forNotification: .ViewDataSource,
                    object: nil) { notification in
            
            let asam = try! XCTUnwrap(notification.object as? Asam)
            XCTAssertEqual(asam.hostility, "Boarding")
            XCTAssertEqual(asam.victim, "Boat")
            return true
        }
        tester().tapView(withAccessibilityLabel: "More Details")
        
        waitForExpectations(timeout: 10, handler: nil)
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
        
        let bottomSheetItem = BottomSheetItem(item: newItem)
        
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
        
        let bottomSheetItem2 = BottomSheetItem(item: newItem2)
        
        let view = TestBottomSheet(bottomSheetItems: [bottomSheetItem, bottomSheetItem2])
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "stack")
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        
        expectation(forNotification: .ViewDataSource,
                    object: nil) { notification in
            
            let asam = try! XCTUnwrap(notification.object as? Asam)
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
            
            let modu = try! XCTUnwrap(notification.object as? Modu)
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
            
            let asam = try! XCTUnwrap(notification.object as? Asam)
            XCTAssertEqual(asam.hostility, "Boarding")
            XCTAssertEqual(asam.victim, "Boat")
            return true
        }
        tester().tapView(withAccessibilityLabel: "More Details")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
