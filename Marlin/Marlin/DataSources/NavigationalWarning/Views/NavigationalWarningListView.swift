//
//  NavigationalWarningListView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI
import MapKit

struct RootPresentationModeKey: EnvironmentKey {
    static let defaultValue: Binding<RootPresentationMode> = .constant(RootPresentationMode())
}

extension EnvironmentValues {
    var rootPresentationMode: Binding<RootPresentationMode> {
        get { return self[RootPresentationModeKey.self] }
        set { self[RootPresentationModeKey.self] = newValue }
    }
}

typealias RootPresentationMode = Bool

extension RootPresentationMode {
    
    public mutating func dismiss() {
        self.toggle()
    }
}

struct NavigationalWarningMapView<Content: View>: View {
    @ViewBuilder var bottomButtons: Content
    @StateObject var mixins: NavigationalMapMixins = NavigationalMapMixins()
    @StateObject var mapState: MapState = MapState()
    
    var body: some View {
        MarlinMap(name: "Navigational Warning List View Map", mixins: mixins, mapState: mapState)
            .overlay(alignment: .bottom) {
                HStack(alignment: .bottom, spacing: 0) {
                    Spacer()
                    VStack {
                        bottomButtons
                        UserTrackingButton(mapState: mapState)
                            .fixedSize()
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("User Tracking")
                    }
                }
                .padding(.trailing, 8)
                .padding(.bottom, 30)
            }
    }
}

struct NavigationalWarningListView<Location>: View where Location: LocationManagerProtocol  {
    @StateObject var navState = NavState()
    
    let MAP_NAME = "Navigational Warning List View Map"
    @Environment(\.managedObjectContext) private var viewContext
    var locationManager: Location
    @State var expandMap: Bool = false
    @State var selection: String? = nil
    let tabFocus = NotificationCenter.default.publisher(for: .TabRequestFocus)

    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
    
    init(locationManager: Location = LocationManager.shared) {
        self.locationManager = locationManager
    }
    
    var body: some View {
        Self._printChanges()
        return GeometryReader { geometry in
            NavigationLink(tag: "detail", selection: $selection) {
                if let data = itemWrapper.dataSource as? DataSourceViewBuilder {
                    data.detailView
                }
            } label: {
                EmptyView()
            }
            .isDetailLink(false)
            .hidden()
            
            VStack(spacing: 0) {
                NavigationalWarningMapView(bottomButtons: {
                    ViewExpandButton(expanded: $expandMap)
                })
                .frame(minHeight: expandMap ? geometry.size.height : geometry.size.height * 0.3, maxHeight: expandMap ? geometry.size.height : geometry.size.height * 0.5)
                .edgesIgnoringSafeArea([.leading, .trailing])
                List {
                    NavigationalWarningAreasView(locationManager: locationManager, mapName: MAP_NAME)
                        .listRowBackground(Color.surfaceColor)
                        .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
                        .environmentObject(navState)
                }
                .listStyle(.plain)
                .onAppear {
                    Metrics.shared.appRoute([NavigationalWarning.metricsKey, "group"])
                    Metrics.shared.dataSourceList(dataSource: NavigationalWarning.self)
                }
            }
        }
        .navigationTitle(NavigationalWarning.fullDataSourceName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.surfaceColor)
        .onReceive(tabFocus) { output in
            let tabName = output.object as? String
            if tabName == nil || tabName == "\(NavigationalWarning.key)List" {
                selection = "Navigational Warning View"
                navState.rootViewId = UUID()
            }
        }
        .onAppear {
            navState.navGroupName = "\(NavigationalWarning.key)List"
            navState.mapName = MAP_NAME
        }
        .id(navState.rootViewId)
    }
}

struct NavigationalWarningAreasView<Location>: View where Location: LocationManagerProtocol {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navState: NavState
    @ObservedObject var locationManager: Location
    
    var mapName: String?
    
    @AppStorage("showUnparsedNavigationalWarnings") var showUnparsedNavigationalWarnings = false
    
    @SectionedFetchRequest<String, NavigationalWarning>
    var currentNavigationalWarningsSections: SectionedFetchResults<String, NavigationalWarning>

    @SectionedFetchRequest<String, NavigationalWarning>
    var navigationalWarningsSections: SectionedFetchResults<String, NavigationalWarning>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \NavigationalWarning.navArea, ascending: false), NSSortDescriptor(keyPath: \NavigationalWarning.issueDate, ascending: false)],
        predicate: NSPredicate(format: "locations == nil"),
        animation: .default)
    private var noParsedLocationNavigationalWarnings: FetchedResults<NavigationalWarning>
    
    init(locationManager: Location, mapName: String?) {
        self.locationManager = locationManager
        let currentArea = locationManager.currentNavArea
        self._currentNavigationalWarningsSections = SectionedFetchRequest<String, NavigationalWarning>(entity: NavigationalWarning.entity(), sectionIdentifier: \NavigationalWarning.navArea!, sortDescriptors: [NSSortDescriptor(keyPath: \NavigationalWarning.navArea, ascending: false), NSSortDescriptor(keyPath: \NavigationalWarning.issueDate, ascending: false)], predicate: NSPredicate(format: "navArea = %@", currentArea?.name ?? ""))
    
        self._navigationalWarningsSections = SectionedFetchRequest<String, NavigationalWarning>(entity: NavigationalWarning.entity(), sectionIdentifier: \NavigationalWarning.navArea!, sortDescriptors: [NSSortDescriptor(keyPath: \NavigationalWarning.navArea, ascending: false), NSSortDescriptor(keyPath: \NavigationalWarning.issueDate, ascending: false)], predicate: NSPredicate(format: "navArea != %@", currentArea?.name ?? ""))
        
        self.mapName = mapName
    }
    
    var body: some View {
        ForEach(currentNavigationalWarningsSections) { section in
            NavigationLink {
                NavigationalWarningNavAreaListView(warnings: Array<NavigationalWarning>(section), navArea: section.id, mapName: mapName)
                    .environmentObject(navState)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(NavigationalWarningNavArea.fromId(id: section.id)?.display ?? "")
                            .font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.87)
                        Text("\(section.count) Active")
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.6)
                    }
                    Spacer()
                    NavigationalWarningAreaUnreadBadge(navArea: section.id, warnings: Array<NavigationalWarning>(section))
                }
            }
            .isDetailLink(false)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(NavigationalWarningNavArea.fromId(id: section.id)?.display ?? "Navigation Area") (Current)")
            .padding(.leading, 8)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(
                HStack {
                    Rectangle()
                        .fill(Color(NavigationalWarningNavArea.fromId(id: section.id)?.color ?? UIColor.clear))
                        .frame(maxWidth: 6, maxHeight: .infinity)
                    Spacer()
                }.padding([.leading, .top, .bottom], -8)
            )
        }
        .listRowBackground(Color.surfaceColor)
        .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
        
        ForEach(navigationalWarningsSections) { section in
            NavigationLink {
                NavigationalWarningNavAreaListView(warnings: Array<NavigationalWarning>(section), navArea: section.id, mapName: mapName)
                    .environmentObject(navState)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(NavigationalWarningNavArea.fromId(id: section.id)?.display ?? "")
                            .font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.87)
                        Text("\(section.count) Active")
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.6)
                    }
                    Spacer()
                    NavigationalWarningAreaUnreadBadge(navArea: section.id, warnings: Array<NavigationalWarning>(section))
                }
            }
            .isDetailLink(false)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(NavigationalWarningNavArea.fromId(id: section.id)?.display ?? "Navigation Area")
            .padding(.leading, 8)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(
                HStack {
                    Rectangle()
                        .fill(Color(NavigationalWarningNavArea.fromId(id: section.id)?.color ?? UIColor.clear))
                        .frame(maxWidth: 6, maxHeight: .infinity)
                    Spacer()
                }.padding([.leading, .top, .bottom], -8)
            )
        }
        .listRowBackground(Color.surfaceColor)
        .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
        
        if showUnparsedNavigationalWarnings {
            NavigationLink {
                NavigationalWarningNavAreaListView(warnings: Array<NavigationalWarning>(noParsedLocationNavigationalWarnings), navArea: "Unknown", mapName: mapName)
                    .environmentObject(navState)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Unparsed Locations")
                            .font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.87)
                        Text("\(noParsedLocationNavigationalWarnings.count)")
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.6)
                    }
                    Spacer()
                }
            }
            .isDetailLink(false)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Unparsed Locations Navigation Area")
            .padding(.leading, 8)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .listRowBackground(Color.surfaceColor)
            .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
        }
    }
}
