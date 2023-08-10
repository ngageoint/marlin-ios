//
//  LightSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/18/23.
//

import XCTest

import Combine
import SwiftUI

@testable import Marlin

final class LightSummaryViewTests: XCTestCase {
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
        
        var newItem: Light?
        
        persistentStore.viewContext.performAndWait {
            let light = Light(context: persistentStore.viewContext)
            
            light.characteristicNumber = 1
            light.volumeNumber = "PUB 110"
            light.featureNumber = "14840"
            light.noticeWeek = "06"
            light.noticeYear = "2015"
            light.latitude = 1.0
            light.longitude = 2.0
            light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
            light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
            light.range = "W. 12 ; R. 9 ; G. 9"
            light.sectionHeader = "Section"
            light.structure = "Yellow pedestal, red band; 7.\n"
            light.name = "-Outer."
            
            try? persistentStore.viewContext.save()
            newItem = light
        }
        
        guard let light = newItem else {
            XCTFail()
            return
        }

        let summary = light.summary
            .setShowMoreDetails(false)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "14840  PUB 110")
        tester().waitForView(withAccessibilityLabel: "-Outer.")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Section")
        tester().waitForView(withAccessibilityLabel: "Yellow pedestal, red band; 7.")
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertEqual(model?.snackbarModel?.message, "Location \(UserDefaults.standard.coordinateDisplay.format(coordinate: light.coordinate)) copied to clipboard")
            XCTAssertEqual(UIPasteboard.general.string, "\(UserDefaults.standard.coordinateDisplay.format(coordinate: light.coordinate))")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let light = tapNotification.items as! [Light]
            XCTAssertEqual(light.count, 1)
            XCTAssertEqual(light[0].featureNumber, "14840")
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "Close")
        tester().tapView(withAccessibilityLabel: "Close")
        
        BookmarkHelper().verifyBookmarkButton(viewContext: persistentStore.viewContext, bookmarkable: light)
    }
    
    func testShowMoreDetails() {
        let light = Light(context: persistentStore.viewContext)
        
        light.characteristicNumber = 1
        light.volumeNumber = "PUB 110"
        light.featureNumber = "14840"
        light.noticeWeek = "06"
        light.noticeYear = "2015"
        light.latitude = 1.0
        light.longitude = 2.0
        light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
        light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
        light.range = "W. 12 ; R. 9 ; G. 9"
        light.sectionHeader = "Section"
        light.structure = "Yellow pedestal, red band; 7.\n"
        light.name = "-Outer."
        
        let summary = light.summary
            .setShowMoreDetails(true)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "14840  PUB 110")
        tester().waitForView(withAccessibilityLabel: "-Outer.")
        tester().waitForView(withAccessibilityLabel: "Section")
        tester().waitForView(withAccessibilityLabel: "Yellow pedestal, red band; 7.")
        
        expectation(forNotification: .ViewDataSource,
                    object: nil) { notification in
            let vds = try! XCTUnwrap(notification.object as? ViewDataSource)
            let light = try! XCTUnwrap(vds.dataSource as? Light)
            XCTAssertEqual(light.featureNumber, "14840")
            return true
        }
        tester().tapView(withAccessibilityLabel: "More Details")
        
        waitForExpectations(timeout: 10, handler: nil)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
    }
}
