//
//  AsamCoreDataDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 10/31/23.
//

import XCTest
import Combine
import CoreData

@testable import Marlin

final class AsamCoreDataDataSourceTests: XCTestCase {
    
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        Task.init {
            await TestHelpers.asyncGetKeyWindowVisible()
        }
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
        
        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource.definition)
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

    func testCount() {
        var newItem: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            newItem = asam
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let dataSource = AsamCoreDataDataSource(context: persistentStore.viewContext)
        
        XCTAssertEqual(dataSource.getCount(filters: nil), 1)
    }
    
    func testGetAsam() {
        var newItem: Asam?
        var newItem2: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Ship"
            
            newItem = asam
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description"
            asam2.longitude = 1.0
            asam2.latitude = 1.0
            asam2.date = Date(timeIntervalSince1970: 0)
            asam2.navArea = "XI"
            asam2.reference = "2022-101"
            asam2.subreg = "71"
            asam2.position = "1°00'00\"N \n1°00'00\"E"
            asam2.hostility = "Boarding"
            asam2.victim = "Boat"
            
            newItem2 = asam2
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        guard let newItem2 = newItem2 else {
            XCTFail()
            return
        }
        
        let dataSource = AsamCoreDataDataSource(context: persistentStore.viewContext)
        
        let retrieved = dataSource.getAsam(reference: newItem.reference)
        XCTAssertEqual(retrieved?.reference, newItem.reference)
        XCTAssertEqual(retrieved?.victim, newItem.victim)
        
        let retrieved2 = dataSource.getAsam(reference: newItem2.reference)
        XCTAssertEqual(retrieved2?.reference, newItem2.reference)
        XCTAssertEqual(retrieved2?.victim, newItem2.victim)
        
        let no = dataSource.getAsam(reference: "Nope")
        XCTAssertNil(no)
    }
    
    func testObserveAsamListItems() {
        let dataSource = AsamCoreDataDataSource(context: persistentStore.viewContext)

        var publisher: AnyPublisher<CollectionDifference<AsamModel>, Never> = dataSource.observeAsamListItems(filters: [])
        
        let expectation = XCTestExpectation(description: "Wait for Asam data")
        var disposables = Set<AnyCancellable>()
        var calls: Int = 0
        publisher.sink { difference in
            print("Difference \(difference)")
            if calls == 0 {
                XCTAssertEqual(difference.insertions.count, 0)
                XCTAssertEqual(difference.removals.count, 0)
            } else if calls == 1 {
                XCTAssertEqual(difference.insertions.count, 1)
                XCTAssertEqual(difference.removals.count, 0)
            } else if calls == 2 {
                XCTAssertEqual(difference.insertions.count, 1)
                XCTAssertEqual(difference.removals.count, 0)
            } else if calls == 3 {
                XCTAssertEqual(difference.insertions.count, 0)
                XCTAssertEqual(difference.removals.count, 2)
            } else if calls == 4 {
                XCTAssertEqual(difference.insertions.count, 2)
                XCTAssertEqual(difference.removals.count, 0)
                expectation.fulfill()
            }
            calls += 1
        }
        .store(in: &disposables)
        
        var newItem: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Ship"
            
            newItem = asam
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        
        var newItem2: Asam?
        persistentStore.viewContext.performAndWait {
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description"
            asam2.longitude = 1.0
            asam2.latitude = 1.0
            asam2.date = Date(timeIntervalSince1970: 0)
            asam2.navArea = "XI"
            asam2.reference = "2022-101"
            asam2.subreg = "71"
            asam2.position = "1°00'00\"N \n1°00'00\"E"
            asam2.hostility = "Boarding"
            asam2.victim = "Boat"

            newItem2 = asam2
            try? persistentStore.viewContext.save()
        }
        
        guard let newItem2 = newItem2 else {
            XCTFail()
            return
        }
        
        persistentStore.viewContext.performAndWait {
            persistentStore.viewContext.delete(newItem)
            persistentStore.viewContext.delete(newItem2)
            try? persistentStore.viewContext.save()
        }
        
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Ship"
                        
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description"
            asam2.longitude = 1.0
            asam2.latitude = 1.0
            asam2.date = Date(timeIntervalSince1970: 0)
            asam2.navArea = "XI"
            asam2.reference = "2022-101"
            asam2.subreg = "71"
            asam2.position = "1°00'00\"N \n1°00'00\"E"
            asam2.hostility = "Boarding"
            asam2.victim = "Boat"
            
            try? persistentStore.viewContext.save()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testInsert() async {
        var asam = AsamModel()
        asam.asamDescription = "description"
        asam.longitude = 1.0
        asam.latitude = 1.0
        asam.date = Date(timeIntervalSince1970: 0)
        asam.navArea = "XI"
        asam.reference = "2022-100"
        asam.subreg = "71"
        asam.position = "1°00'00\"N \n1°00'00\"E"
        asam.hostility = "Boarding"
        asam.victim = "Ship"
        
        let dataSource = AsamCoreDataDataSource(context: persistentStore.viewContext)

        let inserted = await dataSource.insert(asams: [asam])
        XCTAssertEqual(1, inserted)
        
        let retrieved = dataSource.getAsam(reference: asam.reference)
        XCTAssertEqual(retrieved?.reference, asam.reference)
        XCTAssertEqual(retrieved?.victim, asam.victim)
    }
    
    func testGetAsams() async {
        var asam = AsamModel()
        asam.asamDescription = "description"
        asam.longitude = 1.0
        asam.latitude = 1.0
        asam.date = Date(timeIntervalSince1970: 0)
        asam.navArea = "XI"
        asam.reference = "2022-100"
        asam.subreg = "71"
        asam.position = "1°00'00\"N \n1°00'00\"E"
        asam.hostility = "Boarding"
        asam.victim = "Ship"
        
        let dataSource = AsamCoreDataDataSource(context: persistentStore.viewContext)
        
        let inserted = await dataSource.insert(asams: [asam])
        XCTAssertEqual(1, inserted)

        let retrieved = dataSource.getAsams(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "reference", key: "reference", type: .string), comparison: DataSourceFilterComparison.equals, valueString: asam.reference)])
        XCTAssertEqual(1, retrieved.count)
        XCTAssertEqual(retrieved[0].reference, asam.reference)
        XCTAssertEqual(retrieved[0].victim, asam.victim)
        
        let retrievedNone = dataSource.getAsams(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "reference", key: "reference", type: .string), comparison: DataSourceFilterComparison.equals, valueString: "no")])
        XCTAssertEqual(0, retrievedNone.count)
    }

}
