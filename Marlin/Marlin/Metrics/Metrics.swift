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
    
    func appLaunch() {
        NSLog("Record App Launch")
        MatomoTracker.shared.track(view:["app"])
    }
    
    func mapView() {
        NSLog("Record Map View")
        MatomoTracker.shared.track(view:["app", "map"])
    }
    
    func mapSettingsView() {
        NSLog("Record Map Settings View")
        MatomoTracker.shared.track(view:["app", "map", "settings"])
    }
    
    func sideNavigationView() {
        NSLog("Record Side Navigation View")
        MatomoTracker.shared.track(view:["app", "sideNavigation"])
    }
    
    func settingsView() {
        NSLog("Record Settings View")
        MatomoTracker.shared.track(view:["app", "settings"])
    }
    
    func submitReportView() {
        NSLog("Record Submit Report View")
        MatomoTracker.shared.track(view:["app", "submitReport"])
    }
    
    func searchView() {
        NSLog("Record Search View")
        MatomoTracker.shared.track(view:["app", "map", "search"])
    }
    
    func dataSourceList(dataSource: any DataSource.Type) {
        NSLog("Record Data Source List \(dataSource.key)")
        MatomoTracker.shared.track(view:["app", "\(dataSource.key)List"])
    }
    
    func dataSourceDetail(dataSource: any DataSource.Type) {
        NSLog("Record Data Source Detail \(dataSource.key)")
        MatomoTracker.shared.track(view:["app", "\(dataSource.key)List", "\(dataSource.key)Detail"])
    }
    
    func search(query: String, resultCount: Int) {
        NSLog("Record search")
        MatomoTracker.shared.trackSearch(query: query, category: nil, resultCount: resultCount)
    }
    
    func fileDownload(url: URL?) {
        guard let url else {
            return
        }
        let event = Event(tracker: MatomoTracker.shared, action: ["download"], url: url, eventCategory: "download", eventAction: "download", eventName: nil, eventValue: nil, customTrackingParameters: ["download": url.absoluteString], dimensions: [], isCustomAction: true)
        MatomoTracker.shared.track(event)
    }
    
}

extension MatomoTracker {
    static let shared: MatomoTracker = MatomoTracker(siteId: Metrics.MATOMO_SITEID, baseURL: URL(string: Metrics.MATOMO_URL)!)
}
