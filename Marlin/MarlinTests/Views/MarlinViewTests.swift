//
//  MarlinViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/17/23.
//

import XCTest
import SwiftUI
import Combine
import CoreLocation

@testable import Marlin

final class MarlinViewTests: XCTestCase {
    
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults(withMetrics: false)
        
        UserDefaults.standard.initialDataLoaded = false
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
        UserDefaults.standard.showCurrentLocation = true
        LocationManager.shared.lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
        class PassThrough {
            var dataSourceList: DataSourceList?
        }
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            @StateObject var mapState: MapState = MapState()
            @State var filterOpen: Bool = false
            
            var passThrough: PassThrough
            var mixins: [MapMixin] = []
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                ZStack {
                    MarlinCompactWidth(dataSourceList: dataSourceList, filterOpen: $filterOpen, marlinMap: MarlinMap(name: "Marlin Compact Map", mixins: mixins, mapState: mapState)
                    )
                    .onAppear {
                        self.passThrough.dataSourceList = dataSourceList
                    }
                }
            }
        }
        
        let appState = AppState()
        let passThrough = PassThrough()
        UNNotificationSettings.fakeAuthorizationStatus = .notDetermined
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForAbsenceOfView(withAccessibilityLabel: "New Data Loaded")
        tester().waitForView(withAccessibilityLabel: "Current Location")
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
        tester().waitForView(withAccessibilityLabel: "Loading initial data")
        tester().waitForView(withAccessibilityLabel: "Map Settings")
        tester().waitForView(withAccessibilityLabel: "User Tracking")
        
        if let dataSourceList = passThrough.dataSourceList {
            for dataSource in dataSourceList.tabs {
                tester().waitForView(withAccessibilityLabel: "\(dataSource.dataSource.key)List")
            }
            for dataSource in dataSourceList.allTabs.filter({ item in
                item.dataSource.isMappable
            }) {
                tester().waitForView(withAccessibilityLabel: "\(dataSource.dataSource.key) Map Toggle")
            }
        }
    }
}
