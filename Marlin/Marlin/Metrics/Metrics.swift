//
//  Metrics.swift
//  Marlin
//
//  Created by Daniel Barela on 10/24/22.
//

import Foundation
import MatomoTracker

class Metrics {
    
    static let MATOMO_URL = "https://webanalytics.nga.mil/matomo.php"
    static let MATOMO_SITEID = "795"
    
    static let shared = Metrics()
    
    private init() {
        
    }
    
    func appRoute(_ route: [String]) {
        MatomoTracker.shared?.track(view:route)
    }
    
    func appLaunch() {
        NSLog("Record App Launch")
        appRoute(["main"])
    }
    
    func mapView() {
        NSLog("Record Map View")
        appRoute(["map"])
    }
    
    func mapSettingsView() {
        NSLog("Record Map Settings View")
        appRoute(["mapSettings"])
    }
    
    func mapLayersView() {
        appRoute(["mapLayers"])
    }
    
    func sideNavigationView() {
        NSLog("Record Side Navigation View")
        appRoute(["sideNavigation"])
    }
    
    func aboutView() {
        NSLog("Record About View")
        appRoute(["about", "list"])
    }
    
    func submitReportView() {
        NSLog("Record Submit Report View")
        appRoute(["report", "list"])
    }
    
    func searchView() {
        NSLog("Record Search View")
        appRoute(["mapSearch"])
    }
    
    func noticeToMarinersView() {
        NSLog("Record Notice To Mariners")
        appRoute(["ntms", "home"])
    }
    
    func dataSourceSort(dataSource: any DataSource.Type) {
        NSLog("Record Data Source Sort \(dataSource.key)")
        appRoute(["\(dataSource.metricsKey)", "sort"])
    }
    
    func dataSourceFilter(dataSource: any DataSource.Type) {
        NSLog("Record Data Source Filter \(dataSource.key)")
        appRoute(["\(dataSource.metricsKey)", "filter"])
    }
    
    func dataSourceBottomSheet(dataSource: any DataSource.Type) {
        NSLog("Record Data Source BottomSheet \(dataSource.key)")
        appRoute(["\(dataSource.metricsKey)", "sheet"])
    }
    
    func dataSourceList(dataSource: any DataSource.Type) {
        NSLog("Record Data Source List \(dataSource.key)")
        appRoute(["\(dataSource.metricsKey)", "list"])
    }
    
    func dataSourceDetail(dataSource: any DataSource.Type) {
        NSLog("Record Data Source Detail \(dataSource.key)")
        appRoute(["\(dataSource.metricsKey)", "detail"])
    }
    
    func search(query: String, resultCount: Int) {
        NSLog("Record search")
        MatomoTracker.shared?.trackSearch(query: query, category: nil, resultCount: resultCount)
    }
    
    func fileDownload(url: URL?) {
        guard let url else {
            return
        }
        if let tracker = MatomoTracker.shared {
            let event = Event(tracker: tracker, action: ["download"], url: url, eventCategory: "download", eventAction: "download", eventName: nil, eventValue: nil, customTrackingParameters: ["download": url.absoluteString], dimensions: [], isCustomAction: true)
            MatomoTracker.shared?.track(event)
        }
    }
    
    func dispatch() {
        MatomoTracker.shared?.dispatch()
    }
    
}

extension MatomoTracker {
    static let shared: MatomoTracker? = UserDefaults.standard.metricsEnabled ? MatomoTracker(siteId: Metrics.MATOMO_SITEID, baseURL: URL(string: Metrics.MATOMO_URL)!) : nil
}
