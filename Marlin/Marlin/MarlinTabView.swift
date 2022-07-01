//
//  TabView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/13/22.
//

import SwiftUI

class ItemWrapper : ObservableObject {
    @Published var asam: Asam?
    @Published var modu: Modu?
}

struct MarlinTabView: View {
    
    @EnvironmentObject var scheme: MarlinScheme
    
    @StateObject var itemWrapper: ItemWrapper
    @State var selection: String? = nil
    @State private var selectedTab = "map"
    
    let asamPub = NotificationCenter.default.publisher(for: .ViewAsam)
    let moduPub = NotificationCenter.default.publisher(for: .ViewModu)
    let mapFocus = NotificationCenter.default.publisher(for: .MapRequestFocus)
    
    var marlinMap = MarlinMap()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                VStack {
                    ZStack(alignment: .topLeading) {
                        marlinMap
                            .mixin(AsamMap())
                            .mixin(ModuMap())
                            .mixin(BottomSheetMixin())
                            .navigationTitle("Marlin")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarBackButtonHidden(true)
                            .toolbar {
                                ToolbarItem (placement: .navigation)  {
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundColor(Color(scheme.containerScheme.colorScheme.onPrimaryColor))
                                        .onTapGesture {
                                            self.showHamburger()
                                        }
                                }
                            }
                        // top of map
                        VStack {
                            HStack(alignment: .top, spacing: 0) {
                                Spacer()
                                // top right button stack
                                VStack(alignment: .trailing, spacing: 16) {
                                    NavigationLink {
                                        MapSettings()
                                    } label: {
                                        MaterialFloatingButton(imageName: .constant("square.3.stack.3d"))
                                    }
                                    .offset(x: -8, y: 16)
                                    .fixedSize()
                                }
                        }
                        Spacer()
                        // bottom of map
                            HStack(alignment: .bottom, spacing: 0) {
                                Spacer()
                                // bottom right button stack
                                VStack(alignment: .trailing, spacing: 16) {
                                    UserTrackingButton(mapView: marlinMap.mutatingWrapper.mapView)
                                        .offset(x: -8, y: -24)
                                        .fixedSize()
                                }
                            }
                        }
                    }
                    NavigationLink(tag: "asam", selection: $selection) {
                        if let asam = itemWrapper.asam {
                            AsamDetailView(asam: asam)
                        } else {
                            EmptyView()
                        }
                    } label: {
                        EmptyView()
                    }.hidden()
                    NavigationLink(tag: "modu", selection: $selection) {
                        if let modu = itemWrapper.modu {
                            ModuDetailView(modu: modu)
                        } else {
                            EmptyView()
                        }
                    } label: {
                        EmptyView()
                    }.hidden()
                }
            }
            .tag("map")
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }
            // this affects text buttons, image buttons need .foregroundColor set on them
            .tint(Color(scheme.containerScheme.colorScheme.onPrimaryColor))
            .navigationViewStyle(.stack)
            .statusBar(hidden: false)
            
            ModuListView()
                .tabItem {
                    Label("MODUs", image: "modu")
                }
                .tag("moduList")
            
            AsamListView()
                .tabItem {
                    Label("ASAMs", image: "asam")
                }
                .tag("asamList")
            NavigationalWarningListView()
                .tabItem {
                    Label("Warnings", systemImage: "exclamationmark.triangle.fill")
                }
                .tag("warningList")
        }
        .onReceive(asamPub) { output in
            viewAsam(output.object as! Asam)
        }
        .onReceive(moduPub) { output in
            viewModu(output.object as! Modu)
        }
        .onReceive(mapFocus) { output in
            selectedTab = "map"
        }
    }
    
    func viewAsam(_ asam: Asam) {
        NotificationCenter.default.post(name: .MapAnnotationFocused, object: MapAnnotationFocusedNotification(annotation: nil, mapView: nil))
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        itemWrapper.asam = asam
        selection = "asam"
    }
    
    func viewModu(_ modu: Modu) {
        NotificationCenter.default.post(name: .MapAnnotationFocused, object: MapAnnotationFocusedNotification(annotation: nil, mapView: nil))
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        itemWrapper.modu = modu
        selection = "modu"
    }
    
    private func showHamburger() {
    }
}
