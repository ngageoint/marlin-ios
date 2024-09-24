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
    
    func testLoading() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var newItem = AsamModel()
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
        
        let bottomSheetItem = BottomSheetItem(zoom: false, itemKey: newItem.itemKey, dataSourceKey: DataSources.asam.key)

        let localDataSource = AsamStaticLocalDataSource()
        InjectedValues[\.asamLocalDataSource] = localDataSource
//        let remoteDataSource = AsamStaticRemoteDataSource()
//        InjectedValues[\.asamRemoteDataSource]
        localDataSource.list.append(newItem)
        let repository = AsamRepository()
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        let router = MarlinRouter()
        let view = TestBottomSheet(bottomSheetItems: [bottomSheetItem])
//            .environmentObject(repository)
            .environmentObject(router)

        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "stack")
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")

        XCTAssertEqual(router.path.count, 0)
        tester().tapView(withAccessibilityLabel: "More Details")
        XCTAssertEqual(router.path.count, 1)

        NotificationCenter.default.post(name: .DismissBottomSheet, object: nil)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding: Boat")
    }
    
    func testMultipleItems() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var newItem = AsamModel()
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
        
        let bottomSheetItem = BottomSheetItem(zoom: false, itemKey: newItem.itemKey, dataSourceKey: DataSources.asam.key)

        var newItem2 = ModuModel()
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
        
        let bottomSheetItem2 = BottomSheetItem(zoom: false, itemKey: newItem2.itemKey, dataSourceKey: DataSources.modu.key)

        let localDataSource = AsamStaticLocalDataSource()
        InjectedValues[\.asamLocalDataSource] = localDataSource
//        let remoteDataSource = AsamStaticRemoteDataSource()
//        InjectedValues[\.asamRemoteDataSource] = remoteDataSource
        localDataSource.list.append(newItem)
        let repository = AsamRepository()
        let moduLocalDataSource = ModuStaticLocalDataSource()
        InjectedValues[\.moduLocalDataSource] = moduLocalDataSource
        
        let moduRemoteDataSource = ModuRemoteDataSource()
        InjectedValues[\.moduRemoteDataSource] = moduRemoteDataSource
        
        moduLocalDataSource.list.append(newItem2)
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        let router = MarlinRouter()
        let view = TestBottomSheet(bottomSheetItems: [bottomSheetItem, bottomSheetItem2])
//            .environmentObject(repository)
            .environmentObject(router)

        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "stack")
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")

        // TODO: would be nice to verify the path contains the correct item but I cannot find a way to mock it
        XCTAssertEqual(router.path.count, 0)
        tester().tapView(withAccessibilityLabel: "More Details")
        XCTAssertEqual(router.path.count, 1)

        tester().tapView(withAccessibilityLabel: "next")
        
        tester().waitForView(withAccessibilityLabel: "name")
        
        XCTAssertEqual(router.path.count, 1)
        tester().tapView(withAccessibilityLabel: "More Details")
        XCTAssertEqual(router.path.count, 2)

        tester().tapView(withAccessibilityLabel: "previous")
        tester().waitForView(withAccessibilityLabel: "stack")
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        
        XCTAssertEqual(router.path.count, 2)
        tester().tapView(withAccessibilityLabel: "More Details")
        XCTAssertEqual(router.path.count, 3)

        NotificationCenter.default.post(name: .DismissBottomSheet, object: nil)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding: Boat")
    }
}
