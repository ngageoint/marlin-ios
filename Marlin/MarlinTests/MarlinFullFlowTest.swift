//
//  MarlinFullFlowTest.swift
//  MarlinTests
//
//  Created by Daniel Barela on 6/1/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class MarlinFullFlowTest: XCTestCase {
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    let scheme = MarlinScheme()
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        Task.init {
            await TestHelpers.asyncGetKeyWindowVisible()
        }
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
        
        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = true
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource as! any BatchImportable.Type)
        }
                
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                TestHelpers.clearData()
                for dataSource in MSI.shared.masterDataList {
                    switch dataSource {
                    case let mapImage as MapImage.Type:
                        mapImage.imageCache.clearCache()
                    default:
                        continue
                    }
                }
                
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
    }
    
    func testMapTapBottomSheetShowDetails() {
        guard let asam = TestHelpers.createAsam(persistentStore.viewContext) else {
            XCTFail()
            return
        }
        guard let modu = TestHelpers.createModu(persistentStore.viewContext) else {
            XCTFail()
            return
        }
        guard let port = TestHelpers.createPort(persistentStore.viewContext) else {
            XCTFail()
            return
        }
        guard let dfrs = TestHelpers.createDFRS(persistentStore.viewContext) else {
            XCTFail()
            return
        }
        guard let radioBeacon = TestHelpers.createRadioBeacon(persistentStore.viewContext) else {
            XCTFail()
            return
        }
        guard let light = TestHelpers.createLight(persistentStore.viewContext) else {
            XCTFail()
            return
        }
        guard let navigationalWarningPolygon = TestHelpers.createNavigationalWarningPolygon(persistentStore.viewContext) else {
            XCTFail()
            return
        }
        guard let navigationalWarningLine = TestHelpers.createNavigationalWarningLine(persistentStore.viewContext) else {
            XCTFail()
            return
        }
        guard let navigationalWarningPoint = TestHelpers.createNavigationalWarningPoint(persistentStore.viewContext) else {
            XCTFail()
            return
        }
        guard let navigationalWarningMultipoint = TestHelpers.createNavigationalWarningMultiPoint(persistentStore.viewContext) else {
            XCTFail()
            return
        }
        guard let navigationalWarningCircle = TestHelpers.createNavigationalWarningCircle(persistentStore.viewContext) else {
            XCTFail()
            return
        }
        guard let differentialGPSStation = TestHelpers.createDifferentialGPSStation(persistentStore.viewContext) else {
            XCTFail()
            return
        }
        
        for dataSource in MSI.shared.masterDataList {
            switch dataSource {
            case let mapImage as MapImage.Type:
                mapImage.imageCache.clearCache()
            default:
                continue
            }
        }
        
        let appState: AppState = MSI.shared.appState
        UserDefaults.standard.setValue(true, forKey: "onboardingComplete")
        UserDefaults.standard.setValue(true, forKey: "disclaimerAccepted")
        let dataSourceList: DataSourceList = DataSourceList()
        
        let view = MarlinView()
            .environmentObject(LocationManager.shared())
            .environmentObject(appState)
            .environmentObject(dataSourceList)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
        NotificationCenter.default.post(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: navigationalWarningPolygon))
//        tester().wait(forTimeInterval: 10)
        
        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(annotations: nil, items: [asam, modu, port, dfrs, radioBeacon, light, navigationalWarningPolygon, navigationalWarningLine, navigationalWarningPoint, navigationalWarningMultipoint, navigationalWarningCircle, differentialGPSStation], mapName: nil))
//        tester().wait(forTimeInterval: 5)
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        tester().tapView(withAccessibilityLabel: "next")
        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().tapView(withAccessibilityLabel: "next")
        tester().waitForView(withAccessibilityLabel: "Aasiaat")
        tester().tapView(withAccessibilityLabel: "next")
        tester().waitForView(withAccessibilityLabel: "Nos Galata Lt.")
        tester().tapView(withAccessibilityLabel: "next")
        tester().waitForView(withAccessibilityLabel: "Ittoqqortoormit, Scoresbysund")
        tester().tapView(withAccessibilityLabel: "next")
        tester().waitForView(withAccessibilityLabel: "Bishop Rock.")
        tester().tapView(withAccessibilityLabel: "next")
        tester().waitForView(withAccessibilityLabel: navigationalWarningPolygon.itemTitle)
//        tester().wait(forTimeInterval: 10)
        tester().tapView(withAccessibilityLabel: "next")
        tester().waitForView(withAccessibilityLabel: navigationalWarningLine.itemTitle)
//        tester().wait(forTimeInterval: 5)
        tester().tapView(withAccessibilityLabel: "next")
        tester().waitForView(withAccessibilityLabel: navigationalWarningPoint.itemTitle)
//        tester().wait(forTimeInterval: 5)
        tester().tapView(withAccessibilityLabel: "next")
        tester().waitForView(withAccessibilityLabel: navigationalWarningMultipoint.itemTitle)
//        tester().wait(forTimeInterval: 5)
        tester().tapView(withAccessibilityLabel: "next")
        tester().waitForView(withAccessibilityLabel: navigationalWarningCircle.itemTitle)
//        tester().wait(forTimeInterval: 5)
        tester().tapView(withAccessibilityLabel: "next")
        tester().waitForView(withAccessibilityLabel: "Chojin Dan Lt")
        
        
        tester().waitForTappableView(withAccessibilityLabel: "More Details")
        tester().tapView(withAccessibilityLabel: "More Details")
        tester().waitForView(withAccessibilityLabel: "Chojin Dan Lt")
        tester().waitForTappableView(withAccessibilityLabel: "Marlin")
        tester().tapView(withAccessibilityLabel: "Marlin", traits: .button)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Chojin Dan Lt")
        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
    }
}
