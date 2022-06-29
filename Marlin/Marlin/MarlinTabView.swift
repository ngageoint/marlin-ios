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
    
    let asamPub = NotificationCenter.default.publisher(for: .ViewAsam)
    let moduPub = NotificationCenter.default.publisher(for: .ViewModu)
    
    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    MarlinMap()
                        .mixin(AsamMap())
                        .mixin(ModuMap())
                        .mixin(BottomSheetMixin())
                        .mixin(UserTrackingMap())
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
            
            AsamListView()
                .tabItem {
                    Label("ASAMs", image: "asam")
                }
            NavigationalWarningListView()
                .tabItem {
                    Label("Warnings", systemImage: "exclamationmark.triangle.fill")
                }
            

        }
        .onReceive(asamPub) { output in
            viewAsam(output.object as! Asam)
        }
        .onReceive(moduPub) { output in
            viewModu(output.object as! Modu)
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
