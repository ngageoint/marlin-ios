//
//  LightDetailViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/18/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class LightDetailViewTests: XCTestCase {

    func testLoading() {
        var light = LightModel()

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

        let localDataSource = LightStaticLocalDataSource()
        localDataSource.list = [light]
        let repository = LightRepository(localDataSource: localDataSource, remoteDataSource: LightRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(lightRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)

        let routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        let detailView = LightDetailView(featureNumber: light.featureNumber!, volumeNumber: light.volumeNumber!)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(routeWaypointRepository)

        let controller = UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "14840  PUB 110")
        tester().waitForView(withAccessibilityLabel: "-Outer.")
        tester().waitForView(withAccessibilityLabel: "Section")
        tester().waitForView(withAccessibilityLabel: "Yellow pedestal, red band; 7.")
        tester().waitForView(withAccessibilityLabel: light.range)
        tester().waitForView(withAccessibilityLabel: light.remarks)
        tester().waitForView(withAccessibilityLabel: light.expandedCharacteristic)
        tester().waitForView(withAccessibilityLabel: "Light image")

    }

    func xtestTapButtons() {
        var light = LightModel()

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

        let localDataSource = LightStaticLocalDataSource()
        localDataSource.list = [light]
        let repository = LightRepository(localDataSource: localDataSource, remoteDataSource: LightRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(lightRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)

        let routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        let detailView = LightDetailView(featureNumber: light.featureNumber!, volumeNumber: light.volumeNumber!)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(routeWaypointRepository)

        let controller = UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        // TODO: this is untestable b/c KIF thinks the button can become first responder so it fails to tap
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }

        tester().tapView(withAccessibilityLabel: "Location")
        waitForExpectations(timeout: 10, handler: nil)

        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let lightKeys = tapNotification.itemKeys!

            let lights = lightKeys[DataSources.light.key]!

            XCTAssertEqual(lights.count, 1)
            XCTAssertEqual(lights[0], light.itemKey)
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapView(withAccessibilityLabel: "dismiss popup")
        
        BookmarkHelper().verifyBookmarkButton(bookmarkable: light)
    }

//    func testLoadingWithColors() {
//        var newItem: Light?
//        persistentStore.viewContext.performAndWait {
//            let light = Light(context: persistentStore.viewContext)
//            
//            light.characteristicNumber = 1
//            light.volumeNumber = "PUB 110"
//            light.featureNumber = "14840"
//            light.noticeWeek = "06"
//            light.noticeYear = "2015"
//            light.latitude = 1.0
//            light.longitude = 2.0
//            light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
//            light.range = "W. 12 ; R. 9 ; G. 9"
//            light.sectionHeader = "Section"
//            light.structure = "Yellow pedestal, red band; 7.\n"
//            light.name = "-Outer."
//            
//            newItem = light
//            try? persistentStore.viewContext.save()
//        }
//        guard let newItem = newItem else {
//            XCTFail()
//            return
//        }
//        
//        let repository = LightRepositoryManager(repository: LightCoreDataRepository(context: persistentStore.viewContext))
//        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
//        
//        let detailView = newItem.detailView.environment(\.managedObjectContext, persistentStore.viewContext)
//            .environmentObject(repository)
//            .environmentObject(bookmarkRepository)
//        
//        let controller = UIHostingController(rootView: detailView)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        tester().waitForView(withAccessibilityLabel: "14840  PUB 110")
//        tester().waitForView(withAccessibilityLabel: "-Outer.")
//        tester().waitForView(withAccessibilityLabel: "Section")
//        tester().waitForView(withAccessibilityLabel: "Yellow pedestal, red band; 7.")
//        tester().waitForView(withAccessibilityLabel: newItem.range)
//        tester().waitForView(withAccessibilityLabel: newItem.remarks)
//        tester().waitForView(withAccessibilityLabel: newItem.expandedCharacteristic)
//        tester().waitForView(withAccessibilityLabel: "Light image")
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
//            let light = tapNotification.items as! [LightModel]
//            XCTAssertEqual(light.count, 1)
//            XCTAssertEqual(light[0].featureNumber, "14840")
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
//    }
//    
//    func testLightAndRacon() {
//        var newItem: Light?
//        var newItem2: Light?
//        persistentStore.viewContext.performAndWait {
//            let extraLight = Light(context: persistentStore.viewContext)
//            
//            extraLight.characteristicNumber = 1
//            extraLight.volumeNumber = "PUB 110"
//            extraLight.featureNumber = "14840"
//            extraLight.noticeWeek = "06"
//            extraLight.noticeYear = "2015"
//            extraLight.latitude = 1.0
//            extraLight.longitude = 2.0
//            extraLight.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
//            extraLight.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
//            extraLight.range = "W. 12 ; R. 9 ; G. 9"
//            extraLight.sectionHeader = "Section"
//            extraLight.structure = "Yellow pedestal, red band; 7.\n"
//            extraLight.name = "-Outer."
//            
//            let light = Light(context: persistentStore.viewContext)
//
//            light.volumeNumber = "PUB 114"
//            light.aidType = "Lighted Aids"
//            light.geopoliticalHeading = "ENGLAND-SCILLY ISLES"
//            light.regionHeading = nil
//            light.subregionHeading = nil
//            light.localHeading = nil
//            light.precedingNote = nil
//            light.featureNumber = "4"
//            light.internationalFeature = "A0002"
//            light.name = "Bishop Rock."
//            light.position = "49°52'21.4\"N \n6°26'44\"W"
//            light.characteristicNumber = 1
//            light.characteristic = "Fl.(2)W.\nperiod 15s \nfl. 0.1s, ec. 2.2s \n"
//            light.heightFeet = 144
//            light.heightMeters = 44
//            light.range = "20"
//            light.structure = "Gray round granite tower; 161.\nHelicopter platform. \n"
//            light.remarks = "Visible 233°-236° and 259°-204°.  Partially obscured 204°-211°.  AIS (MMSI No 992351137).\n"
//            light.postNote = nil
//            light.noticeNumber = 201516
//            light.removeFromList = "N"
//            light.deleteFlag = "Y"
//            light.noticeWeek = "16"
//            light.noticeYear = "2015"
//            light.latitude = 1.0
//            light.longitude = 2.0
//            light.sectionHeader = "Section"
//
//            let light2 = Light(context: persistentStore.viewContext)
//
//            light2.volumeNumber = "PUB 114"
//            light2.aidType = "Lighted Aids"
//            light2.geopoliticalHeading = "ENGLAND-SCILLY ISLES"
//            light2.regionHeading = nil
//            light2.subregionHeading = nil
//            light2.localHeading = nil
//            light2.precedingNote = nil
//            light2.featureNumber = "4"
//            light2.internationalFeature = "A0002"
//            light2.name = "RACON"
//            light2.position = "49°52'21.4\"N \n6°26'44\"W"
//            light2.characteristicNumber = 2
//            light2.characteristic = "T(- )\n"
//            light2.range = "18"
//            light2.structure = "Helicopter platform. \n"
//            light2.remarks = "Azimuth coverage 254°-215°.  (3 & 10cm).\n"
//            light2.postNote = nil
//            light2.noticeNumber = 201516
//            light2.removeFromList = "N"
//            light2.deleteFlag = "Y"
//            light2.noticeWeek = "16"
//            light2.noticeYear = "2015"
//            light2.latitude = 1.0
//            light2.longitude = 2.0
//            light2.sectionHeader = "Section"
//            
//            newItem = light
//            newItem2 = light2
//            try? persistentStore.viewContext.save()
//        }
//        guard let newItem = newItem else {
//            XCTFail()
//            return
//        }
//        guard let newItem2 = newItem2 else {
//            XCTFail()
//            return
//        }
//        
//        let repository = LightRepositoryManager(repository: LightCoreDataRepository(context: persistentStore.viewContext))
//        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
//        
//        let detailView = newItem.detailView.environment(\.managedObjectContext, persistentStore.viewContext)
//            .environmentObject(repository)
//            .environmentObject(bookmarkRepository)
//        
//        let controller = UIHostingController(rootView: detailView)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        tester().waitForView(withAccessibilityLabel: "4 A0002 PUB 114")
//        tester().waitForView(withAccessibilityLabel: "Section")
//        tester().waitForView(withAccessibilityLabel: "Bishop Rock.")
//        tester().waitForView(withAccessibilityLabel: "Gray round granite tower; 161.\nHelicopter platform.")
//        tester().waitForView(withAccessibilityLabel: "Focal Plane Elevation: 144ft (44m)")
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
//            let light = tapNotification.items as! [LightModel]
//            XCTAssertEqual(light.count, 1)
//            XCTAssertEqual(light[0].featureNumber, "4")
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
//        
//        tester().waitForView(withAccessibilityLabel: newItem.range)
//        tester().waitForView(withAccessibilityLabel: newItem.remarks)
//        tester().waitForView(withAccessibilityLabel: newItem.expandedCharacteristic)
//        tester().waitForView(withAccessibilityLabel: "Light image")
//        
//        tester().waitForView(withAccessibilityLabel: "Signal")
//        tester().waitForView(withAccessibilityLabel: "RACON")
//        tester().waitForView(withAccessibilityLabel: newItem2.remarks)
//        tester().waitForView(withAccessibilityLabel: newItem2.characteristic)
//    }
}
