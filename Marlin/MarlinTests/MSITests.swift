//
//  MSITests.swift
//  Tests
//
//  Created by Daniel Barela on 6/6/22.
//

import Foundation
import Quick
import KIF
import Nimble
import Kingfisher
import OHHTTPStubs

@testable import Marlin
import CoreData

class MSITests: KIFSpec {
    
    override func spec() {
                
        describe("ASAM Tests") {
            
            beforeEach {
                TestHelpers.clearData()
                
//                var cleared = false;
//                while (!cleared) {
//                    let clearMap = TestHelpers.clearAndSetUpStack()
//                    cleared = (clearMap[String(describing: Layer.self)] ?? false)
//
//                    if (!cleared) {
//                        cleared = Layer.mr_findAll(in: NSManagedObjectContext.mr_default())?.count == 0
//                    }
//
//                    if (!cleared) {
//                        Thread.sleep(forTimeInterval: 0.5);
//                    }
//
//                }
//
//                if let staticLayerObserver = staticLayerObserver {
//                    NotificationCenter.default.removeObserver(staticLayerObserver, name: .StaticLayerLoaded, object: nil)
//                }
//
//                expect(Layer.mr_findAll(in: NSManagedObjectContext.mr_default())?.count).toEventually(equal(0), timeout: DispatchTimeInterval.seconds(2), pollInterval: DispatchTimeInterval.milliseconds(200), description: "Layers still exist in default");
//
//                expect(Layer.mr_findAll(in: NSManagedObjectContext.mr_rootSaving())?.count).toEventually(equal(0), timeout: DispatchTimeInterval.seconds(10), pollInterval: DispatchTimeInterval.milliseconds(200), description: "Layers still exist in root");
//
//                UserDefaults.standard.baseServerUrl = "https://magetest";
//                UserDefaults.standard.serverMajorVersion = 6;
//                UserDefaults.standard.serverMinorVersion = 0;
//
//                MageCoreDataFixtures.addEvent(remoteId: 1, name: "Event", formsJsonFile: "oneForm")
//                Server.setCurrentEventId(1);
//                NSManagedObject.mr_setDefaultBatchSize(0);
            }
            
            afterEach {
//                NSManagedObject.mr_setDefaultBatchSize(20);
//                TestHelpers.clearAndSetUpStack();
                HTTPStubs.removeAllStubs();
                TestHelpers.clearData()
            }
            
            it("should pull ASAMS") {
                print("running a test")
                var stubCalled = false;

                stub(condition: isMethodGET() &&
                     isHost("msi.gs.mil") &&
                     isScheme("https") &&
                     isPath("/api/publications/asam")
                ) { (request) -> HTTPStubsResponse in
                    stubCalled = true;
                    let stubPath = OHPathForFile("asams.json", MSITests.self);
                    return HTTPStubsResponse(fileAtPath: stubPath!, statusCode: 200, headers: ["Content-Type": "application/json"]);
                }
                
                MSI.shared.loadAsams()
                expect(stubCalled).toEventually(beTrue());
                
                let persistenceController = PersistenceController.shared
                expect(try? persistenceController.container.viewContext.countOfObjects(Asam.self)).toEventually(equal(4))
                let asam = persistenceController.container.viewContext.fetchFirst(Asam.self, key: "reference", value: "2022-142")
                expect(asam?.reference).to(equal("2022-142"))
                expect(asam?.navArea).to(equal("IX"))
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                expect(asam?.date).to(equal(formatter.date(from:"2022-05-25")))
//                expect(Layer.mr_findAll(in: NSManagedObjectContext.mr_default())?.count).toEventually(equal(1), timeout: DispatchTimeInterval.seconds(2), pollInterval: DispatchTimeInterval.milliseconds(200), description: "Did not find layer");
//                let layer = Layer.mr_findFirst()!;
//                expect(layer.remoteId).to(equal(1))
//                expect(layer.name).to(equal("name"))
//                expect(layer.type).to(equal("GeoPackage"))
//                expect(layer.eventId).to(equal(1))
//                expect(layer.file).toNot(beNil());
//                expect(layer.file![LayerFileKey.name.key] as? String).to(equal("geopackage.gpkg"))
//                expect(layer.file![LayerFileKey.contentType.key] as? String).to(equal("application/octet-stream"))
//                expect(layer.file![LayerFileKey.size.key] as? String).to(equal("303104"))
//                expect(layer.loaded).to(equal(NSNumber(floatLiteral:Layer.OFFLINE_LAYER_NOT_DOWNLOADED)))
            }
        }
    }
}
