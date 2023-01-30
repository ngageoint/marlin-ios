//
//  MarlinCompactWidthViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/26/23.
//

import XCTest
import SwiftUI
import Combine
import CoreLocation

@testable import Marlin

final class MarlinCompactWidthViewTests: XCTestCase {
    
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)

    override func setUp(completion: @escaping (Error?) -> Void) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
        
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

    func xtestLoading() {
        class PassThrough {
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
        
        tester().wait(forTimeInterval: 6)
    }
}
