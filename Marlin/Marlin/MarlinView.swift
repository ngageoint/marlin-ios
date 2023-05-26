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
    @Published var mixins: [any MapMixin] = []
}

struct MarlinView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject var dataSourceList: DataSourceList

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

    let snackbarPub = NotificationCenter.default.publisher(for: .SnackbarNotification)
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }
    let documentPreviewPub = NotificationCenter.default.publisher(for: .DocumentPreview).map { notification in
        notification.object
    }
    
    var body: some View {
        Self._printChanges()
        return ZStack(alignment: .top) {
            
            if !onboardingComplete {
                OnboardingView()
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
                    MarlinCompactWidth(filterOpen: $filterOpen)
                } else {
                    MarlinRegularWidth(filterOpen: $filterOpen)
                }
            }
        }
        .background {
            MarlinDataBottomSheet()
        }
        .background {
            MappedDataSourcesFilter(showBottomSheet: $filterOpen)
                .environmentObject(dataSourceList)
        }
//        .bottomSheet(isPresented: $filterOpen, detents: .large, delegate: self) {
//            MappedDataSourcesFilter()
//                .environmentObject(dataSourceList)
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button(action: {
//                            filterOpen.toggle()
//                        }) {
//                            Image(systemName: "xmark.circle.fill")
//                                .imageScale(.large)
//                                .foregroundColor(Color.onPrimaryColor.opacity(0.87))
//                        }
//                        .accessibilityElement(children: .contain)
//                        .accessibilityLabel("Close Filter")
//                    }
//                }
//                .onAppear {
//                    Metrics.shared.appRoute(["mapFilter"])
//                }
//        }
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
    }
}
