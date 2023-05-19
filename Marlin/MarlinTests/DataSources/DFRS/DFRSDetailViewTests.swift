//
//  DFRSDetailViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/24/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class DFRSDetailViewTests: XCTestCase {
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
    
    func testLoading() {
        var dfrs: DFRS?
        persistentStore.viewContext.performAndWait {
            let area = DFRSArea(context: persistentStore.viewContext)
            area.areaName = "CANADA"
            area.areaIndex = 30
            area.areaNote = "The VHF direction finding stations of Canada are for emergency use only. All stations are remotely controlled by a Marine Communications and Traffic Services Center (MCTS). The following details of operation are common to all of these stations:"
            area.index = 1
            area.indexNote = "A. Ch.16."
            let area2 = DFRSArea(context: persistentStore.viewContext)
            area2.areaName = "CANADA"
            area2.areaIndex = 30
            area2.areaNote = "The VHF direction finding stations of Canada are for emergency use only. All stations are remotely controlled by a Marine Communications and Traffic Services Center (MCTS). The following details of operation are common to all of these stations:"
            area2.index = 2
            area2.indexNote = "B. Ch.16 (distress only)."
            let area3 = DFRSArea(context: persistentStore.viewContext)
            area3.areaName = "CANADA"
            area3.areaIndex = 30
            area3.areaNote = "The VHF direction finding stations of Canada are for emergency use only. All stations are remotely controlled by a Marine Communications and Traffic Services Center (MCTS). The following details of operation are common to all of these stations:"
            area3.index = 3
            area3.indexNote = "C. Ch.16 (distress only)."
            
            let newItem = DFRS(context: persistentStore.viewContext)
            newItem.stationNumber = "1188.61\n2-1282"
            newItem.stationName = "Nos Galata Lt."
            newItem.stationType = "RDF"
            newItem.rxPosition = nil
            newItem.rxLongitude = -190.0
            newItem.rxLatitude = -190.0
            newItem.txPosition = "1°00'00\"N \n2°00'00\"E"
            newItem.txLongitude = 2.0
            newItem.txLatitude = 1.0
            newItem.frequency = "297.5 kHz, A2A."
            newItem.range = 5
            newItem.procedureText = "On request to Hydrographic Service, Varna."
            newItem.remarks = "Transmits !DG$."
            newItem.notes = "notes"
            newItem.areaName = "CANADA"
            
            dfrs = newItem
            try? persistentStore.viewContext.save()
        }
        
        guard let dfrs = dfrs else {
            XCTFail()
            return
        }
        
        let detailView = dfrs.detailView.environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "1188.61\n2-1282")
        tester().waitForView(withAccessibilityLabel: "Nos Galata Lt.")
        tester().waitForView(withAccessibilityLabel: "CANADA")
        tester().waitForView(withAccessibilityLabel: "notes")
        tester().waitForView(withAccessibilityLabel: "Transmits !DG$.")
        tester().waitForView(withAccessibilityLabel: "The VHF direction finding stations of Canada are for emergency use only. All stations are remotely controlled by a Marine Communications and Traffic Services Center (MCTS). The following details of operation are common to all of these stations:\nA. Ch.16.\nB. Ch.16 (distress only).\nC. Ch.16 (distress only).")
        
        tester().waitForAbsenceOfView(withAccessibilityLabel: "More Details")
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let dfrs = tapNotification.items as! [DFRS]
            XCTAssertEqual(dfrs.count, 1)
            XCTAssertEqual(dfrs[0].stationName, "Nos Galata Lt.")
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
