//
//  MapLayerViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/27/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class MapLayerViewTests: XCTestCase {
    
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        
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

    func testToggle() {
        
        var layer: MapLayer?
        persistentStore.viewContext.performAndWait {
            let item = MapLayer(context: persistentStore.viewContext)
            item.visible = true
            item.layerId = 1
            item.name = "Hi"
            item.displayName = "Hi Display"
            item.url = "https://example.com/wms"
            
            layer = item
            try? persistentStore.viewContext.save()
        }
        guard let layer = layer else {
            XCTFail()
            return
        }
        
        let view = MapLayersView()
        let nav = NavigationView {
            view
                .environment(\.managedObjectContext, persistentStore.viewContext)
        }
        
        let controller = UIHostingController(rootView: nav)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().wait(forTimeInterval: 5)
        
        XCTAssertEqual(true, layer.visible)
        tester().waitForView(withAccessibilityLabel: "Hide \(layer.url!)")
        tester().tapView(withAccessibilityLabel: "Hide \(layer.url!)")
        XCTAssertEqual(false, layer.visible)
        
        XCTAssertEqual(false, layer.visible)
        tester().waitForView(withAccessibilityLabel: "Show \(layer.url!)")
        tester().tapView(withAccessibilityLabel: "Show \(layer.url!)")
        XCTAssertEqual(true, layer.visible)
        
        tester().wait(forTimeInterval: 5)
    }
}
