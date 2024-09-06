//
//  DGPSStationListTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 3/4/24.
//

import XCTest
import SwiftUI

@testable import Marlin

final class DGPSStationListTests: XCTestCase {

    override class func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
        UserDefaults.standard.setSort(DataSources.dgps.key, sort: DataSources.dgps.filterable!.defaultSort)
    }

    func testLoading() {
        UserDefaults.standard.setSort(DataSources.dgps.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Feature Number",
                    key: #keyPath(DifferentialGPSStation.featureNumber),
                    type: .int),
                ascending: true,
                section: false)
        ])

        var dgps = DGPSStationModel()
        dgps.volumeNumber = "PUB 112"
        dgps.aidType = "Differential GPS Stations"
        dgps.geopoliticalHeading = "KOREA"
        dgps.regionHeading = "region heading"
        dgps.sectionHeader = "KOREA: region heading"
        dgps.precedingNote = "preceeding note"
        dgps.featureNumber = 6
        dgps.name = "Chojin Dan Lt"
        dgps.position = "1°00'00\"N \n2°00'00.00\"E"
        dgps.latitude = 1.0
        dgps.longitude = 2.0
        dgps.stationID = "T670\nR740\nR741"
        dgps.range = 100
        dgps.frequency = 292
        dgps.transferRate = 200
        dgps.remarks = "Message types: 3, 5, 7, 9, 16."
        dgps.postNote = "post note"
        dgps.noticeNumber = 201134
        dgps.removeFromList = "N"
        dgps.deleteFlag = "N"
        dgps.noticeWeek = "34"
        dgps.noticeYear = "2011"

        let localDataSource = DifferentialGPSStationStaticLocalDataSource()
        InjectedValues[\.dgpsLocalDataSource] = localDataSource
        let remoteDataSource = DGPSStationRemoteDataSource()
        InjectedValues[\.dgpsemoteDataSource] = remoteDataSource
        localDataSource.list = [dgps]
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource

        let router = MarlinRouter()

        let routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        struct Container: View {
            @EnvironmentObject var router: MarlinRouter

            var body: some View {
                NavigationStack(path: $router.path) {
                    DGPSStationList()
                        .marlinRoutes()
                }
            }
        }
        let view = Container()
            .environmentObject(routeWaypointRepository)
            .environmentObject(router)
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller

        tester().waitForAbsenceOfView(withAccessibilityLabel: "\(DataSources.dgps.key) Loading")

        tester().waitForView(withAccessibilityLabel: "6 PUB 112")

        XCTAssertEqual(router.path.count, 0)
        tester().tapMiddlePointInView(accessibilityLabel: "\(DataSources.dgps.key) \(dgps.itemKey)")
        XCTAssertEqual(router.path.count, 1)

        tester().waitForView(withAccessibilityLabel: "6 PUB 112")
        tester().waitForView(withAccessibilityLabel: "\(dgps.featureNumber ?? 0)")
        tester().waitForView(withAccessibilityLabel: dgps.name)
        tester().waitForView(withAccessibilityLabel: dgps.geopoliticalHeading)
        tester().waitForView(withAccessibilityLabel: dgps.position)
        tester().waitForView(withAccessibilityLabel: dgps.stationID)
        tester().waitForView(withAccessibilityLabel: "\(dgps.range ?? 0)")
        tester().waitForView(withAccessibilityLabel: "\(dgps.frequency ?? 0)")
        tester().waitForView(withAccessibilityLabel: "\(dgps.transferRate ?? 0)")
        tester().waitForView(withAccessibilityLabel: dgps.remarks)
        tester().waitForView(withAccessibilityLabel: "\(dgps.noticeNumber ?? 0)")
        tester().waitForView(withAccessibilityLabel: dgps.precedingNote)
        tester().waitForView(withAccessibilityLabel: dgps.postNote)
    }

    func testLoadingWithSections() {
        UserDefaults.standard.setSort(DataSources.dgps.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Feature Number",
                    key: #keyPath(DifferentialGPSStation.featureNumber),
                    type: .int),
                ascending: true,
                section: true)
        ])

        var dgps = DGPSStationModel()
        dgps.volumeNumber = "PUB 112"
        dgps.aidType = "Differential GPS Stations"
        dgps.geopoliticalHeading = "KOREA"
        dgps.regionHeading = "region heading"
        dgps.sectionHeader = "KOREA: region heading"
        dgps.precedingNote = "preceeding note"
        dgps.featureNumber = 6
        dgps.name = "Chojin Dan Lt"
        dgps.position = "1°00'00\"N \n2°00'00.00\"E"
        dgps.latitude = 1.0
        dgps.longitude = 2.0
        dgps.stationID = "T670\nR740\nR741"
        dgps.range = 100
        dgps.frequency = 292
        dgps.transferRate = 200
        dgps.remarks = "Message types: 3, 5, 7, 9, 16."
        dgps.postNote = "post note"
        dgps.noticeNumber = 201134
        dgps.removeFromList = "N"
        dgps.deleteFlag = "N"
        dgps.noticeWeek = "34"
        dgps.noticeYear = "2011"

        var dgps2 = DGPSStationModel()
        dgps2.volumeNumber = "PUB 112"
        dgps2.aidType = "Differential GPS Stations"
        dgps2.geopoliticalHeading = "KOREA2"
        dgps2.regionHeading = "region heading2"
        dgps2.sectionHeader = "KOREA: region heading2"
        dgps2.precedingNote = "preceeding note2"
        dgps2.featureNumber = 7
        dgps2.name = "Chojin Dan Lt2"
        dgps2.position = "2°00'00\"N \n3°00'00.00\"E"
        dgps2.latitude = 1.0
        dgps2.longitude = 2.0
        dgps2.stationID = "T670\nR740\nR741"
        dgps2.range = 100
        dgps2.frequency = 292
        dgps2.transferRate = 200
        dgps2.remarks = "Message types: 3, 5, 7, 9, 16."
        dgps2.postNote = "post note"
        dgps2.noticeNumber = 201134
        dgps2.removeFromList = "N"
        dgps2.deleteFlag = "N"
        dgps2.noticeWeek = "35"
        dgps2.noticeYear = "2011"

        let localDataSource = DifferentialGPSStationStaticLocalDataSource()
        InjectedValues[\.dgpsLocalDataSource] = localDataSource
        let remoteDataSource = DGPSStationRemoteDataSource()
        InjectedValues[\.dgpsemoteDataSource] = remoteDataSource
        localDataSource.list = [dgps, dgps2]
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource

        let router = MarlinRouter()

        let routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        struct Container: View {
            @EnvironmentObject var router: MarlinRouter

            var body: some View {
                NavigationStack(path: $router.path) {
                    DGPSStationList()
                        .marlinRoutes()
                }
            }
        }
        let view = Container()
            .environmentObject(routeWaypointRepository)
            .environmentObject(router)
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller

        tester().waitForAbsenceOfView(withAccessibilityLabel: "\(DataSources.dgps.key) Loading")

        tester().waitForView(withAccessibilityLabel: "6 PUB 112")
        tester().waitForView(withAccessibilityLabel: "7 PUB 112")
        tester().waitForView(withAccessibilityLabel: "7")
        tester().waitForView(withAccessibilityLabel: "6")
    }

    func testLoadingWithSectionsSort() {
        UserDefaults.standard.setSort(DataSources.dgps.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Feature Number",
                    key: #keyPath(DifferentialGPSStation.featureNumber),
                    type: .int),
                ascending: true,
                section: true)
        ])

        var dgps = DGPSStationModel()
        dgps.volumeNumber = "PUB 112"
        dgps.aidType = "Differential GPS Stations"
        dgps.geopoliticalHeading = "KOREA"
        dgps.regionHeading = "region heading"
        dgps.sectionHeader = "KOREA: region heading"
        dgps.precedingNote = "preceeding note"
        dgps.featureNumber = 6
        dgps.name = "Chojin Dan Lt"
        dgps.position = "1°00'00\"N \n2°00'00.00\"E"
        dgps.latitude = 1.0
        dgps.longitude = 2.0
        dgps.stationID = "T670\nR740\nR741"
        dgps.range = 100
        dgps.frequency = 292
        dgps.transferRate = 200
        dgps.remarks = "Message types: 3, 5, 7, 9, 16."
        dgps.postNote = "post note"
        dgps.noticeNumber = 201134
        dgps.removeFromList = "N"
        dgps.deleteFlag = "N"
        dgps.noticeWeek = "34"
        dgps.noticeYear = "2011"

        var dgps2 = DGPSStationModel()
        dgps2.volumeNumber = "PUB 112"
        dgps2.aidType = "Differential GPS Stations"
        dgps2.geopoliticalHeading = "KOREA2"
        dgps2.regionHeading = "region heading2"
        dgps2.sectionHeader = "KOREA: region heading2"
        dgps2.precedingNote = "preceeding note2"
        dgps2.featureNumber = 7
        dgps2.name = "Chojin Dan Lt2"
        dgps2.position = "2°00'00\"N \n3°00'00.00\"E"
        dgps2.latitude = 1.0
        dgps2.longitude = 2.0
        dgps2.stationID = "T670\nR740\nR741"
        dgps2.range = 100
        dgps2.frequency = 292
        dgps2.transferRate = 200
        dgps2.remarks = "Message types: 3, 5, 7, 9, 16."
        dgps2.postNote = "post note"
        dgps2.noticeNumber = 201134
        dgps2.removeFromList = "N"
        dgps2.deleteFlag = "N"
        dgps2.noticeWeek = "35"
        dgps2.noticeYear = "2011"

        let localDataSource = DifferentialGPSStationStaticLocalDataSource()
        InjectedValues[\.dgpsLocalDataSource] = localDataSource
        let remoteDataSource = DGPSStationRemoteDataSource()
        InjectedValues[\.dgpsemoteDataSource] = remoteDataSource
        localDataSource.list = [dgps, dgps2]
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource

        let router = MarlinRouter()

        let routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        struct Container: View {
            @EnvironmentObject var router: MarlinRouter

            var body: some View {
                NavigationStack(path: $router.path) {
                    DGPSStationList()
                        .marlinRoutes()
                }
            }
        }
        let view = Container()
            .environmentObject(routeWaypointRepository)
            .environmentObject(router)
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller

        tester().waitForAbsenceOfView(withAccessibilityLabel: "\(DataSources.dgps.key) Loading")

        tester().waitForView(withAccessibilityLabel: "6 PUB 112")
        tester().waitForView(withAccessibilityLabel: "7 PUB 112")
        tester().waitForView(withAccessibilityLabel: "7")
        tester().waitForView(withAccessibilityLabel: "6")

        tester().tapView(withAccessibilityLabel: "Sort")
        tester().waitForView(withAccessibilityLabel: "\(DataSources.dgps.name) Sort")
        UserDefaults.standard.setSort(DataSources.dgps.key, sort: [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Volume Number",
                    key: #keyPath(DifferentialGPSStation.volumeNumber),
                    type: .string),
                ascending: true,
                section: true)
        ])
        tester().tapView(withAccessibilityLabel: "Close Sort")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "7")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "6")
        tester().waitForView(withAccessibilityLabel: "PUB 112")
    }
}
