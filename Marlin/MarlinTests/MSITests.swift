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
                expect(asam?.latitude).to(beCloseTo(12.55000000016662))
                expect(asam?.longitude).to(beCloseTo(43.51666666702533))
                expect(asam?.position).to(equal("12°33'00\"N \n43°31'00\"E"))
                expect(asam?.subreg).to(equal("62"))
                expect(asam?.hostility).to(beNil())
                expect(asam?.victim).to(equal("Survey vessel"))
                expect(asam?.asamDescription).to(equal("DJIBOUTI: On 25 May, at 1050 local time, an underway survey vessel reported a suspicious approach by a skiff with eight people onboard approximately 5 NM southeast of Perim Island, near position 12-33N 043-31E. Upon sighting of the skiff, the master raised the alarm, anti-piracy measures were implemented, and the security team onboard positioned on the bridge. The skiff came close to within half a nautical mile before aborting the approach. The master reported the incident to the authorities."))
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                expect(asam?.date).to(equal(formatter.date(from:"2022-05-25")))
            }
            
            it("should pull ASAMS from a date") {
                print("running a test")
                var stubCalled = false;
                
                stub(condition: isMethodGET() &&
                     isHost("msi.gs.mil") &&
                     isScheme("https") &&
                     isPath("/api/publications/asam") &&
                     containsQueryParams(["minOccurDate": "2022-02-02"])
                ) { (request) -> HTTPStubsResponse in
                    stubCalled = true;
                    return HTTPStubsResponse(jsonObject: [], statusCode: 200, headers: ["Content-Type": "application/json"])
                }
                
                MSI.shared.loadAsams(date: "2022-02-02")
                expect(stubCalled).toEventually(beTrue());
                
                let persistenceController = PersistenceController.shared
                expect(try? persistenceController.container.viewContext.countOfObjects(Asam.self)).toEventually(equal(0))
                
            }
            
            it("should pull MODUS") {
                print("running a test")
                var stubCalled = false;
                
                stub(condition: isMethodGET() &&
                     isHost("msi.gs.mil") &&
                     isScheme("https") &&
                     isPath("/api/publications/modu")
                ) { (request) -> HTTPStubsResponse in
                    stubCalled = true;
                    let stubPath = OHPathForFile("modus.json", MSITests.self);
                    return HTTPStubsResponse(fileAtPath: stubPath!, statusCode: 200, headers: ["Content-Type": "application/json"]);
                }
                
                MSI.shared.loadModus()
                expect(stubCalled).toEventually(beTrue());
                
                let persistenceController = PersistenceController.shared
                expect(try? persistenceController.container.viewContext.countOfObjects(Modu.self)).toEventually(equal(1))
                let modu = persistenceController.container.viewContext.fetchFirst(Modu.self, key: "name", value: "590021")
                expect(modu?.name).to(equal("590021"))
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                expect(modu?.date).to(equal(formatter.date(from:"2021-04-16")))
            }
        }
    }
}
