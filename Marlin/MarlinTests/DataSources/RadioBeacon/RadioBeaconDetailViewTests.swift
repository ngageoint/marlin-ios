//
//  RadioBeaconDetailViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class RadioBeaconDetailViewTests: XCTestCase {
    func testLoading() {
        XCTFail()
    }
//    var cancellable = Set<AnyCancellable>()
//    var persistentStore: PersistentStore = PersistenceController.shared
//    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
//        .receive(on: RunLoop.main)
//    
//    override func setUp(completion: @escaping (Error?) -> Void) {
//        for item in DataSourceList().allTabs {
//            UserDefaults.standard.initialDataLoaded = false
//            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource.definition)
//        }
//        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
//        
//        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
//        persistentStoreLoadedPub
//            .removeDuplicates()
//            .sink { output in
//                completion(nil)
//            }
//            .store(in: &cancellable)
//        persistentStore.reset()
//    }
//    
//    override func tearDown() {
//    }
//    
//    func testLoading() {
//        var newItem: RadioBeacon?
//        persistentStore.viewContext.performAndWait {
//            let rb = RadioBeacon(context: persistentStore.viewContext)
//            
//            rb.volumeNumber = "PUB 110"
//            rb.aidType = "Radiobeacons"
//            rb.geopoliticalHeading = "GREENLAND"
//            rb.regionHeading = "region heading"
//            rb.precedingNote = "preceding note"
//            rb.featureNumber = 10
//            rb.name = "Ittoqqortoormit, Scoresbysund"
//            rb.position = "70°29'11.99\"N \n21°58'20\"W"
//            rb.characteristic = "SC\n(• • •  - • - • ).\n"
//            rb.range = 200
//            rb.sequenceText = "sequence text"
//            rb.frequency = "343\nNON, A2A."
//            rb.stationRemark = "Aeromarine."
//            rb.postNote = "post note"
//            rb.noticeNumber = 199706
//            rb.removeFromList = "N"
//            rb.deleteFlag = "N"
//            rb.noticeWeek = "06"
//            rb.noticeYear = "1997"
//            rb.latitude = 1.0
//            rb.longitude = 2.0
//            rb.sectionHeader = "section"
//            
//            newItem = rb
//            try? persistentStore.viewContext.save()
//        }
//        
//        guard let newItem = newItem else {
//            XCTFail()
//            return
//        }
//        
//        let repository = RadioBeaconRepositoryManager(repository: RadioBeaconCoreDataRepository(context: persistentStore.viewContext))
//        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
//        
//        let detailView = newItem.detailView.environment(\.managedObjectContext, persistentStore.viewContext)
//            .environmentObject(repository)
//            .environmentObject(bookmarkRepository)
//        
//        let controller = UIHostingController(rootView: detailView)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        tester().waitForView(withAccessibilityLabel: "\(newItem.featureNumber) \(newItem.volumeNumber!)")
//        tester().waitForView(withAccessibilityLabel: newItem.name)
//        tester().waitForView(withAccessibilityLabel: "section")
//        tester().waitForView(withAccessibilityLabel: newItem.morseLetter)
//        tester().waitForView(withAccessibilityLabel: newItem.expandedCharacteristicWithoutCode)
//        tester().waitForView(withAccessibilityLabel: newItem.stationRemark)
//        
//        expectation(forNotification: .SnackbarNotification,
//                    object: nil) { notification in
//            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
//            XCTAssertEqual(model?.snackbarModel?.message, "Location \(UserDefaults.standard.coordinateDisplay.format(coordinate: newItem.coordinate)) copied to clipboard")
//            XCTAssertEqual(UIPasteboard.general.string, "\(UserDefaults.standard.coordinateDisplay.format(coordinate: newItem.coordinate))")
//            return true
//        }
//        tester().tapView(withAccessibilityLabel: "Location")
//        
//        expectation(forNotification: .TabRequestFocus,
//                    object: nil) { notification in
//            return true
//        }
//        
//        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
//            
//            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
//            let rb = tapNotification.items as! [RadioBeaconModel]
//            XCTAssertEqual(rb.count, 1)
//            XCTAssertEqual(rb[0].name, "Ittoqqortoormit, Scoresbysund")
//            return true
//        }
//        tester().tapView(withAccessibilityLabel: "focus")
//        
//        waitForExpectations(timeout: 10, handler: nil)
//        
//        tester().waitForView(withAccessibilityLabel: "share")
//        tester().tapView(withAccessibilityLabel: "share")
//        
//        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
//        tester().tapView(withAccessibilityLabel: "dismiss popup")
//
//        tester().waitForView(withAccessibilityLabel: "Number")
//        tester().waitForView(withAccessibilityLabel: "Name & Location")
//        tester().waitForView(withAccessibilityLabel: "Geopolitical Heading")
//        tester().waitForView(withAccessibilityLabel: "Position")
//        tester().waitForView(withAccessibilityLabel: "Characteristic")
//        tester().waitForView(withAccessibilityLabel: "Range (nmi)")
//        tester().waitForView(withAccessibilityLabel: "Sequence")
//        tester().waitForView(withAccessibilityLabel: "Frequency (kHz)")
//        tester().waitForView(withAccessibilityLabel: "Remarks")
//        
//        tester().waitForView(withAccessibilityLabel: "\(newItem.featureNumber)")
//        tester().waitForView(withAccessibilityLabel: newItem.name)
//        tester().waitForView(withAccessibilityLabel: newItem.geopoliticalHeading)
//        tester().waitForView(withAccessibilityLabel: "\(newItem.position ?? "")")
//        tester().waitForView(withAccessibilityLabel: newItem.expandedCharacteristic)
//        tester().waitForView(withAccessibilityLabel: "\(newItem.range)")
//        tester().waitForView(withAccessibilityLabel: newItem.sequenceText)
//        tester().waitForView(withAccessibilityLabel: newItem.frequency)
//        tester().waitForView(withAccessibilityLabel: newItem.stationRemark)
//        
//        BookmarkHelper().verifyBookmarkButton(viewContext: persistentStore.viewContext, bookmarkable: newItem)
//    }
}

