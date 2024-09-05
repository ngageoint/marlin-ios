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

//    var cancellable = Set<AnyCancellable>()
//    var persistentStore: PersistentStore = PersistenceController.shared
//    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
//        .receive(on: RunLoop.main)
//    
//    let scheme = MarlinScheme()
//    
//    override func setUp(completion: @escaping (Error?) -> Void) {
//        Task.init {
//            await TestHelpers.asyncGetKeyWindowVisible()
//        }
//        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
//        UserDefaults.registerMarlinDefaults()
//        
//        for item in DataSourceList().allTabs {
//            UserDefaults.standard.initialDataLoaded = true
//            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource.definition)
//        }
//                
//        persistentStoreLoadedPub
//            .removeDuplicates()
//            .sink { output in
//                TestHelpers.clearData()
//                for dataSource in MSI.shared.mainDataList {
//                    switch dataSource {
//                    case let mapImage as MapImage.Type:
//                        mapImage.imageCache.clearCache()
//                    default:
//                        continue
//                    }
//                }
//                
//                completion(nil)
//            }
//            .store(in: &cancellable)
//        persistentStore.reset()
//    }
//    
//    // TODO: this is failing when trying to tap the second tab
//    func xtestNavigateToTabFocusOnMap() {
//        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
//        let asamRepository = AsamRepository(localDataSource: AsamCoreDataDataSource(context: persistentStore.viewContext), remoteDataSource: AsamRemoteDataSource())
//        let moduRepository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
//        let lightRepository = LightRepositoryManager(repository: LightCoreDataRepository(context: persistentStore.viewContext))
//        let portRepository = PortRepositoryManager(repository: PortCoreDataRepository(context: persistentStore.viewContext))
//        let dgpsRepository = DifferentialGPSStationRepositoryManager(repository: DifferentialGPSStationCoreDataRepository(context: persistentStore.viewContext))
//        let radioBeaconRepository = RadioBeaconRepositoryManager(repository: RadioBeaconCoreDataRepository(context: persistentStore.viewContext))
//        let routeRepository = RouteRepositoryManager(repository: RouteCoreDataRepository(context: persistentStore.viewContext))
//        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointCoreDataDataSource(context: persistentStore.viewContext))
//        
//        guard let objects = TestHelpers.createOneOfEachType(persistentStore.viewContext) else {
//            XCTFail()
//            return
//        }
//        
//        for dataSource in MSI.shared.mainDataList {
//            switch dataSource {
//            case let mapImage as MapImage.Type:
//                mapImage.imageCache.clearCache()
//            default:
//                continue
//            }
//        }
//        
//        let appState: AppState = MSI.shared.appState
//        UserDefaults.standard.setValue(true, forKey: "onboardingComplete")
//        UserDefaults.standard.setValue(true, forKey: "disclaimerAccepted")
//        UserDefaults.standard.setFilter(Asam.key, filter: [])
//        let dataSourceList: DataSourceList = DataSourceList()
//        // set up the tabs to only be 1
//        for tab in dataSourceList.tabs {
//            dataSourceList.addItemToNonTabs(dataSourceItem: tab, position: 0)
//        }
//        // find the datasourceitem and move it back to a tab
//        for item in dataSourceList.nonTabs {
//            if item.key == Asam.key {
//                dataSourceList.addItemToTabs(dataSourceItem: item, position: 0)
//                break
//            }
//        }
//        
//        let view = MarlinView()
//            .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
//            .environmentObject(LocationManager.shared())
//            .environmentObject(appState)
//            .environmentObject(dataSourceList)
//            .environmentObject(bookmarkRepository)
//            .environmentObject(asamRepository)
//            .environmentObject(moduRepository)
//            .environmentObject(lightRepository)
//            .environmentObject(portRepository)
//            .environmentObject(dgpsRepository)
//            .environmentObject(radioBeaconRepository)
//            .environmentObject(routeRepository)
//            .environmentObject(routeWaypointRepository)
//        
//        let controller = UIHostingController(rootView: view)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        tester().waitForView(withAccessibilityLabel: "\(Asam.key)List")
//        tester().tapView(withAccessibilityLabel: "\(Asam.key)List")
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Marlin Map")
//        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
//        tester().tapView(withAccessibilityLabel: "focus")
//        // should switch tabs
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        // bottom sheet should show up
//        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
//        NotificationCenter.default.post(name: .DismissBottomSheet, object: nil)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding: Boat")
//        
//        // Modu
//        for item in dataSourceList.nonTabs {
//            if item.key == Modu.key {
//                dataSourceList.addItemToTabs(dataSourceItem: item, position: 0)
//                break
//            }
//        }
//        tester().waitForTappableView(withAccessibilityLabel: "\(Modu.key)List")
//        TestHelpers.printAllAccessibilityLabelsInWindows()
//        tester().tapView(withAccessibilityLabel: "\(Modu.key)List")
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Marlin Map")
//        tester().waitForView(withAccessibilityLabel: "ABAN II")
//        tester().tapView(withAccessibilityLabel: "focus")
//        // should switch tabs
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        // bottom sheet should show up
//        tester().waitForView(withAccessibilityLabel: "ABAN II")
//        NotificationCenter.default.post(name: .DismissBottomSheet, object: nil)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "ABAN II")
//        
//        // Port
//        for item in dataSourceList.nonTabs {
//            if item.key == Port.key {
//                dataSourceList.addItemToTabs(dataSourceItem: item, position: 0)
//                break
//            }
//        }
//        tester().waitForView(withAccessibilityLabel: "\(Port.key)List")
//        tester().tapView(withAccessibilityLabel: "\(Port.key)List")
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Marlin Map")
//        tester().waitForView(withAccessibilityLabel: "Aasiaat")
//        tester().tapView(withAccessibilityLabel: "focus")
//        // should switch tabs
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        // bottom sheet should show up
//        tester().waitForView(withAccessibilityLabel: "Aasiaat")
//        NotificationCenter.default.post(name: .DismissBottomSheet, object: nil)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Aasiaat")
//        
//        // RadioBeacon
//        for item in dataSourceList.nonTabs {
//            if item.key == RadioBeacon.key {
//                dataSourceList.addItemToTabs(dataSourceItem: item, position: 0)
//                break
//            }
//        }
//        tester().waitForView(withAccessibilityLabel: "\(RadioBeacon.key)List")
//        tester().tapView(withAccessibilityLabel: "\(RadioBeacon.key)List")
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Marlin Map")
//        tester().waitForView(withAccessibilityLabel: "Ittoqqortoormit, Scoresbysund")
//        tester().tapView(withAccessibilityLabel: "focus")
//        // should switch tabs
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        // bottom sheet should show up
//        tester().waitForView(withAccessibilityLabel: "Ittoqqortoormit, Scoresbysund")
//        NotificationCenter.default.post(name: .DismissBottomSheet, object: nil)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Ittoqqortoormit, Scoresbysund")
//        
//        // Light
//        for item in dataSourceList.nonTabs {
//            if item.key == Light.key {
//                dataSourceList.addItemToTabs(dataSourceItem: item, position: 0)
//                break
//            }
//        }
//        tester().waitForView(withAccessibilityLabel: "\(Light.key)List")
//        tester().tapView(withAccessibilityLabel: "\(Light.key)List")
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Marlin Map")
//        tester().waitForView(withAccessibilityLabel: "Bishop Rock.")
//        tester().tapView(withAccessibilityLabel: "focus")
//        // should switch tabs
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        // bottom sheet should show up
//        tester().waitForView(withAccessibilityLabel: "Bishop Rock.")
//        NotificationCenter.default.post(name: .DismissBottomSheet, object: nil)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Bishop Rock.")
//        
//        // DifferentialGPSStation
//        for item in dataSourceList.nonTabs {
//            if item.key == DifferentialGPSStation.key {
//                dataSourceList.addItemToTabs(dataSourceItem: item, position: 0)
//                break
//            }
//        }
//        tester().waitForView(withAccessibilityLabel: "\(DifferentialGPSStation.key)List")
//        tester().tapView(withAccessibilityLabel: "\(DifferentialGPSStation.key)List")
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Marlin Map")
//        tester().waitForView(withAccessibilityLabel: "Chojin Dan Lt")
//        tester().tapView(withAccessibilityLabel: "focus")
//        // should switch tabs
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        // bottom sheet should show up
//        tester().waitForView(withAccessibilityLabel: "Chojin Dan Lt")
//        NotificationCenter.default.post(name: .DismissBottomSheet, object: nil)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Chojin Dan Lt")
//        
//        // Navigational Warning
//        for item in dataSourceList.nonTabs {
//            if item.key == NavigationalWarning.key {
//                dataSourceList.addItemToTabs(dataSourceItem: item, position: 0)
//                break
//            }
//        }
//        tester().waitForView(withAccessibilityLabel: "\(NavigationalWarning.key)List")
//        tester().tapView(withAccessibilityLabel: "\(NavigationalWarning.key)List")
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Marlin Map")
//        tester().waitForView(withAccessibilityLabel: "NAVAREA IV")
//        tester().tapView(withAccessibilityLabel: "NAVAREA IV")
//        tester().waitForAnimationsToFinish()
//        TestHelpers.printAllAccessibilityLabelsInWindows()
//        tester().waitForView(withAccessibilityLabel: "\(objects.navigationalWarningPoint.itemTitle) summary")
//        tester().tapView(withAccessibilityLabel: "\(objects.navigationalWarningPoint.itemTitle) summary")
//        tester().tapView(withAccessibilityLabel: "focus")
//        // should switch tabs
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        // bottom sheet should show up
//        tester().waitForView(withAccessibilityLabel: objects.navigationalWarningPoint.itemTitle)
//        NotificationCenter.default.post(name: .DismissBottomSheet, object: nil)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: objects.navigationalWarningPoint.itemTitle)
//    }
//    
//    func testMapTapBottomSheetShowDetails() {
//        guard let objects = TestHelpers.createOneOfEachType(persistentStore.viewContext) else {
//            XCTFail()
//            return
//        }
//        
//        for dataSource in MSI.shared.mainDataList {
//            switch dataSource {
//            case let mapImage as MapImage.Type:
//                mapImage.imageCache.clearCache()
//            default:
//                continue
//            }
//        }
//        
//        let appState: AppState = MSI.shared.appState
//        UserDefaults.standard.setValue(true, forKey: "onboardingComplete")
//        UserDefaults.standard.setValue(true, forKey: "disclaimerAccepted")
//        let dataSourceList: DataSourceList = DataSourceList()
//        
//        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
//        let asamRepository = AsamRepository(localDataSource: AsamCoreDataDataSource(context: persistentStore.viewContext), remoteDataSource: AsamRemoteDataSource())
//        let moduRepository = ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext))
//        let lightRepository = LightRepositoryManager(repository: LightCoreDataRepository(context: persistentStore.viewContext))
//        let portRepository = PortRepositoryManager(repository: PortCoreDataRepository(context: persistentStore.viewContext))
//        let dgpsRepository = DifferentialGPSStationRepositoryManager(repository: DifferentialGPSStationCoreDataRepository(context: persistentStore.viewContext))
//        let radioBeaconRepository = RadioBeaconRepositoryManager(repository: RadioBeaconCoreDataRepository(context: persistentStore.viewContext))
//        let routeRepository = RouteRepositoryManager(repository: RouteCoreDataRepository(context: persistentStore.viewContext))
//        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointCoreDataDataSource(context: persistentStore.viewContext))
//        
//        let view = MarlinView()
//            .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
//            .environmentObject(LocationManager.shared())
//            .environmentObject(appState)
//            .environmentObject(dataSourceList)
//            .environmentObject(bookmarkRepository)
//            .environmentObject(asamRepository)
//            .environmentObject(moduRepository)
//            .environmentObject(lightRepository)
//            .environmentObject(portRepository)
//            .environmentObject(dgpsRepository)
//            .environmentObject(radioBeaconRepository)
//            .environmentObject(routeRepository)
//            .environmentObject(routeWaypointRepository)
//        
//        let controller = UIHostingController(rootView: view)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        
//        // verify bottom sheet switching works and then tapping more details works
//        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(annotations: nil, items: [objects.asam, objects.modu, objects.port, objects.dfrs, objects.radioBeacon, objects.light, objects.navigationalWarningPolygon, objects.navigationalWarningLine, objects.navigationalWarningPoint, objects.navigationalWarningMultipoint, objects.navigationalWarningCircle, objects.differentialGPSStation], mapName: nil))
//        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
//        tester().tapView(withAccessibilityLabel: "next")
//        tester().waitForView(withAccessibilityLabel: "ABAN II")
//        tester().tapView(withAccessibilityLabel: "next")
//        tester().waitForView(withAccessibilityLabel: "Aasiaat")
//        tester().tapView(withAccessibilityLabel: "next")
//        tester().waitForView(withAccessibilityLabel: "Nos Galata Lt.")
//        tester().tapView(withAccessibilityLabel: "next")
//        tester().waitForView(withAccessibilityLabel: "Ittoqqortoormit, Scoresbysund")
//        tester().tapView(withAccessibilityLabel: "next")
//        tester().waitForView(withAccessibilityLabel: "Bishop Rock.")
//        tester().tapView(withAccessibilityLabel: "next")
//        tester().waitForView(withAccessibilityLabel: objects.navigationalWarningPolygon.itemTitle)
//        tester().tapView(withAccessibilityLabel: "next")
//        tester().waitForView(withAccessibilityLabel: objects.navigationalWarningLine.itemTitle)
//        tester().tapView(withAccessibilityLabel: "next")
//        tester().waitForView(withAccessibilityLabel: objects.navigationalWarningPoint.itemTitle)
//        tester().tapView(withAccessibilityLabel: "next")
//        tester().waitForView(withAccessibilityLabel: objects.navigationalWarningMultipoint.itemTitle)
//        tester().tapView(withAccessibilityLabel: "next")
//        tester().waitForView(withAccessibilityLabel: objects.navigationalWarningCircle.itemTitle)
//        tester().tapView(withAccessibilityLabel: "next")
//        tester().waitForView(withAccessibilityLabel: "Chojin Dan Lt")
//        
//        tester().waitForTappableView(withAccessibilityLabel: "More Details")
//        tester().tapView(withAccessibilityLabel: "More Details")
//        tester().waitForView(withAccessibilityLabel: "Chojin Dan Lt")
//        tester().waitForTappableView(withAccessibilityLabel: "Marlin")
//        tester().tapView(withAccessibilityLabel: "Marlin", traits: .button)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Chojin Dan Lt")
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        
//        // pull up each data type and go to the detail page
//        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(annotations: nil, items: [objects.asam], mapName: nil))
//        tester().waitForTappableView(withAccessibilityLabel: "More Details")
//        tester().tapView(withAccessibilityLabel: "More Details")
//        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
//        tester().waitForTappableView(withAccessibilityLabel: "Marlin")
//        tester().tapView(withAccessibilityLabel: "Marlin", traits: .button)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding: Boat")
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        
//        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(annotations: nil, items: [objects.modu], mapName: nil))
//        tester().waitForTappableView(withAccessibilityLabel: "More Details")
//        tester().tapView(withAccessibilityLabel: "More Details")
//        tester().waitForView(withAccessibilityLabel: "ABAN II")
//        tester().waitForTappableView(withAccessibilityLabel: "Marlin")
//        tester().tapView(withAccessibilityLabel: "Marlin", traits: .button)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "ABAN II")
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        
//        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(annotations: nil, items: [objects.port], mapName: nil))
//        tester().waitForTappableView(withAccessibilityLabel: "More Details")
//        tester().tapView(withAccessibilityLabel: "More Details")
//        tester().waitForView(withAccessibilityLabel: "Aasiaat")
//        tester().waitForTappableView(withAccessibilityLabel: "Marlin")
//        tester().tapView(withAccessibilityLabel: "Marlin", traits: .button)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Aasiaat")
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        
////        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(annotations: nil, items: [objects.dfrs], mapName: nil))
////        tester().waitForTappableView(withAccessibilityLabel: "More Details")
////        tester().tapView(withAccessibilityLabel: "More Details")
////        tester().waitForView(withAccessibilityLabel: "Nos Galata Lt.")
////        tester().waitForTappableView(withAccessibilityLabel: "Marlin")
////        tester().tapView(withAccessibilityLabel: "Marlin", traits: .button)
////        tester().waitForAbsenceOfView(withAccessibilityLabel: "Nos Galata Lt.")
////        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        
//        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(annotations: nil, items: [objects.radioBeacon], mapName: nil))
//        tester().waitForTappableView(withAccessibilityLabel: "More Details")
//        tester().tapView(withAccessibilityLabel: "More Details")
//        tester().waitForView(withAccessibilityLabel: "Ittoqqortoormit, Scoresbysund")
//        tester().waitForTappableView(withAccessibilityLabel: "Marlin")
//        tester().tapView(withAccessibilityLabel: "Marlin", traits: .button)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Ittoqqortoormit, Scoresbysund")
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        
//        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(annotations: nil, items: [objects.light], mapName: nil))
//        tester().waitForTappableView(withAccessibilityLabel: "More Details")
//        tester().tapView(withAccessibilityLabel: "More Details")
//        tester().waitForView(withAccessibilityLabel: "Bishop Rock.")
//        tester().waitForTappableView(withAccessibilityLabel: "Marlin")
//        tester().tapView(withAccessibilityLabel: "Marlin", traits: .button)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "Bishop Rock.")
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        
//        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(annotations: nil, items: [objects.navigationalWarningPolygon], mapName: nil))
//        tester().waitForTappableView(withAccessibilityLabel: "More Details")
//        tester().tapView(withAccessibilityLabel: "More Details")
//        tester().waitForView(withAccessibilityLabel: objects.navigationalWarningPolygon.itemTitle)
//        tester().waitForTappableView(withAccessibilityLabel: "Marlin")
//        tester().tapView(withAccessibilityLabel: "Marlin", traits: .button)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: objects.navigationalWarningPolygon.itemTitle)
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        
//        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(annotations: nil, items: [objects.navigationalWarningLine], mapName: nil))
//        tester().waitForTappableView(withAccessibilityLabel: "More Details")
//        tester().tapView(withAccessibilityLabel: "More Details")
//        tester().waitForView(withAccessibilityLabel: objects.navigationalWarningLine.itemTitle)
//        tester().waitForTappableView(withAccessibilityLabel: "Marlin")
//        tester().tapView(withAccessibilityLabel: "Marlin", traits: .button)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: objects.navigationalWarningLine.itemTitle)
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        
//        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(annotations: nil, items: [objects.navigationalWarningPoint], mapName: nil))
//        tester().waitForTappableView(withAccessibilityLabel: "More Details")
//        tester().tapView(withAccessibilityLabel: "More Details")
//        tester().waitForView(withAccessibilityLabel: objects.navigationalWarningPoint.itemTitle)
//        tester().waitForTappableView(withAccessibilityLabel: "Marlin")
//        tester().tapView(withAccessibilityLabel: "Marlin", traits: .button)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: objects.navigationalWarningPoint.itemTitle)
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        
//        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(annotations: nil, items: [objects.navigationalWarningMultipoint], mapName: nil))
//        tester().waitForTappableView(withAccessibilityLabel: "More Details")
//        tester().tapView(withAccessibilityLabel: "More Details")
//        tester().waitForView(withAccessibilityLabel: objects.navigationalWarningMultipoint.itemTitle)
//        tester().waitForTappableView(withAccessibilityLabel: "Marlin")
//        tester().tapView(withAccessibilityLabel: "Marlin", traits: .button)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: objects.navigationalWarningMultipoint.itemTitle)
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//        
//        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(annotations: nil, items: [objects.navigationalWarningCircle], mapName: nil))
//        tester().waitForTappableView(withAccessibilityLabel: "More Details")
//        tester().tapView(withAccessibilityLabel: "More Details")
//        tester().waitForView(withAccessibilityLabel: objects.navigationalWarningCircle.itemTitle)
//        tester().waitForTappableView(withAccessibilityLabel: "Marlin")
//        tester().tapView(withAccessibilityLabel: "Marlin", traits: .button)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: objects.navigationalWarningCircle.itemTitle)
//        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
//    }
}
