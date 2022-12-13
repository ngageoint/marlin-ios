//
//  OnboardingView.swift
//  Marlin
//
//  Created by Daniel Barela on 10/18/22.
//

import SwiftUI
import CoreLocation

struct OnboardingView: View {
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
    
    @State var locationAuthorizationStatus: CLAuthorizationStatus = LocationManager.shared.locationStatus ?? .notDetermined
    
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
                    tabSelection = NOTIFICATION_TAB
                }
            }
            .onAppear {
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
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
        VStack(alignment: .center, spacing: 0) {
            
            HStack(alignment: .bottom) {
                VStack(alignment: .center, spacing: 16) {
                    Text(title)
                        .font(.headline4)
                        .bold()
                        .opacity(0.94)
                    
                    if let explanation = explanation {
                        Text(explanation)
                            .font(.headline6)
                            .opacity(0.87)
                    }
                }
                .padding(.top, 24)
            }
            .frame(height: geometry.size.height * 0.25)
            
            HStack(alignment: .bottom) {
                if let imageAreaContent = imageAreaContent {
                    imageAreaContent
                }
                if let imageName = imageName {
                    Image(imageName)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if let systemImageName = systemImageName {
                    Image(systemName: systemImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(Color.black)
                        .frame(width: geometry.size.width * 0.50)
                }
            }
            .frame(height: geometry.size.height * 0.50)
            
            HStack(alignment: .top) {
                VStack(alignment: .center, spacing: 16) {
                    buttons
                        .padding(.top, 24)
                    Spacer()
                }
                .padding(.top, 24)
            }
            .frame(height: geometry.size.height * 0.25)
        }
        .padding([.top, .leading, .trailing], 16)
        .padding(.bottom, 40)
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
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
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
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    if(settings.authorizationStatus == .authorized) {
                        tabSelection = DATA_TABS_TAB
                    } else {
                        tabSelection = NOTIFICATION_TAB
                    }
                }
            }
        case LOCATION_TAB:
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
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
        tabContent(geometry: geometry, imageName: "marlin_large", title: "Welcome to Marlin", explanation: "Marlin puts NGA's Maritime Safety Information datasets at your fingertips even when offline. The next few screens will allow you to customize your experience to meet your needs.", buttons: VStack(alignment: .center, spacing: 16) {
            Button("Let's Go") {
                nextTab(currentTab: WELCOME_TAB)
            }
            .tint(Color.primaryColor)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
        })
    }
    
    @ViewBuilder
    func disclaimerTab(geometry: GeometryProxy) -> some View {
        VStack(alignment: .center, spacing: 0) {
            
            VStack(spacing: 16) {
                Text("Disclaimer")
                    .font(.headline4)
                    .bold()
                ScrollView {
                    DisclaimerView()
                    Button("Accept") {
                        disclaimerAccepted.toggle()
                        nextTab(currentTab: DISCLAIMER_TAB)
                    }
                    .tint(Color.primaryColor)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .padding(.bottom, 40)
                }
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
                            LocationManager.shared.requestAuthorization()
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
                            let center = UNUserNotificationCenter.current()
                            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
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
        tabContent(geometry: geometry, imageAreaContent: dataSourceTabGrid(), title: "Marlin Tabs", explanation: "Choose up to 4 dataset tabs for the tab bar.  Other datasets will be accessible in the navigation menu.", buttons:
                    VStack(spacing: 16) {
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
                    }
        )
    }
    
    @ViewBuilder
    func dataMapTab(geometry: GeometryProxy) -> some View {
        tabContent(geometry: geometry, imageAreaContent: dataSourceMapGrid(), title: "Marlin Map", explanation: "Choose what datasets you want to see on the map.  This can always be changed via the navigation menu.", buttons:
                    VStack(spacing: 16) {
                        Button("Take Me To Marlin") {
                            onboardingComplete = true
                        }
                        .tint(Color.primaryColor)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                    }
        )
    }
    
    @ViewBuilder
    func dataSourceTabGrid() -> some View {
        VStack(alignment: .center, spacing: 16) {
            
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .center) {
                    if let image = Asam.image {
                        Image(uiImage: image)
                            .renderingMode(.template)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                .background(Circle().fill(Color(uiColor: Asam.color))))
                    }
                    Text(Asam.dataSourceName)
                        .foregroundColor(Color.onPrimaryColor)
                }
                .frame(width: 100, height: 100)
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
                .overlay(CheckBadge(on: .constant(asamIsTab)))
                
                VStack(alignment: .center) {
                    if let image = Modu.image {
                        Image(uiImage: image)
                            .renderingMode(.template)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                .background(Circle().fill(Color(uiColor: Modu.color))))
                    }
                    Text(Modu.dataSourceName)
                        .foregroundColor(Color.onPrimaryColor)
                }
                .frame(width: 100, height: 100)
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
                .overlay(CheckBadge(on: .constant(moduIsTab)))
                
                VStack(alignment: .center) {
                    if let image = Light.image {
                        Image(uiImage: image)
                            .renderingMode(.template)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                .background(Circle().fill(Color(uiColor: Light.color))))
                    }
                    Text(Light.dataSourceName)
                        .foregroundColor(Color.onPrimaryColor)
                }
                .frame(width: 100, height: 100)
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
                .overlay(CheckBadge(on: .constant(lightIsTab)))
                
            }
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .center) {
                    if let image = NavigationalWarning.image {
                        Image(uiImage: image)
                            .renderingMode(.template)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                .background(Circle().fill(Color(uiColor: NavigationalWarning.color))))
                    }
                    Text(NavigationalWarning.dataSourceName)
                        .foregroundColor(Color.onPrimaryColor)
                }
                .frame(width: 100, height: 100)
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
                .overlay(CheckBadge(on: .constant(navWarningIsTab)))
                
                VStack(alignment: .center) {
                    if let image = Port.image {
                        Image(uiImage: image)
                            .renderingMode(.template)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                .background(Circle().fill(Color(uiColor: Port.color))))
                    }
                    Text(Port.dataSourceName)
                        .foregroundColor(Color.onPrimaryColor)
                }
                .frame(width: 100, height: 100)
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
                .overlay(CheckBadge(on: .constant(portIsTab)))
                
                VStack(alignment: .center) {
                    if let image = RadioBeacon.image {
                        Image(uiImage: image)
                            .renderingMode(.template)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                .background(Circle().fill(Color(uiColor: RadioBeacon.color))))
                    }
                    Text(RadioBeacon.dataSourceName)
                        .foregroundColor(Color.onPrimaryColor)
                }
                .frame(width: 100, height: 100)
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
                .overlay(CheckBadge(on: .constant(radioBeaconIsTab)))
                
            }
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .center) {
                    if let image = DifferentialGPSStation.image {
                        Image(uiImage: image)
                            .renderingMode(.template)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                .background(Circle().fill(Color(uiColor: DifferentialGPSStation.color))))
                    }
                    Text(DifferentialGPSStation.dataSourceName)
                        .foregroundColor(Color.onPrimaryColor)
                }
                .frame(width: 100, height: 100)
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
                .overlay(CheckBadge(on: .constant(dgpsIsTab)))
                VStack(alignment: .center) {
                    if let image = ElectronicPublication.image {
                        Image(uiImage: image)
                            .renderingMode(.template)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                .background(Circle().fill(Color(uiColor: ElectronicPublication.color))))
                    }
                    Text(ElectronicPublication.dataSourceName)
                        .foregroundColor(Color.onPrimaryColor)
                }
                .frame(width: 100, height: 100)
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
                .overlay(CheckBadge(on: .constant(epubIsTab)))
                VStack(alignment: .center) {
                    if let image = NoticeToMariners.image {
                        Image(uiImage: image)
                            .renderingMode(.template)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                .background(Circle().fill(Color(uiColor: NoticeToMariners.color))))
                    }
                    Text(NoticeToMariners.dataSourceName)
                        .foregroundColor(Color.onPrimaryColor)
                }
                .frame(width: 100, height: 100)
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
                .overlay(CheckBadge(on: .constant(ntmIsTab)))
            }
        }
    }
        
        @ViewBuilder
        func dataSourceMapGrid() -> some View {
            VStack(alignment: .center, spacing: 16) {
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .center) {
                        if let image = Asam.image {
                            Image(uiImage: image)
                                .renderingMode(.template)
                                .frame(width: 50, height: 50)
                                .tint(Color.white)
                                .clipShape(Circle())
                                .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                    .background(Circle().fill(Color(uiColor: Asam.color))))
                        }
                        Text(Asam.dataSourceName)
                            .foregroundColor(Color.onPrimaryColor)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.secondaryColor)
                    .cornerRadius(2)
                    .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
                    .onTapGesture {
                        asamIsMapped = !asamIsMapped
                    }
                    .overlay(CheckBadge(on: $asamIsMapped))
                    
                    VStack(alignment: .center) {
                        if let image = Modu.image {
                            Image(uiImage: image)
                                .renderingMode(.template)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                    .background(Circle().fill(Color(uiColor: Modu.color))))
                            
                        }
                        Text(Modu.dataSourceName)
                            .foregroundColor(Color.onPrimaryColor)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.secondaryColor)
                    .cornerRadius(2)
                    .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
                    .onTapGesture {
                        moduIsMapped = !moduIsMapped
                    }
                    .overlay(CheckBadge(on: $moduIsMapped))
                    
                    VStack(alignment: .center) {
                        if let image = Light.image {
                            Image(uiImage: image)
                                .renderingMode(.template)
                                .frame(width: 50, height: 50)
                                .tint(Color.white)
                                .clipShape(Circle())
                                .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                    .background(Circle().fill(Color(uiColor: Light.color))))
                        }
                        Text(Light.dataSourceName)
                            .foregroundColor(Color.onPrimaryColor)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.secondaryColor)
                    .cornerRadius(2)
                    .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
                    .onTapGesture {
                        lightIsMapped = !lightIsMapped
                    }
                    .overlay(CheckBadge(on: $lightIsMapped))
                    
                }
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .center) {
                        if let image = Port.image {
                            Image(uiImage: image)
                                .renderingMode(.template)
                                .frame(width: 50, height: 50)
                                .tint(Color.white)
                                .clipShape(Circle())
                                .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                    .background(Circle().fill(Color(uiColor: Port.color))))
                        }
                        Text(Port.dataSourceName)
                            .foregroundColor(Color.onPrimaryColor)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.secondaryColor)
                    .cornerRadius(2)
                    .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
                    .onTapGesture {
                        portIsMapped = !portIsMapped
                    }
                    .overlay(CheckBadge(on: $portIsMapped))
                    
                    VStack(alignment: .center) {
                        if let image = RadioBeacon.image {
                            Image(uiImage: image)
                                .renderingMode(.template)
                                .frame(width: 50, height: 50)
                                .tint(Color.white)
                                .clipShape(Circle())
                                .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                    .background(Circle().fill(Color(uiColor: RadioBeacon.color))))
                        }
                        Text(RadioBeacon.dataSourceName)
                            .foregroundColor(Color.onPrimaryColor)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.secondaryColor)
                    .cornerRadius(2)
                    .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
                    .onTapGesture {
                        radioBeaconIsMapped = !radioBeaconIsMapped
                    }
                    .overlay(CheckBadge(on: $radioBeaconIsMapped))
                    
                    VStack(alignment: .center) {
                        if let image = DifferentialGPSStation.image {
                            Image(uiImage: image)
                                .renderingMode(.template)
                                .frame(width: 50, height: 50)
                                .tint(Color.white)
                                .clipShape(Circle())
                                .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                                    .background(Circle().fill(Color(uiColor: DifferentialGPSStation.color))))
                        }
                        Text(DifferentialGPSStation.dataSourceName)
                            .foregroundColor(Color.onPrimaryColor)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.secondaryColor)
                    .cornerRadius(2)
                    .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
                    .onTapGesture {
                        dgpsIsMapped = !dgpsIsMapped
                    }
                    .overlay(CheckBadge(on: $dgpsIsMapped))
                }
            }
        }
}

struct CheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                VStack(alignment: .center) {
                    Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(configuration.isOn ? .secondaryColor : .onPrimaryColor)
                        .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                        .imageScale(.large)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
