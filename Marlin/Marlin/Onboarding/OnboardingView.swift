//
//  OnboardingView.swift
//  Marlin
//
//  Created by Daniel Barela on 10/18/22.
//

import SwiftUI
import CoreLocation

protocol UserNotificationCenter {
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void)
    func removeAllPendingNotificationRequests()
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)
}

extension UNUserNotificationCenter: UserNotificationCenter {}

struct OnboardingView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    let WELCOME_TAB = 1
    let DISCLAIMER_TAB = 2
    let LOCATION_TAB = 3
    let NOTIFICATION_TAB = 4
    let DATA_TABS_TAB = 5
    let DATA_MAP_TAB = 6
        
    @State private var tabSelection = 1
    @AppStorage("disclaimerAccepted") var disclaimerAccepted: Bool = false
    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false
    
    @State private var requestedLocationAuthorization = false
    let locationAuthorizationStatusChangedPub = 
    NotificationCenter.default.publisher(for: .LocationAuthorizationStatusChanged)

    @State private var notificationsAuthorized = false
    
    @EnvironmentObject var dataSourceList: DataSourceList
    var userNotificationCenter: UserNotificationCenter
    
    @State var locationAuthorizationStatus: CLAuthorizationStatus?
    
    init(userNotificationCenter: UserNotificationCenter = UNUserNotificationCenter.current()) {
        self.userNotificationCenter = userNotificationCenter
    }
    
    var body: some View {
        TabView(selection: $tabSelection) {
            if shouldShowTab(tab: WELCOME_TAB) {
                welcomeTab()
                    .onAppear {
                        Metrics.shared.appRoute(["embark", "welcome"])
                    }
                    .tag(WELCOME_TAB)
            }
            
            if shouldShowTab(tab: DISCLAIMER_TAB) {
                disclaimerTab()
                    .onAppear {
                        Metrics.shared.appRoute(["embark", "disclaimer"])
                    }
                    .tag(DISCLAIMER_TAB)
            }
            
            if shouldShowTab(tab: LOCATION_TAB) {
                locationTab()
                    .onAppear {
                        Metrics.shared.appRoute(["embark", "Location"])
                    }
                    .tag(LOCATION_TAB)
            }
            
            if shouldShowTab(tab: NOTIFICATION_TAB) {
                notificationTab()
                    .onAppear {
                        Metrics.shared.appRoute(["embark", "notification"])
                    }
                    .tag(NOTIFICATION_TAB)
            }
            
            if shouldShowTab(tab: DATA_TABS_TAB) {
                dataTabsTab()
                    .onAppear {
                        Metrics.shared.appRoute(["embark", "tabs"])
                    }
                    .tag(DATA_TABS_TAB)
            }
            
            if shouldShowTab(tab: DATA_MAP_TAB) {
                dataMapTab()
                    .onAppear {
                        Metrics.shared.appRoute(["embark", "map"])
                    }
                    .tag(DATA_MAP_TAB)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onReceive(locationAuthorizationStatusChangedPub) { output in
            if let status = output.object as? CLAuthorizationStatus {
                locationAuthorizationStatus = status
            }
            if requestedLocationAuthorization {
                nextTab(currentTab: LOCATION_TAB)
            }
        }
        .onAppear {
            userNotificationCenter.getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    notificationsAuthorized = true
                } else {
                    notificationsAuthorized = false
                }
            }
        }
        .gradientView()
        .onAppear {
            locationAuthorizationStatus = locationManager.locationStatus ?? .notDetermined
        }
    }
    
    func shouldShowTab(tab: Int) -> Bool {
        switch tab {
        case WELCOME_TAB:
            return true
        case DISCLAIMER_TAB:
            return !disclaimerAccepted
        case LOCATION_TAB:
            if locationAuthorizationStatus != .authorizedWhenInUse && locationAuthorizationStatus != .authorizedAlways {
                return true
            }
            return false
        case NOTIFICATION_TAB:
            return !notificationsAuthorized
        case DATA_TABS_TAB:
            return true
        default:
            return true
        }
    }
    
    func nextTab(currentTab: Int) {
        switch currentTab {
        case WELCOME_TAB:
            if !disclaimerAccepted {
                tabSelection = DISCLAIMER_TAB
            } else if locationAuthorizationStatus != .authorizedWhenInUse 
                        && locationAuthorizationStatus != .authorizedAlways {
                tabSelection = LOCATION_TAB
            } else {
                userNotificationCenter.getNotificationSettings { settings in
                    if settings.authorizationStatus == .authorized {
                        tabSelection = DATA_TABS_TAB
                    } else {
                        tabSelection = NOTIFICATION_TAB
                    }
                }
            }
        case DISCLAIMER_TAB:
            if locationAuthorizationStatus != .authorizedWhenInUse && locationAuthorizationStatus != .authorizedAlways {
                tabSelection = LOCATION_TAB
            } else {
                userNotificationCenter.getNotificationSettings { settings in
                    if settings.authorizationStatus == .authorized {
                        tabSelection = DATA_TABS_TAB
                    } else {
                        tabSelection = NOTIFICATION_TAB
                    }
                }
            }
        case LOCATION_TAB:
            userNotificationCenter.getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    tabSelection = DATA_TABS_TAB
                } else {
                    tabSelection = NOTIFICATION_TAB
                }
            }
        case NOTIFICATION_TAB:
            tabSelection = DATA_TABS_TAB
        case DATA_TABS_TAB:
            tabSelection = DATA_MAP_TAB
        default:
            tabSelection = WELCOME_TAB
        }
    }
    
    @ViewBuilder
    func welcomeTab() -> some View {
        OnboardingTabTemplate(
            title: "Welcome To Marlin",
            explanation: """
                Marlin puts NGA's Maritime Safety Information datasets at your fingertips even when offline. \
                The next few screens will allow you to customize your experience to meet your needs.
            """,
            imageName: "marlin_large",
            buttons:
            Button("Set Sail") {
                nextTab(currentTab: WELCOME_TAB)
            }
            .tint(Color.primaryColor)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
        )
    }
    
    @ViewBuilder
    func disclaimerTab() -> some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                Text("Disclaimer")
                    .font(.headline4)
                    .bold()
            
                DisclaimerView()
                Button("Accept") {
                    disclaimerAccepted.toggle()
                    nextTab(currentTab: DISCLAIMER_TAB)
                }
                .tint(Color.primaryColor)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
            }
        }
        .padding(.all, 16)
    }
    
    @ViewBuilder
    func locationTab() -> some View {
        OnboardingTabTemplate(
            title: "Enable Location",
            explanation: """
                Marlin can show your location on the map and provide location aware filtering. \
                Would you like to allow Marlin to access your location?
            """,
            systemImageName: "location.circle.fill",
            buttons:
                VStack(spacing: 16) {
                    Button("Yes, Enable My Location") {
                        requestedLocationAuthorization = true
                        locationManager.requestAuthorization()
                    }
                    .tint(Color.primaryColor)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    
                    Button("Not Now") {
                        nextTab(currentTab: LOCATION_TAB)
                    }
                    .tint(Color.onPrimaryColor)
                    .buttonStyle(.plain)
                }
        )
    }
    
    @ViewBuilder
    func notificationTab() -> some View {
        OnboardingTabTemplate(
            title: "Allow Notifications",
            explanation: "Would you like to recieve alerts when new data is available?",
            systemImageName: "bell.badge.fill",
            buttons:
                VStack(spacing: 16) {
                    Button("Yes, Enable Notifications") {
                        userNotificationCenter.requestAuthorization(
                            options: [.alert, .sound, .badge]) { _, _ in
                            nextTab(currentTab: NOTIFICATION_TAB)
                        }
                    }
                    .tint(Color.primaryColor)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    
                    Button("Not Now") {
                        nextTab(currentTab: NOTIFICATION_TAB)
                    }
                    .tint(Color.onPrimaryColor)
                    .buttonStyle(.plain)
                }
        )
    }
    
    @ViewBuilder
    func dataTabsTab() -> some View {
        OnboardingTabTemplate(
            title: "Marlin Tabs",
            explanation: """
                Choose up to 4 dataset tabs for the tab bar. \
                Other datasets will be accessible in the navigation menu.
            """,
            imageAreaContent:
                DataSourceTabGrid()
                .frame(maxHeight: .infinity),
            buttons:
                Button("Next") {
                    // when we add the tabs to the tab list, we are adding them to the front of the tab list, 
                    // so we need to reverse that list
                    // This will make the tabs appear in the order the user chose them
                    dataSourceList.tabs.reverse()
                    for i in 0...(dataSourceList.tabs.count - 1) {
                        dataSourceList.tabs[i].order = i
                    }
                    nextTab(currentTab: DATA_TABS_TAB)
                }
                .tint(Color.primaryColor)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
        )
    }
    
    @ViewBuilder
    func dataMapTab() -> some View {
        OnboardingTabTemplate(
            title: "Marlin Map",
            explanation: """
                Choose what datasets you want to see on the map. \
                This can always be changed via the navigation menu.
            """,
            imageAreaContent:
                DataSourceMapGrid()
                .frame(maxHeight: .infinity),
            buttons:
                Button("Take Me To Marlin") {
                    onboardingComplete = true
                }
                .tint(Color.primaryColor)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
        )
    }
}
