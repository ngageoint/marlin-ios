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

extension MarlinView: BottomSheetDelegate {
    func bottomSheetDidDismiss() {
        NotificationCenter.default.post(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: nil))
    }
}

class MapMixins: ObservableObject {
    var mixins: [MapMixin]
    init(mixins: [MapMixin]) {
        self.mixins = mixins
    }
}

struct MarlinView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @StateObject var dataSourceList: DataSourceList = DataSourceList()
    @State var selection: String? = nil
    @State var showBottomSheet: Bool = false
        
    @State var showSnackbar: Bool = false
    @State var snackbarModel: SnackbarModel?
    
    @State var filterOpen: Bool = false
    
    @State private var previewDate: Date = Date()
    @State private var previewUrl: URL?
    @State var isMapLayersPresented: Bool = false
    @State var mapLayerEditViewModel: MapLayerViewModel? = nil
        
    @AppStorage("initialDataLoaded") var initialDataLoaded: Bool = true
    @AppStorage("disclaimerAccepted") var disclaimerAccepted: Bool = false
    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false

    let dismissBottomSheetPub = NotificationCenter.default.publisher(for: .DismissBottomSheet)
    let snackbarPub = NotificationCenter.default.publisher(for: .SnackbarNotification)
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }
    let documentPreviewPub = NotificationCenter.default.publisher(for: .DocumentPreview).map { notification in
        notification.object
    }
    
    @State var mixins: [MapMixin]
    
    init() {
        var mixins: [MapMixin] = [PersistedMapState(), SearchResultsMap(), UserLayersMap()]

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
        if UserDefaults.standard.showNavigationalWarningsOnMainMap {
            mixins.append(NavigationalWarningMap())
        }
        _mixins = State(wrappedValue: mixins)
    }
    
    var body: some View {
        Self._printChanges()
        return ZStack(alignment: .top) {
            
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
                    
                    MarlinCompactWidth(dataSourceList: dataSourceList, filterOpen: $filterOpen, marlinMap: MarlinMap(name: "Marlin Compact Map", mixins: mixins)
                    )
                } else {
                    MarlinRegularWidth(filterOpen: $filterOpen, dataSourceList: dataSourceList, marlinMap: MarlinMap(name: "Marlin Regular Map", mixins: mixins))
                }
            }
        }
        .background {
            MarlinDataBottomSheet()
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
                .onAppear {
                    Metrics.shared.appRoute(["mapFilter"])
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
        
        .onReceive(dismissBottomSheetPub) { output in
            showBottomSheet = false
        }
        .onReceive(documentPreviewPub) { output in
            if let url = output as? URL {
                previewUrl = url
            }
            previewDate = Date()
        }
        .onOpenURL(perform: { url in
            if url.isFileURL {
                if url.pathExtension == "gpkg" || url.pathExtension == "gpkx" {
                    mapLayerEditViewModel = MapLayerViewModel()
                    mapLayerEditViewModel?.fileChosen(url: url)
                    isMapLayersPresented = true
                }
            }
        })
        .fullScreenCover(item: $mapLayerEditViewModel, onDismiss: {
            isMapLayersPresented = false
            mapLayerEditViewModel = nil
        }) { viewModel in
            NavigationView {
                MapLayerView(viewModel: viewModel, isPresented: $isMapLayersPresented)
            }
        }
        .onAppear {
            Metrics.shared.appLaunch()
        }
        // this affects text buttons, image buttons need .foregroundColor set on them
        .tint(Color.onPrimaryColor)
        // This is deprecated, but in iOS16 this is the only way to set the back button color
        .accentColor(Color.onPrimaryColor)
//        .environmentObject(appState)
    }
}
