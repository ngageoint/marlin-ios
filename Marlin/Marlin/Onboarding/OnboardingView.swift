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

struct OnboardingView<Location>: View where Location: LocationManagerProtocol {
    let WELCOME_TAB = 1
    let DISCLAIMER_TAB = 2
    let LOCATION_TAB = 3
    let NOTIFICATION_TAB = 4
    let DATA_TABS_TAB = 5
    let DATA_MAP_TAB = 6
    
    let gridColumns = Array(repeating: GridItem(.flexible()), count: 3)
    let numColumns = 3
    
    @State private var tabSelection = 1
    @AppStorage("disclaimerAccepted") var disclaimerAccepted: Bool = false
    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    
    @State private var requestedLocationAuthorization = false
    let locationAuthorizationStatusChangedPub = NotificationCenter.default.publisher(for: .LocationAuthorizationStatusChanged)
    
    @State private var notificationsAuthorized = false
    
    private var asamIsTab: Bool {
        dataSourceList.tabs.contains { item in
            item.key == Asam.key
        }
    }
    private var moduIsTab: Bool {
        dataSourceList.tabs.contains { item in
            item.key == Modu.key
        }
    }
    private var lightIsTab: Bool {
        dataSourceList.tabs.contains { item in
            item.key == Light.key
        }
    }
    private var navWarningIsTab: Bool {
        dataSourceList.tabs.contains { item in
            item.key == NavigationalWarning.key
        }
    }
    private var portIsTab: Bool {
        dataSourceList.tabs.contains { item in
            item.key == Port.key
        }
    }
    private var radioBeaconIsTab: Bool {
        dataSourceList.tabs.contains { item in
            item.key == RadioBeacon.key
        }
    }
    private var dgpsIsTab: Bool {
        dataSourceList.tabs.contains { item in
            item.key == DifferentialGPSStation.key
        }
    }
    private var epubIsTab: Bool {
        dataSourceList.tabs.contains { item in
            item.key == ElectronicPublication.key
        }
    }
    private var ntmIsTab: Bool {
        dataSourceList.tabs.contains { item in
            item.key == NoticeToMariners.key
        }
    }
    
    @AppStorage("showOnMap\(Asam.key)") var asamIsMapped: Bool = false
    @AppStorage("showOnMap\(Modu.key)") var moduIsMapped: Bool = false
    @AppStorage("showOnMap\(Light.key)") var lightIsMapped: Bool = false
    @AppStorage("showOnMap\(Port.key)") var portIsMapped: Bool = false
    @AppStorage("showOnMap\(RadioBeacon.key)") var radioBeaconIsMapped: Bool = false
    @AppStorage("showOnMap\(DifferentialGPSStation.key)") var dgpsIsMapped: Bool = false
    
    @ObservedObject var dataSourceList: DataSourceList
    var locationManager: Location
    var userNotificationCenter: UserNotificationCenter
    
    @State var locationAuthorizationStatus: CLAuthorizationStatus
    
    init(dataSourceList: DataSourceList, locationManager: Location = LocationManager.shared, userNotificationCenter: UserNotificationCenter = UNUserNotificationCenter.current()) {
        self.dataSourceList = dataSourceList
        self.locationManager = locationManager
        self.userNotificationCenter = userNotificationCenter
        self._locationAuthorizationStatus = State(initialValue: locationManager.locationStatus ?? .notDetermined)
    }
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $tabSelection) {
                if shouldShowTab(tab: WELCOME_TAB) {
                    welcomeTab(geometry: geometry)
                        .tag(WELCOME_TAB)
                }
                
                if shouldShowTab(tab: DISCLAIMER_TAB) {
                    disclaimerTab(geometry: geometry)
                        .tag(DISCLAIMER_TAB)
                }
                
                if shouldShowTab(tab: LOCATION_TAB) {
                    locationTab(geometry: geometry)
                        .tag(LOCATION_TAB)
                }
                
                if shouldShowTab(tab: NOTIFICATION_TAB) {
                    notificationTab(geometry: geometry)
                        .tag(NOTIFICATION_TAB)
                }
                
                if shouldShowTab(tab: DATA_TABS_TAB) {
                    dataTabsTab(geometry: geometry)
                        .tag(DATA_TABS_TAB)
                }
                
                if shouldShowTab(tab: DATA_MAP_TAB) {
                    dataMapTab(geometry: geometry)
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
                userNotificationCenter.getNotificationSettings { (settings) in
                    if(settings.authorizationStatus == .authorized) {
                        notificationsAuthorized = true
                    } else {
                        notificationsAuthorized = false
                    }
                }
            }
        }
        .gradientView()
    }
    
    @ViewBuilder
    func tabContent<M:View, T:View>(geometry: GeometryProxy, imageName: String? = nil, systemImageName: String? = nil, imageAreaContent: M? = EmptyView(), title: String, explanation: String?, buttons: T) -> some View {
        
        VStack(alignment: .center, spacing: 16) {
            HStack(alignment: .bottom) {
                VStack(alignment: .center, spacing: 16) {
                    Text(title)
                        .font(.headline4)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .opacity(0.94)
                    
                    if let explanation = explanation {
                        Text(explanation)
                            .font(.headline6)
                            .opacity(0.87)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            imageAreaContent
            if verticalSizeClass != .compact {
                if let imageName = imageName {
                    Image(imageName)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: .infinity)
                } else if let systemImageName = systemImageName {
                    Image(systemName: systemImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(Color.black)
                        .frame(maxHeight: .infinity)
                }
            } else if (imageAreaContent is EmptyView) {
                Spacer()
                    .frame(maxHeight: 24)
            }
            buttons
        }
        .padding(16)
        .frame(maxHeight: .infinity)
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
            } else if locationAuthorizationStatus != .authorizedWhenInUse && locationAuthorizationStatus != .authorizedAlways {
                tabSelection = LOCATION_TAB
            } else {
                userNotificationCenter.getNotificationSettings { (settings) in
                    if(settings.authorizationStatus == .authorized) {
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
                userNotificationCenter.getNotificationSettings { (settings) in
                    if(settings.authorizationStatus == .authorized) {
                        tabSelection = DATA_TABS_TAB
                    } else {
                        tabSelection = NOTIFICATION_TAB
                    }
                }
            }
        case LOCATION_TAB:
            userNotificationCenter.getNotificationSettings { (settings) in
                if(settings.authorizationStatus == .authorized) {
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
    func welcomeTab(geometry: GeometryProxy) -> some View {
        tabContent(geometry: geometry, imageName: "marlin_large", title: "Welcome to Marlin", explanation: "Marlin puts NGA's Maritime Safety Information datasets at your fingertips even when offline. The next few screens will allow you to customize your experience to meet your needs.", buttons:
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
    func disclaimerTab(geometry: GeometryProxy) -> some View {
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
    func locationTab(geometry: GeometryProxy) -> some View {
        tabContent(geometry: geometry, systemImageName: "location.circle.fill", title: "Enable Location", explanation: "Marlin can show your location on the map and provide location aware filtering. Would you like to allow Marlin to access your location?", buttons:
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
    func notificationTab(geometry: GeometryProxy) -> some View {
        tabContent(geometry: geometry, systemImageName: "bell.badge.fill", title: "Allow Notifications", explanation: "Would you like to recieve alerts when new data is available?", buttons:
                    VStack(spacing: 16) {
                        Button("Yes, Enable Notifications") {
                            userNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
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
    func dataTabsTab(geometry: GeometryProxy) -> some View {
        tabContent(geometry: geometry, imageAreaContent:
                    dataSourceTabGrid(gridSize: verticalSizeClass != .compact ? 100 : 75)
            .frame(maxHeight: .infinity)
                   ,
                   title: "Marlin Tabs", explanation: "Choose up to 4 dataset tabs for the tab bar.  Other datasets will be accessible in the navigation menu.", buttons:
            Button("Next") {
                // when we add the tabs to the tab list, we are adding them to the front of the tab list, so we need to reverse that list
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
    func dataMapTab(geometry: GeometryProxy) -> some View {
        tabContent(geometry: geometry, imageAreaContent:
                    dataSourceMapGrid(gridSize: verticalSizeClass != .compact ? 100 : 100)
            .frame(maxHeight: .infinity),
                   title: "Marlin Map", explanation: "Choose what datasets you want to see on the map.  This can always be changed via the navigation menu.", buttons:
                Button("Take Me To Marlin") {
                    onboardingComplete = true
                }
                .tint(Color.primaryColor)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
        )
    }
    
    @ViewBuilder
    func dataSourceTabGrid(gridSize: CGFloat) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: gridSize))]) {
            VStack(alignment: .center) {
                if let image = Asam.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: Asam.color))))
                }
                Text(Asam.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                if asamIsTab {
                    dataSourceList.addItemToNonTabs(dataSourceItem: DataSourceItem(dataSource: Asam.self), position: 0)
                } else {
                    dataSourceList.addItemToTabs(dataSourceItem: DataSourceItem(dataSource: Asam.self), position: 0)
                }
            }
            .overlay(CheckBadge(on: .constant(asamIsTab))
                .accessibilityElement()
                .accessibilityLabel("\(Asam.fullDataSourceName) Tab \(asamIsTab ? "On" : "Off")"))
            .padding(8)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(Asam.fullDataSourceName) Tab")
            
            VStack(alignment: .center) {
                if let image = Modu.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: Modu.color))))
                }
                Text(Modu.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                if moduIsTab {
                    dataSourceList.addItemToNonTabs(dataSourceItem: DataSourceItem(dataSource: Modu.self), position: 0)
                } else {
                    dataSourceList.addItemToTabs(dataSourceItem: DataSourceItem(dataSource: Modu.self), position: 0)
                }
            }
            .overlay(
                CheckBadge(on: .constant(moduIsTab))
                    .accessibilityElement()
                    .accessibilityLabel("\(Modu.fullDataSourceName) Tab \(moduIsTab ? "On" : "Off")")
            )
            .padding(8)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(Modu.fullDataSourceName) Tab")
            
            VStack(alignment: .center) {
                if let image = Light.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: Light.color))))
                }
                Text(Light.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                if lightIsTab {
                    dataSourceList.addItemToNonTabs(dataSourceItem: DataSourceItem(dataSource: Light.self), position: 0)
                } else {
                    dataSourceList.addItemToTabs(dataSourceItem: DataSourceItem(dataSource: Light.self), position: 0)
                }
            }
            .overlay(CheckBadge(on: .constant(lightIsTab))
                .accessibilityElement()
                .accessibilityLabel("\(Light.fullDataSourceName) Tab \(lightIsTab ? "On" : "Off")"))
            .padding(8)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(Light.fullDataSourceName) Tab")
            
            VStack(alignment: .center) {
                if let image = NavigationalWarning.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: NavigationalWarning.color))))
                }
                Text(NavigationalWarning.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                if navWarningIsTab {
                    dataSourceList.addItemToNonTabs(dataSourceItem: DataSourceItem(dataSource: NavigationalWarning.self), position: 0)
                } else {
                    dataSourceList.addItemToTabs(dataSourceItem: DataSourceItem(dataSource: NavigationalWarning.self), position: 0)
                }
            }
            .overlay(CheckBadge(on: .constant(navWarningIsTab))
                .accessibilityElement()
                .accessibilityLabel("\(NavigationalWarning.fullDataSourceName) Tab \(navWarningIsTab ? "On" : "Off")"))
            .padding(8)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(NavigationalWarning.fullDataSourceName) Tab")
            
            VStack(alignment: .center) {
                if let image = Port.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: Port.color))))
                }
                Text(Port.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                if portIsTab {
                    dataSourceList.addItemToNonTabs(dataSourceItem: DataSourceItem(dataSource: Port.self), position: 0)
                } else {
                    dataSourceList.addItemToTabs(dataSourceItem: DataSourceItem(dataSource: Port.self), position: 0)
                }
            }
            .overlay(CheckBadge(on: .constant(portIsTab))
                .accessibilityElement()
                .accessibilityLabel("\(Port.fullDataSourceName) Tab \(portIsTab ? "On" : "Off")"))
            .padding(8)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(Port.fullDataSourceName) Tab")
            
            VStack(alignment: .center) {
                if let image = RadioBeacon.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: RadioBeacon.color))))
                }
                Text(RadioBeacon.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                if radioBeaconIsTab {
                    dataSourceList.addItemToNonTabs(dataSourceItem: DataSourceItem(dataSource: RadioBeacon.self), position: 0)
                } else {
                    dataSourceList.addItemToTabs(dataSourceItem: DataSourceItem(dataSource: RadioBeacon.self), position: 0)
                }
            }
            .overlay(CheckBadge(on: .constant(radioBeaconIsTab))
                .accessibilityElement()
                .accessibilityLabel("\(RadioBeacon.fullDataSourceName) Tab \(radioBeaconIsTab ? "On" : "Off")"))
            .padding(8)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(RadioBeacon.fullDataSourceName) Tab")
            
            VStack(alignment: .center) {
                if let image = DifferentialGPSStation.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: DifferentialGPSStation.color))))
                }
                Text(DifferentialGPSStation.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                if dgpsIsTab {
                    dataSourceList.addItemToNonTabs(dataSourceItem: DataSourceItem(dataSource: DifferentialGPSStation.self), position: 0)
                } else {
                    dataSourceList.addItemToTabs(dataSourceItem: DataSourceItem(dataSource: DifferentialGPSStation.self), position: 0)
                }
            }
            .overlay(CheckBadge(on: .constant(dgpsIsTab))
                .accessibilityElement()
                .accessibilityLabel("\(DifferentialGPSStation.fullDataSourceName) Tab \(dgpsIsTab ? "On" : "Off")"))
            .padding(8)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(DifferentialGPSStation.fullDataSourceName) Tab")
            
            VStack(alignment: .center) {
                if let image = ElectronicPublication.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: ElectronicPublication.color))))
                }
                Text(ElectronicPublication.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                if epubIsTab {
                    dataSourceList.addItemToNonTabs(dataSourceItem: DataSourceItem(dataSource: ElectronicPublication.self), position: 0)
                } else {
                    dataSourceList.addItemToTabs(dataSourceItem: DataSourceItem(dataSource: ElectronicPublication.self), position: 0)
                }
            }
            .overlay(CheckBadge(on: .constant(epubIsTab))
                .accessibilityElement()
                .accessibilityLabel("\(ElectronicPublication.fullDataSourceName) Tab \(epubIsTab ? "On" : "Off")"))
            .padding(8)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(ElectronicPublication.fullDataSourceName) Tab")
            
            VStack(alignment: .center) {
                if let image = NoticeToMariners.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: NoticeToMariners.color))))
                }
                Text(NoticeToMariners.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                if ntmIsTab {
                    dataSourceList.addItemToNonTabs(dataSourceItem: DataSourceItem(dataSource: NoticeToMariners.self), position: 0)
                } else {
                    dataSourceList.addItemToTabs(dataSourceItem: DataSourceItem(dataSource: NoticeToMariners.self), position: 0)
                }
            }
            .overlay(CheckBadge(on: .constant(ntmIsTab))
                .accessibilityElement()
                .accessibilityLabel("\(NoticeToMariners.fullDataSourceName) Tab \(ntmIsTab ? "On" : "Off")"))
            .padding(8)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(NoticeToMariners.fullDataSourceName) Tab")
        }
        .frame(maxWidth: 500, alignment: .center)
    }
    
    @ViewBuilder
    func dataSourceMapGrid(gridSize: CGFloat) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: gridSize))]) {
            
            VStack(alignment: .center) {
                if let image = Asam.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: Asam.color))))
                }
                Text(Asam.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                asamIsMapped = !asamIsMapped
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(Asam.fullDataSourceName) Map")
            .overlay(CheckBadge(on: $asamIsMapped)
                .accessibilityElement()
                .accessibilityLabel("\(Asam.fullDataSourceName) Map \(asamIsMapped ? "On" : "Off")"))
            .padding(8)
            
            VStack(alignment: .center) {
                if let image = Modu.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: Modu.color))))
                    
                }
                Text(Modu.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                moduIsMapped = !moduIsMapped
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(Modu.fullDataSourceName) Map")
            .overlay(CheckBadge(on: $moduIsMapped)
                .accessibilityElement()
                .accessibilityLabel("\(Modu.fullDataSourceName) Map \(moduIsMapped ? "On" : "Off")"))
            .padding(8)
            
            VStack(alignment: .center) {
                if let image = Light.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .tint(Color.white)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: Light.color))))
                }
                Text(Light.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                lightIsMapped = !lightIsMapped
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(Light.fullDataSourceName) Map")
            .overlay(CheckBadge(on: $lightIsMapped)
                .accessibilityElement()
                .accessibilityLabel("\(Light.fullDataSourceName) Map \(lightIsMapped ? "On" : "Off")"))
            .padding(8)
            
            VStack(alignment: .center) {
                if let image = Port.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .tint(Color.white)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: Port.color))))
                }
                Text(Port.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                portIsMapped = !portIsMapped
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(Port.fullDataSourceName) Map")
            .overlay(CheckBadge(on: $portIsMapped)
                .accessibilityElement()
                .accessibilityLabel("\(Port.fullDataSourceName) Map \(portIsMapped ? "On" : "Off")"))
            .padding(8)
            
            VStack(alignment: .center) {
                if let image = RadioBeacon.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .tint(Color.white)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: RadioBeacon.color))))
                }
                Text(RadioBeacon.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                radioBeaconIsMapped = !radioBeaconIsMapped
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(RadioBeacon.fullDataSourceName) Map")
            .overlay(CheckBadge(on: $radioBeaconIsMapped)
                .accessibilityElement()
                .accessibilityLabel("\(RadioBeacon.fullDataSourceName) Map \(radioBeaconIsMapped ? "On" : "Off")"))
            .padding(8)
            
            VStack(alignment: .center) {
                if let image = DifferentialGPSStation.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .frame(width: gridSize / 2, height: gridSize / 2)
                        .tint(Color.white)
                        .clipShape(Circle())
                        .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                            .background(Circle().fill(Color(uiColor: DifferentialGPSStation.color))))
                }
                Text(DifferentialGPSStation.dataSourceName)
                    .foregroundColor(Color.onPrimaryColor)
            }
            .frame(width: gridSize, height: gridSize)
            .background(Color.secondaryColor)
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
            .onTapGesture {
                dgpsIsMapped = !dgpsIsMapped
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(DifferentialGPSStation.fullDataSourceName) Map")
            .overlay(CheckBadge(on: $dgpsIsMapped)
                .accessibilityElement()
                .accessibilityLabel("\(DifferentialGPSStation.fullDataSourceName) Map \(dgpsIsMapped ? "On" : "Off")"))
            .padding(8)
        }
        .frame(maxWidth: 500, alignment: .center)
    }
}
