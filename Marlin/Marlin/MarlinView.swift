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
    @Published var dataSource: (any DataSource)?
    @Published var date: Date?
}

class BottomSheetItemList: ObservableObject {
    @Published var bottomSheetItems: [BottomSheetItem]?
}

extension MarlinView: BottomSheetDelegate {
    func bottomSheetDidDismiss() {
        NotificationCenter.default.post(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: nil))
    }
}

struct MarlinView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @StateObject var dataSourceList: DataSourceList = DataSourceList()
    @State var selection: String? = nil
    @State var showBottomSheet: Bool = false
    @StateObject var bottomSheetItemList: BottomSheetItemList = BottomSheetItemList()
        
    @State var showSnackbar: Bool = false
    @State var snackbarModel: SnackbarModel?
    
    @State var filterOpen: Bool = false
    
    @State private var previewDate: Date = Date()
    @State private var previewUrl: URL?
    
    @StateObject var mapState: MapState = MapState()
    
    @AppStorage("userTrackingMode") var userTrackingMode: Int = Int(MKUserTrackingMode.none.rawValue)
    @AppStorage("initialDataLoaded") var initialDataLoaded: Bool = true
    @AppStorage("disclaimerAccepted") var disclaimerAccepted: Bool = false
    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false

    let mapItemsTappedPub = NotificationCenter.default.publisher(for: .MapItemsTapped)
    let dismissBottomSheetPub = NotificationCenter.default.publisher(for: .DismissBottomSheet)
    let snackbarPub = NotificationCenter.default.publisher(for: .SnackbarNotification)
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }
    let documentPreviewPub = NotificationCenter.default.publisher(for: .DocumentPreview).map { notification in
        notification.object
    }
    
    var mixins: [MapMixin]
    
    init() {
        var mixins: [MapMixin] = [PersistedMapState(), SearchResultsMap()]

        if UserDefaults.standard.dataSourceEnabled(DifferentialGPSStation.self) {
            mixins.append(DifferentialGPSStationMap(showAsTiles: true))
        }
        if UserDefaults.standard.dataSourceEnabled(DFRS.self) {
            mixins.append(DFRSMap(showAsTiles: true))
        }
        if UserDefaults.standard.dataSourceEnabled(Light.self) {
            mixins.append(LightMap<Light>(showAsTiles: true))
        }
        if UserDefaults.standard.dataSourceEnabled(Port.self) {
            mixins.append(PortMap(showAsTiles: true))
        }
        if UserDefaults.standard.dataSourceEnabled(RadioBeacon.self) {
            mixins.append(RadioBeaconMap(showAsTiles: true))
        }
        if UserDefaults.standard.dataSourceEnabled(Modu.self) {
            mixins.append(ModuMap(showAsTiles: true))
        }
        if UserDefaults.standard.dataSourceEnabled(Asam.self) {
            mixins.append(AsamMap(showAsTiles: true))
        }
        self.mixins = mixins
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            if !onboardingComplete {
                OnboardingView(dataSourceList: dataSourceList)
            } else
            if !disclaimerAccepted {
                VStack(spacing: 16) {
                    Text("Disclaimer")
                        .font(.headline5)
                    ScrollView {
                        DisclaimerView()
                        Button("Accept") {
                            disclaimerAccepted.toggle()
                        }
                    }
                }
                .gradientView()
            } else {
                
                if horizontalSizeClass == .compact {
                    
                    MarlinCompactWidth(dataSourceList: dataSourceList, filterOpen: $filterOpen, marlinMap: MarlinMap(name: "Marlin Compact Map", mixins: mixins, mapState: mapState)
                    )
                } else {
                    MarlinRegularWidth(filterOpen: $filterOpen, dataSourceList: dataSourceList, marlinMap: MarlinMap(name: "Marlin Regular Map", mixins: mixins, mapState: mapState))
                }
            }
        }
        .onChange(of: userTrackingMode) { newValue in
            mapState.userTrackingMode = newValue
        }
        // TODO: this can be replaced with .sheet introduced in ios16 when we are at 17
        .bottomSheet(isPresented: $showBottomSheet, delegate: self) {
            MarlinBottomSheet(itemList: bottomSheetItemList)
        }
        .bottomSheet(isPresented: $filterOpen, detents: .large, delegate: self) {
            FilterBottomSheet(dataSources: $dataSourceList.mappedDataSources)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            filterOpen.toggle()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(Color.onPrimaryColor.opacity(0.87))
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Close Filter")
                    }
                }
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
        .documentPreview(previewUrl: $previewUrl, previewDate: $previewDate) { }
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
            bottomSheetItems += self.handleTappedItems(items: notification.items)
            if bottomSheetItems.count == 0 {
                return
            }
            bottomSheetItemList.bottomSheetItems = bottomSheetItems
            showBottomSheet.toggle()
        }
        .onReceive(dismissBottomSheetPub) { output in
            showBottomSheet = false
        }
        .onReceive(documentPreviewPub) { output in
            if let url = output as? URL {
                previewUrl = url
            }
            previewDate = Date()
        }
        .onAppear {
            Metrics.shared.appLaunch()
        }
    }
    
    func handleTappedItems(items: [any DataSource]?) -> [BottomSheetItem] {
        var bottomSheetItems: [BottomSheetItem] = []
        if let items = items {
            for item in items {
                let bottomSheetItem = BottomSheetItem(item: item, actionDelegate: self, annotationView: nil)
                bottomSheetItems.append(bottomSheetItem)
            }
        }
        return bottomSheetItems
    }

}
