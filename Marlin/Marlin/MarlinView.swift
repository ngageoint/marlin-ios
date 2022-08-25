//
//  TabView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/13/22.
//

import SwiftUI
import MapKit

class ItemWrapper : ObservableObject {
    @Published var asam: Asam?
    @Published var modu: Modu?
    @Published var dataSource: DataSource?
    @Published var date: Date?
}

class BottomSheetItemList: ObservableObject {
    @Published var bottomSheetItems: [BottomSheetItem]?
}

extension MarlinView: BottomSheetDelegate {
    func bottomSheetDidDismiss() {
        NotificationCenter.default.post(name: .MapAnnotationFocused, object: MapAnnotationFocusedNotification(annotation: nil))
    }
}

struct MarlinView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var locationManager: LocationManager = LocationManager()

    @StateObject var dataSourceList: DataSourceList = DataSourceList()
    @State var menuOpen: Bool = false
    @State var showBottomSheet: Bool = false
    @StateObject var bottomSheetItemList: BottomSheetItemList = BottomSheetItemList()
    
    @State var showSnackbar: Bool = false
    @State var snackbarModel: SnackbarModel?
    
    @StateObject var mapState: MapState = MapState()
    
    @AppStorage("userTrackingMode") var userTrackingMode: Int = Int(MKUserTrackingMode.none.rawValue)

    let mapItemsTappedPub = NotificationCenter.default.publisher(for: .MapItemsTapped)
    let mapViewDisappearingPub = NotificationCenter.default.publisher(for: .MapViewDisappearing)
    let dismissBottomSheetPub = NotificationCenter.default.publisher(for: .DismissBottomSheet)
    let snackbarPub = NotificationCenter.default.publisher(for: .SnackbarNotification)
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }
    
    var mixins: [MapMixin]
    
    init() {
        var mixins: [MapMixin] = [PersistedMapState()]
        if UserDefaults.standard.dataSourceEnabled(Asam.self) {
            mixins.append(AsamMap())
        }
        if UserDefaults.standard.dataSourceEnabled(Modu.self) {
            mixins.append(ModuMap())
        }
        if UserDefaults.standard.dataSourceEnabled(Light.self) {
            mixins.append(LightMap(showLightsAsTiles: true))
        }
        if UserDefaults.standard.dataSourceEnabled(Port.self) {
            mixins.append(PortMap(showPortsAsTiles: true))
        }
        self.mixins = mixins
    }
    
    var body: some View {
        ZStack {
            if horizontalSizeClass == .compact {
                
                MarlinCompactWidth(dataSourceList: dataSourceList, marlinMap: MarlinMap(name: "Marlin Compact Map", mixins: mixins, mapState: mapState)
                ).environmentObject(locationManager)
            } else {
                NavigationView {
                    ZStack {
                        MarlinRegularWidth(dataSourceList: dataSourceList, marlinMap: MarlinMap(name: "Marlin Regular Map", mixins: mixins, mapState: mapState)).environmentObject(locationManager)
                        GeometryReader { geometry in
                            SideMenu(width: min(geometry.size.width - 56, 512),
                                     isOpen: self.menuOpen,
                                     menuClose: self.openMenu,
                                     dataSourceList: dataSourceList
                            )
                            .opacity(self.menuOpen ? 1 : 0)
                            .animation(.default, value: self.menuOpen)
                            .onReceive(switchTabPub) { output in
                                self.menuOpen.toggle()
                            }
                        }
                    }
                    .if(UserDefaults.standard.hamburger) { view in
                        view.modifier(Hamburger(menuOpen: $menuOpen))
                    }
                    .navigationTitle("Marlin")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .tint(Color.onPrimaryColor)
                .navigationViewStyle(.stack)
            }
        }
        .onChange(of: userTrackingMode) { newValue in
            mapState.userTrackingMode = newValue
        }
        // TODO: this can be replaced with .sheet introduced in ios16 when we are at 17
        .bottomSheet(isPresented: $showBottomSheet, delegate: self) {
            MarlinBottomSheet(itemList: bottomSheetItemList).environmentObject(locationManager)
        }
        .snackbar(isPresented: $showSnackbar) {
            Group {
                if let snackbarModel = snackbarModel {
                    SnackbarContent(snackbarModel: snackbarModel)
                } else {
                    EmptyView()
                }
            }
        }
        .onReceive(snackbarPub) { output in
            guard let notification = output.object as? SnackbarNotification else {
                return
            }
            self.snackbarModel = notification.snackbarModel
            showSnackbar.toggle()
        }
        .onReceive(mapItemsTappedPub) { output in
            guard let notification = output.object as? MapItemsTappedNotification else {
                return
            }
            var bottomSheetItems: [BottomSheetItem] = []
            bottomSheetItems += self.handleTappedAnnotations(annotations: notification.annotations)
            bottomSheetItems += self.handleTappedItems(items: notification.items)
            if bottomSheetItems.count == 0 {
                return
            }
            bottomSheetItemList.bottomSheetItems = bottomSheetItems
            showBottomSheet.toggle()
        }
        .onReceive(mapViewDisappearingPub) { output in
            if showBottomSheet {
                showBottomSheet.toggle()
            }
        }
        .onReceive(dismissBottomSheetPub) { output in
            if showBottomSheet {
                showBottomSheet.toggle()
            }
        }
    }
    
    func handleTappedItems(items: [DataSource]?) -> [BottomSheetItem] {
        var bottomSheetItems: [BottomSheetItem] = []
        if let items = items {
            for item in items {
                let bottomSheetItem = BottomSheetItem(item: item, actionDelegate: self, annotationView: nil)
                bottomSheetItems.append(bottomSheetItem)
            }
        }
        return bottomSheetItems
    }
    
    func handleTappedAnnotations(annotations: [Any]?) -> [BottomSheetItem] {
        var dedup: Set<AnyHashable> = Set()
        let bottomSheetItems: [BottomSheetItem] = createBottomSheetItems(annotations: annotations, dedup: &dedup)
        return bottomSheetItems
    }
    
    func createBottomSheetItems(annotations: [Any]?, dedup: inout Set<AnyHashable>) -> [BottomSheetItem] {
        var items: [BottomSheetItem] = []
        
        guard let annotations = annotations else {
            return items
        }
        
        for annotation in annotations {
            if let cluster = annotation as? MKClusterAnnotation {
                items.append(contentsOf: self.createBottomSheetItems(annotations: cluster.memberAnnotations, dedup: &dedup))
            } else if let asam = annotation as? Asam {
                if !dedup.contains(asam) {
                    _ = dedup.insert(asam)
                    let bottomSheetItem = BottomSheetItem(item: asam, actionDelegate: nil, annotationView: asam.annotationView)
                    items.append(bottomSheetItem)
                }
            } else if let modu = annotation as? Modu {
                if !dedup.contains(modu) {
                    _ = dedup.insert(modu)
                    let bottomSheetItem = BottomSheetItem(item: modu, actionDelegate: nil, annotationView: modu.annotationView)
                    items.append(bottomSheetItem)
                }
            } else if let light = annotation as? Light {
                if !dedup.contains(light) {
                    _ = dedup.insert(light)
                    let bottomSheetItem = BottomSheetItem(item: light, actionDelegate: nil, annotationView: light.annotationView)
                    items.append(bottomSheetItem)
                }
            }
        }
        
        return Array(items)
    }
    
    func openMenu() {
        self.menuOpen.toggle()
    }
}
