//
//  DifferentialGPSStationDetailViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/12/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class DifferentialGPSStationDetailViewTests: XCTestCase {
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
        var newItem: DifferentialGPSStation?
        persistentStore.viewContext.performAndWait {
            let dgps = DifferentialGPSStation(context: persistentStore.viewContext)
            dgps.volumeNumber = "PUB 112"
            dgps.aidType = "Differential GPS Stations"
            dgps.geopoliticalHeading = "KOREA"
            dgps.regionHeading = "region heading"
            dgps.sectionHeader = "KOREA: region heading"
            dgps.precedingNote = "preceeding note"
            dgps.featureNumber = 6
            dgps.name = "Chojin Dan Lt"
            dgps.position = "1°00'00\"N \n2°00'00.00\"E"
            dgps.latitude = 1.0
            dgps.longitude = 2.0
            dgps.stationID = "T670\nR740\nR741"
            dgps.range = 100
            dgps.frequency = 292
            dgps.transferRate = 200
            dgps.remarks = "Message types: 3, 5, 7, 9, 16."
            dgps.postNote = "post note"
            dgps.noticeNumber = 201134
            dgps.removeFromList = "N"
            dgps.deleteFlag = "N"
            dgps.noticeWeek = "34"
            dgps.noticeYear = "2011"
            
            newItem = dgps
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let repository = DifferentialGPSStationRepositoryManager(repository: DifferentialGPSStationCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        
        let view = newItem.detailView
            .environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "6 PUB 112")
        tester().waitForView(withAccessibilityLabel: "\(newItem.featureNumber)")
        tester().waitForView(withAccessibilityLabel: newItem.name)
        tester().waitForView(withAccessibilityLabel: newItem.geopoliticalHeading)
        tester().waitForView(withAccessibilityLabel: newItem.position)
        tester().waitForView(withAccessibilityLabel: newItem.stationID)
        tester().waitForView(withAccessibilityLabel: "\(newItem.range)")
        tester().waitForView(withAccessibilityLabel: "\(newItem.frequency)")
        tester().waitForView(withAccessibilityLabel: "\(newItem.transferRate)")
        tester().waitForView(withAccessibilityLabel: newItem.remarks)
        tester().waitForView(withAccessibilityLabel: "\(newItem.noticeNumber)")
        tester().waitForView(withAccessibilityLabel: newItem.precedingNote)
        tester().waitForView(withAccessibilityLabel: newItem.postNote)

        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        BookmarkHelper().verifyBookmarkButton(viewContext: persistentStore.viewContext, bookmarkable: newItem)
    }
}
