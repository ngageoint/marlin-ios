//
//  MSIListViewModelTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/31/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class MSIListViewModelTests: XCTestCase {

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
        persistentStore.viewContext.performAndWait {
            if let lights = persistentStore.viewContext.fetchAll(Light.self) {
                for light in lights {
                    persistentStore.viewContext.delete(light)
                }
            }
        }
        
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
        
    }
    override func tearDown(completion: @escaping (Error?) -> Void) {
        persistentStore.viewContext.performAndWait {
            if let lights = persistentStore.viewContext.fetchAll(Light.self) {
                for light in lights {
                    persistentStore.viewContext.delete(light)
                }
            }
        }
        completion(nil)
    }

    func testExample() throws {
       // focusedItem: itemWrapper, filterPublisher: UserDefaults.standard.publisher(for: \.asamFilter), sortPublisher: UserDefaults.standard.publisher(for: \.asamSort)
//        let listViewModel =
    }

}
