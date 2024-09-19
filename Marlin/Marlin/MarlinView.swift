//
//  TabView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/13/22.
//

import SwiftUI
import MapKit

class ItemWrapper: ObservableObject, Identifiable, Hashable {
    static func == (lhs: ItemWrapper, rhs: ItemWrapper) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id = UUID()
    @Published var dataSource: (any DataSource)?
    @Published var date: Date?
}

class MapMixins: ObservableObject {
    @Published var mixins: [any MapMixin] = []
}

struct MarlinView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject var dataSourceList: DataSourceList
    @EnvironmentObject var appState: AppState
    
    @State var selection: String?
    @State var showBottomSheet: Bool = false

    @State var showSnackbar: Bool = false
    @State var snackbarModel: SnackbarModel?

    @State var filterOpen: Bool = false

    @State private var previewDate: Date = Date()
    @State private var previewUrl: URL?
    @State var isMapLayersPresented: Bool = false
    @State var mapLayerEditViewModel: MapLayerViewModel?

    @AppStorage("initialDataLoaded") var initialDataLoaded: Bool = true
    @AppStorage("disclaimerAccepted") var disclaimerAccepted: Bool = false
    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false

    let snackbarPub = NotificationCenter.default.publisher(for: .SnackbarNotification)
    let documentPreviewPub = NotificationCenter.default.publisher(for: .DocumentPreview).map { notification in
        notification.object
    }
    let dataSourceLoadingPub = NotificationCenter.default.publisher(for: .DataSourceLoading).map { notification in
        notification.object
    }
    let dataSourceLoadedPub = NotificationCenter.default.publisher(for: .DataSourceLoaded).map { notification in
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
            MappedDataSourcesFilter(showBottomSheet: $filterOpen)
                .environmentObject(dataSourceList)
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
        .onReceive(dataSourceLoadingPub) { output in
            guard let dataSourceItem = output as? DataSourceItem else {
                return
            }
            self.appState.loadingDataSource[dataSourceItem.key] = true
        }
        .onReceive(dataSourceLoadedPub) { output in
            guard let dataSourceItem = output as? DataSourceItem else {
                return
            }
            self.appState.loadingDataSource[dataSourceItem.key] = false
        }
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
        .fullScreenCover(
            item: $mapLayerEditViewModel,
            onDismiss: {
                isMapLayersPresented = false
                mapLayerEditViewModel = nil
            },
            content: { viewModel in
                NavigationView {
                    MapLayerView(viewModel: viewModel, isPresented: $isMapLayersPresented)
                }
            }
        )
        .onAppear {
            Metrics.shared.appLaunch()
        }
        // this affects text buttons, image buttons need .foregroundColor set on them
        .tint(Color.onPrimaryColor)
        // This is deprecated, but in iOS16 this is the only way to set the back button color
        .accentColor(Color.onPrimaryColor)
    }
}
