//
//  MarlinRoute.swift
//  Marlin
//
//  Created by Daniel Barela on 6/30/23.
//

import Foundation
import SwiftUI
import CoreData

class MarlinRouter: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
}

enum MarlinRoute: Hashable {
    case exportGeoPackage(useMapRegion: Bool)
    case exportGeoPackageDataSource(dataSource: DataSourceDefinitions?, filters: [DataSourceFilterParameter]? = nil)
    case lightSettings
    case mapLayers
    case coordinateDisplaySettings
    case mapSettings
    case about
    case submitReport
    case disclaimer
    case acknowledgements
    case createRoute
    case editRoute(routeURI: URL?)
//    case dataSourceDetail(dataSourceKey: String, itemKey: String)
//    case dataSourceRouteDetail(dataSourceKey: String, itemKey: String, waypointURI: URL)
}

enum UserPlaceRoute: Hashable {
    case detail
    case create
    case edit(uri: URL?)
}

enum NoticeToMarinersRoute: Hashable {
    case notices
    case chartQuery
    case chartList
    case fullView(noticeNumber: Int)
}

enum AsamRoute: Hashable {
    case detail(reference: String)
}

enum ModuRoute: Hashable {
    case detail(name: String)
}

enum PortRoute: Hashable {
    case detail(portNumber: Int)
}

enum LightRoute: Hashable {
    case detail(volumeNumber: String, featureNumber: String)
}

enum RadioBeaconRoute: Hashable {
    case detail(featureNumber: Int, volumeNumber: String)
}

enum DGPSStationRoute: Hashable {
    case detail(featureNumber: Int, volumeNumber: String)
}

enum NavigationalWarningRoute: Hashable {
    case detail(msgYear: Int, msgNumber: Int, navArea: String)
    case areaList(navArea: String)
}

enum PublicationRoute: Hashable {
    case completeVolumes(typeId: Int)
    case nestedFolder(typeId: Int)
    case publicationList(key: String, pubs: [PublicationModel])
    case completeAndChapters(typeId: Int, title: String, chapterTitle: String)
    case publications(typeId: Int)
}

enum GeoPackageRoute: Hashable {
    case detail(featureItem: GeoPackageFeatureItem)
}

enum DataSourceRoute: Hashable {
    case detail(dataSourceKey: String, itemKey: String)
}

extension View {
    func marlinRoutes() -> some View {
        modifier(MarlinRouteModifier())
    }
    func asamRoutes() -> some View {
        modifier(AsamRouteModifier())
    }
    func moduRoutes() -> some View {
        modifier(ModuRouteModifier())
    }
    func portRoutes() -> some View {
        modifier(PortRouteModifier())
    }
    func lightRoutes() -> some View {
        modifier(LightRouteModifier())
    }
    func radioBeaconRoutes() -> some View {
        modifier(RadioBeaconRouteModifier())
    }
    func differentialGPSStationRoutes() -> some View {
        modifier(DifferentialGPSStationRouteModifier())
    }
    func noticeToMarinersRoutes() -> some View {
        modifier(NoticeToMarinersRouteModifier())
    }
    func navigationalWarningRoutes() -> some View {
        modifier(NavigationalWarningRouteModifier())
    }
    func publicationRoutes() -> some View {
        modifier(PublicationRouteModifier())
    }
    func geoPackageRoutes() -> some View {
        modifier(GeoPackageRouteModifier())
    }
    func userPlaceRoutes() -> some View {
        modifier(UserPlaceRouteModifier())
    }
}

struct AsamRouteModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: AsamRoute.self) { item in
                switch item {
                case .detail(let reference):
                    // disable this rule in order to execute a statement prior to returning a view
                    // swiftlint:disable redundant_discardable_let
                    let _ = NotificationCenter.default.post(
                        name: .DismissBottomSheet,
                        object: nil,
                        userInfo: nil
                    )
                    // swiftlint:enable redundant_discardable_let

                    AsamDetailView(reference: reference)
                }
            }
    }
}

struct ModuRouteModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: ModuRoute.self) { item in
                switch item {
                case .detail(let name):
                    // disable this rule in order to execute a statement prior to returning a view
                    // swiftlint:disable redundant_discardable_let
                    let _ = NotificationCenter.default.post(
                        name: .DismissBottomSheet,
                        object: nil,
                        userInfo: nil
                    )
                    // swiftlint:enable redundant_discardable_let

                    ModuDetailView(name: name)
                }
            }
    }
}

struct PortRouteModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: PortRoute.self) { item in
                switch item {
                case .detail(let portNumber):
                    // disable this rule in order to execute a statement prior to returning a view
                    // swiftlint:disable redundant_discardable_let
                    let _ = NotificationCenter.default.post(
                        name: .DismissBottomSheet,
                        object: nil,
                        userInfo: nil
                    )
                    // swiftlint:enable redundant_discardable_let

                    PortDetailView(portNumber: portNumber)
                }
            }
    }
}

struct LightRouteModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: LightRoute.self) { item in
                switch item {
                case .detail(let volumeNumber, let featureNumber):
                    // disable this rule in order to execute a statement prior to returning a view
                    // swiftlint:disable redundant_discardable_let
                    let _ = NotificationCenter.default.post(
                        name: .DismissBottomSheet,
                        object: nil,
                        userInfo: nil
                    )
                    // swiftlint:enable redundant_discardable_let

                    LightDetailView(featureNumber: featureNumber, volumeNumber: volumeNumber)
                }
            }
    }
}

struct RadioBeaconRouteModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: RadioBeaconRoute.self) { item in
                switch item {
                case .detail(let featureNumber, let volumeNumber):
                    // disable this rule in order to execute a statement prior to returning a view
                    // swiftlint:disable redundant_discardable_let
                    let _ = NotificationCenter.default.post(
                        name: .DismissBottomSheet,
                        object: nil,
                        userInfo: nil
                    )
                    // swiftlint:enable redundant_discardable_let

                    RadioBeaconDetailView(featureNumber: featureNumber, volumeNumber: volumeNumber)
                }
            }
    }
}

struct DifferentialGPSStationRouteModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: DGPSStationRoute.self) { item in
                switch item {
                case .detail(let featureNumber, let volumeNumber):
                    // disable this rule in order to execute a statement prior to returning a view
                    // swiftlint:disable redundant_discardable_let
                    let _ = NotificationCenter.default.post(
                        name: .DismissBottomSheet,
                        object: nil,
                        userInfo: nil
                    )
                    // swiftlint:enable redundant_discardable_let

                    DGPSStationDetailView(featureNumber: featureNumber, volumeNumber: volumeNumber)
                }
            }
    }
}

struct NoticeToMarinersRouteModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NoticeToMarinersRoute.self) { item in
                switch item {
                case .fullView(let noticeNumber):
                    NoticeToMarinersFullNoticeView(noticeNumber: noticeNumber)
                case .notices:
                    NoticesList()
                case .chartQuery:
                    ChartCorrectionQuery()
                case .chartList:
                    ChartCorrectionList()
                }
            }
    }
}

struct NavigationalWarningRouteModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationalWarningRoute.self) { item in
                switch item {
                case .detail(let msgYear, let msgNumber, let navArea):
                    // disable this rule in order to execute a statement prior to returning a view
                    // swiftlint:disable redundant_discardable_let
                    let _ = NotificationCenter.default.post(
                        name: .DismissBottomSheet,
                        object: nil,
                        userInfo: nil
                    )
                    // swiftlint:enable redundant_discardable_let
                    NavigationalWarningDetailView(msgYear: msgYear, msgNumber: msgNumber, navArea: navArea)
                case .areaList(let navArea):
                    NavigationalWarningNavAreaListView(
                        navArea: navArea,
                        mapName: "Navigational Warning List View Map"
                    )
                }
            }
    }
}

struct PublicationRouteModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: PublicationRoute.self) { item in
                switch item {
                case .publications(typeId: let typeId):
                    PublicationsTypeIdListView(pubTypeId: typeId)
                case .completeVolumes(typeId: let typeId):
                    PublicationsCompleteVolumesList(pubTypeId: typeId)
                case .nestedFolder(typeId: let typeId):
                    PublicationsNestedFolder(pubTypeId: typeId)
                case .publicationList(key: let key, pubs: let pubs):
                    PublicationsListView(key: key, publications: pubs)
                case .completeAndChapters(typeId: let typeId, title: let title, chapterTitle: let chapterTitle):
                    PublicationsChaptersList(pubTypeId: typeId, title: title, chapterTitle: chapterTitle)
                }
            }
    }
}

struct GeoPackageRouteModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: GeoPackageRoute.self) { item in
                switch item {
                case .detail(let featureItem):
                    GeoPackageFeatureItemSummaryView(featureItem: featureItem)
                }
            }
    }
}

struct UserPlaceRouteModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: UserPlaceRoute.self) { item in
                switch item {
                case .create:
                    CreatePlaceView()
                default:
                    Text("no")
                }
            }
    }
}

struct MarlinRouteModifier: ViewModifier {
    @EnvironmentObject var dataSourceList: DataSourceList

    func createExportDataSources() -> [DataSourceDefinitions] {
        var dataSources: [DataSourceDefinitions] = []

        for dataSource in dataSourceList.mappedDataSources {
            if let def = DataSourceDefinitions.from(dataSource.dataSource) {
                dataSources.append(def)
            }
        }
        return dataSources
    }

    func body(content: Content) -> some View {
        content
            .asamRoutes()
            .moduRoutes()
            .portRoutes()
            .lightRoutes()
            .radioBeaconRoutes()
            .differentialGPSStationRoutes()
            .noticeToMarinersRoutes()
            .navigationalWarningRoutes()
            .publicationRoutes()
            .userPlaceRoutes()
            .navigationDestination(for: MarlinRoute.self) { item in
                switch item {
                case .exportGeoPackageDataSource(let dataSource, let filters):
                    GeoPackageExportView(
                        dataSources: dataSource != nil ? [dataSource!] : [],
                        filters: filters,
                        useMapRegion: false)
                case .exportGeoPackage(let useMapRegion):
                    GeoPackageExportView(dataSources: createExportDataSources(), useMapRegion: useMapRegion)
                case .lightSettings:
                    LightSettingsView()
                case .mapSettings:
                    MapSettings()
                case .mapLayers:
                    MapLayersView()
                case .coordinateDisplaySettings:
                    CoordinateDisplaySettings()
                case .about:
                    AboutView()
                case .submitReport:
                    SubmitReportView()
                case .disclaimer:
                    ScrollView {
                        DisclaimerView()
                    }
                case .acknowledgements:
                    AcknowledgementsView()
                case .createRoute:
                    CreateRouteView()
                case .editRoute(let routeURI):
                    CreateRouteView(routeURI: routeURI)
                }
            }
            .navigationDestination(for: ItemWrapper.self) { item in
                if let dataSourceViewBuilder = item.dataSource as? (any DataSourceViewBuilder) {
                    dataSourceViewBuilder.detailView
                }
            }
    }
}
