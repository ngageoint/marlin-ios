//
//  PublicationListTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/13/23.
//

import XCTest
import Combine
import SwiftUI
import OHHTTPStubs

@testable import Marlin

final class PublicationListTests: XCTestCase {

    func testOneSectionList() throws {
//        XCTFail()
        stub(condition: isScheme("https") && pathEndsWith("/publications/stored-pubs")) { request in
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("fullEpubList.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"]
            )
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

//        MSI.shared.loadData(type: ElectronicPublication.decodableRoot, dataType: ElectronicPublication.self)

        let bundle = MockBundle()
        bundle.mockPath = "fullEpubList.json"

        let localDataSource = PublicationStaticLocalDataSource()
        let operation = PublicationInitialDataLoadOperation(localDataSource: localDataSource, bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
        
        class PassThrough: ObservableObject {
            
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            @State var router: MarlinRouter = MarlinRouter()
            var body: some View {
                NavigationStack(path: $router.path) {
                    PublicationsSectionList()
                        .marlinRoutes()
                }
                .environmentObject(router)
            }
        }
        let passThrough = PassThrough()
        let repository = PublicationRepository(localDataSource: localDataSource, remoteDataSource: PublicationRemoteDataSource())
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        let bookmarkRepository = BookmarkRepository(localDataSource: bookmarkLocalDataSource)

        let container = Container(passThrough: passThrough)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)

        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        for publicationType in PublicationTypeEnum.allCases {
            if publicationType != .fleetGuides && publicationType != .unknown {
                tester().waitForView(withAccessibilityLabel: publicationType.description)
                tester().tapView(withAccessibilityLabel: publicationType.description)
                if publicationType == .atlasOfPilotCharts {
                    tester().waitForView(withAccessibilityLabel: "Pub. 109 - Atlas of Pilot Charts Indian Ocean, 4th Ed. 2001")
                    tester().tapView(withAccessibilityLabel: "Pub. 109 - Atlas of Pilot Charts Indian Ocean, 4th Ed. 2001")
                    tester().waitForView(withAccessibilityLabel: "Back")
                    tester().tapView(withAccessibilityLabel: "Back")
                } else if publicationType == .listOfLights {
                    tester().waitForView(withAccessibilityLabel: "Pub. 116 - Baltic Sea with Kattegat, Belts and Sound and Gulf of Bothnia")
                    tester().tapView(withAccessibilityLabel: "Pub. 116 - Baltic Sea with Kattegat, Belts and Sound and Gulf of Bothnia")
                    tester().waitForView(withAccessibilityLabel: "Back")
                    tester().tapView(withAccessibilityLabel: "Back")
                } else if publicationType == .sightReductionTablesForMarineNavigation {
                    tester().waitForView(withAccessibilityLabel: "Volume 1 - Latitudes 0°-15°, Inclusive")
                    tester().tapView(withAccessibilityLabel: "Volume 1 - Latitudes 0°-15°, Inclusive")
                    tester().waitForView(withAccessibilityLabel: "Back")
                    tester().tapView(withAccessibilityLabel: "Back")
                }
                tester().waitForView(withAccessibilityLabel: "Back")
                tester().tapView(withAccessibilityLabel: "Back")
            }
        }
    }

}
