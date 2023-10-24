//
//  LightSectorsTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 6/1/23.
//

import XCTest
import Combine

@testable import Marlin

final class LightSectorsTests: XCTestCase {
    
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
    
    func testVisibleAndObscured() {
        let light = Light(context: persistentStore.viewContext)
        
        light.volumeNumber = "PUB 114"
        light.aidType = "Lighted Aids"
        light.geopoliticalHeading = "ENGLAND-SCILLY ISLES"
        light.regionHeading = nil
        light.subregionHeading = nil
        light.localHeading = nil
        light.precedingNote = nil
        light.featureNumber = "4"
        light.internationalFeature = "A0002"
        light.name = "Bishop Rock."
        light.position = "49°52'21.4\"N \n6°26'44\"W"
        light.characteristicNumber = 1
        light.characteristic = "Fl.(2)W.\nperiod 15s \nfl. 0.1s, ec. 2.2s \n"
        light.heightFeet = 144
        light.heightMeters = 44
        light.range = "20"
        light.structure = "Gray round granite tower; 161.\nHelicopter platform. \n"
        light.remarks = "Visible 233°-236° and 259°-204°.  Partially obscured 204°-211°.  AIS (MMSI No 992351137).\n"
        light.postNote = nil
        light.noticeNumber = 201516
        light.removeFromList = "N"
        light.deleteFlag = "Y"
        light.noticeWeek = "16"
        light.noticeYear = "2015"
        light.latitude = 1.0
        light.longitude = 2.0
        light.sectionHeader = "Section"
        
        let sectors = light.lightSectors!
        XCTAssertEqual(sectors.count, 3)
        XCTAssertFalse(sectors[0].obscured)
        XCTAssertFalse(sectors[1].obscured)
        XCTAssertTrue(sectors[2].obscured)
    }

}
